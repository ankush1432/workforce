import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:supervisor_app/core/config/app_config.dart';
import 'package:supervisor_app/features/face/data/facenet_service.dart';
import 'package:supervisor_app/features/face/data/image_preprocessor.dart';
import 'package:supervisor_app/features/face/data/liveness_detection_service.dart';

final faceEmbeddingGeneratorProvider = Provider<FaceEmbeddingGenerator>((ref) {
  final generator = FaceEmbeddingGenerator(
    facenet: ref.watch(facenetServiceProvider),
    preprocessor: const ImagePreprocessor(),
    liveness: ref.watch(livenessDetectionServiceProvider),
  );
  ref.onDispose(generator.dispose);
  return generator;
});

class FaceEmbeddingResult {
  const FaceEmbeddingResult({
    required this.embedding,
    required this.qualityScore,
    required this.livenessPassed,
  });

  final List<double> embedding;
  final double qualityScore;
  final bool livenessPassed;
}

class FaceQualityReport {
  const FaceQualityReport({
    required this.score,
    required this.isAcceptable,
    required this.sharpness,
    required this.brightness,
    required this.faceSizeRatio,
    required this.message,
  });

  final double score;
  final bool isAcceptable;
  final double sharpness;
  final double brightness;
  final double faceSizeRatio;
  final String message;
}

/// End-to-end: ML Kit detection → quality → preprocess → FaceNet → 128-d embedding.
class FaceEmbeddingGenerator {
  FaceEmbeddingGenerator({
    required FacenetService facenet,
    required ImagePreprocessor preprocessor,
    required LivenessDetectionService liveness,
  })  : _facenet = facenet,
        _preprocessor = preprocessor,
        _liveness = liveness,
        _captureDetector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.accurate,
            enableClassification: true,
            enableLandmarks: false,
            minFaceSize: 0.12,
          ),
        );

  final FacenetService _facenet;
  final ImagePreprocessor _preprocessor;
  final LivenessDetectionService _liveness;
  final FaceDetector _captureDetector;

  Future<void> warmUp() => _facenet.load();

  Future<List<Face>> detectFaces(InputImage image) => _captureDetector.processImage(image);

  FaceQualityReport evaluateQuality({
    required Face face,
    required int imageWidth,
    required int imageHeight,
    required double sharpness,
    required double brightness,
  }) {
    final faceArea = face.boundingBox.width * face.boundingBox.height;
    final frameArea = imageWidth * imageHeight;
    final sizeRatio = faceArea / frameArea;

    var score = 1.0;
    var message = 'Good quality';

    if (sizeRatio < AppConfig.minFaceSizeRatio) {
      score -= 0.35;
      message = 'Move closer to the camera';
    } else if (sizeRatio > AppConfig.maxFaceSizeRatio) {
      score -= 0.2;
      message = 'Move slightly back';
    }

    if (sharpness < AppConfig.minSharpnessVariance) {
      score -= 0.3;
      message = 'Image too blurry — hold steady';
    }

    if (brightness < AppConfig.minBrightness) {
      score -= 0.25;
      message = 'Lighting too dark';
    } else if (brightness > AppConfig.maxBrightness) {
      score -= 0.2;
      message = 'Lighting too bright';
    }

    final angleY = face.headEulerAngleY?.abs() ?? 0;
    final angleZ = face.headEulerAngleZ?.abs() ?? 0;
    if (angleY > 20 || angleZ > 20) {
      score -= 0.25;
      message = 'Face the camera directly';
    }

    score = score.clamp(0.0, 1.0);

    return FaceQualityReport(
      score: score,
      isAcceptable: score >= AppConfig.minFaceQualityScore,
      sharpness: sharpness,
      brightness: brightness,
      faceSizeRatio: sizeRatio,
      message: message,
    );
  }

  Future<FaceEmbeddingResult> generateFromInputImage(
    InputImage inputImage, {
    required bool requireLiveness,
    LivenessSession? livenessSession,
  }) async {
    final path = inputImage.filePath;
    if (path == null) {
      throw ArgumentError('InputImage must have filePath for FaceNet pipeline');
    }

    final bytes = await File(path).readAsBytes();
    final faces = await _captureDetector.processImage(inputImage);

    if (faces.isEmpty) {
      throw StateError('No face detected');
    }
    if (faces.length > 1) {
      throw StateError('Multiple faces detected — only one person allowed');
    }

    final face = faces.first;
    final rotation = inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg;
    final oriented = _preprocessor.decodeAndOrient(bytes, rotation);
    final width = oriented.width;
    final height = oriented.height;

    final faceCrop = _preprocessor.cropFaceRegion(oriented, face, width, height);
    final sharpness = _preprocessor.estimateSharpness(faceCrop);
    final brightness = _preprocessor.estimateBrightness(faceCrop);

    final quality = evaluateQuality(
      face: face,
      imageWidth: width,
      imageHeight: height,
      sharpness: sharpness,
      brightness: brightness,
    );

    if (!quality.isAcceptable) {
      throw StateError(quality.message);
    }

    if (requireLiveness && livenessSession != null && !livenessSession.isComplete) {
      throw StateError('Complete liveness checks first');
    }

    final tensor = await _preprocessor.preprocessFaceFromBytes(
      imageBytes: bytes,
      face: face,
      imageWidth: width,
      imageHeight: height,
      rotation: rotation,
    );

    final embedding = await _facenet.runInference(tensor);

    return FaceEmbeddingResult(
      embedding: embedding,
      qualityScore: quality.score,
      livenessPassed: livenessSession?.isComplete ?? !requireLiveness,
    );
  }

  Future<void> processLivenessFrame(InputImage image, LivenessSession session) async {
    final faces = await _liveness.detect(image);
    if (faces.isEmpty) return;

    final face = faces.first;
    final meta = image.metadata;
    final w = meta?.size.width ?? 720;
    final h = meta?.size.height ?? 1280;
    final area = face.boundingBox.width * face.boundingBox.height;
    final ratio = area / (w * h);
    var q = 0.65;
    if (ratio >= AppConfig.minFaceSizeRatio && ratio <= AppConfig.maxFaceSizeRatio) {
      q = 0.88;
    } else if (ratio >= AppConfig.minFaceSizeRatio * 0.7) {
      q = 0.72;
    }
    session.update(face, qualityScore: q);
  }

  void dispose() => _captureDetector.close();
}
