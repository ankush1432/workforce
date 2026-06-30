import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:supervisor_app/core/config/app_config.dart';

final livenessDetectionServiceProvider = Provider<LivenessDetectionService>((ref) {
  final service = LivenessDetectionService();
  ref.onDispose(service.dispose);
  return service;
});

/// Passive + active liveness checks using ML Kit face classifications and pose.
class LivenessDetectionService {
  LivenessDetectionService()
      : _detector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.fast,
            enableClassification: true,
            enableTracking: true,
            minFaceSize: 0.12,
          ),
        );

  final FaceDetector _detector;

  LivenessSession startSession() => LivenessSession();

  Future<List<Face>> detect(InputImage image) => _detector.processImage(image);

  void dispose() => _detector.close();
}

enum LivenessStep {
  alignFace,
  blink,
  holdStill,
  completed,
  faceVerified,
}

class LivenessSession {
  LivenessStep step = LivenessStep.alignFace;
  bool _sawEyesClosed = false;
  int _stableFrames = 0;
  int _blinkFrames = 0;
  int _alignedFrames = 0;
  
  // Face locking: store the verified face image when liveness completes
  String? _lockedFaceImagePath;
  List<double>? _lockedFaceEmbedding;
  double? _lockedFaceQuality;

  static const int requiredStableFrames = 5;
  static const int requiredBlinkFrames = 1;
  static const int requiredAlignedFrames = 3;

  String get instruction => switch (step) {
        LivenessStep.alignFace => 'Center your face in the circle',
        LivenessStep.blink => 'Blink slowly once',
        LivenessStep.holdStill => 'Hold still…',
        LivenessStep.completed => 'Face Verified',
        LivenessStep.faceVerified => 'Processing Attendance...',
      };

  double get progress => switch (step) {
        LivenessStep.alignFace => 0.2,
        LivenessStep.blink => 0.5,
        LivenessStep.holdStill => 0.8,
        LivenessStep.completed => 1.0,
        LivenessStep.faceVerified => 1.0,
      };

  bool get isComplete => step == LivenessStep.completed || step == LivenessStep.faceVerified;

  // Face locking getters
  bool get hasLockedFace => _lockedFaceImagePath != null;
  String? get lockedFaceImagePath => _lockedFaceImagePath;
  List<double>? get lockedFaceEmbedding => _lockedFaceEmbedding;
  double? get lockedFaceQuality => _lockedFaceQuality;

  void update(Face face, {required double qualityScore}) {
    if (step == LivenessStep.completed || step == LivenessStep.faceVerified) return;

    if (!_isFaceAligned(face)) {
      _stableFrames = 0;
      _alignedFrames = 0;
      step = LivenessStep.alignFace;
      return;
    }

    if (step == LivenessStep.alignFace) {
      _alignedFrames++;
      if (_alignedFrames >= requiredAlignedFrames &&
          qualityScore >= AppConfig.minFaceQualityScore) {
        step = LivenessStep.blink;
        _blinkFrames = 0;
        _sawEyesClosed = false;
      }
      return;
    }

    if (step == LivenessStep.blink) {
      _trackBlink(face);
      return;
    }

    if (step == LivenessStep.holdStill) {
      _stableFrames++;
      if (_stableFrames >= requiredStableFrames) {
        step = LivenessStep.completed;
      }
    }
  }

  void _trackBlink(Face face) {
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;

    if (left != null && right != null) {
      final eyesClosed = left < 0.4 && right < 0.4;
      final eyesOpen = left > 0.55 && right > 0.55;

      if (eyesClosed) _sawEyesClosed = true;
      if (_sawEyesClosed && eyesOpen) {
        _blinkFrames++;
        _sawEyesClosed = false;
      }

      if (_blinkFrames >= requiredBlinkFrames) {
        step = LivenessStep.holdStill;
        _stableFrames = 0;
      }
    } else {
      // Classification unavailable on some devices — advance after brief hold.
      _blinkFrames++;
      if (_blinkFrames >= 8) {
        step = LivenessStep.holdStill;
        _stableFrames = 0;
      }
    }
  }

  bool _isFaceAligned(Face face) {
    final angleY = face.headEulerAngleY;
    final angleZ = face.headEulerAngleZ;
    if (angleY != null && angleY.abs() > 25) return false;
    if (angleZ != null && angleZ.abs() > 25) return false;
    return true;
  }

  void reset() {
    step = LivenessStep.alignFace;
    _sawEyesClosed = false;
    _stableFrames = 0;
    _blinkFrames = 0;
    _alignedFrames = 0;
    // Clear locked face data on reset
    _lockedFaceImagePath = null;
    _lockedFaceEmbedding = null;
    _lockedFaceQuality = null;
  }

  void markFaceVerified() {
    step = LivenessStep.faceVerified;
  }

  /// Lock the verified face data to avoid unnecessary second face detection
  void lockFace({
    required String imagePath,
    required List<double> embedding,
    required double quality,
  }) {
    _lockedFaceImagePath = imagePath;
    _lockedFaceEmbedding = embedding;
    _lockedFaceQuality = quality;
  }
}
