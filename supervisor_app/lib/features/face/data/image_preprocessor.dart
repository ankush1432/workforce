import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:supervisor_app/core/config/app_config.dart';

/// Crops, resizes, and normalizes face regions for FaceNet input.
class ImagePreprocessor {
  const ImagePreprocessor({
    this.inputSize = AppConfig.facenetInputSize,
  });

  final int inputSize;

  img.Image decodeAndOrient(Uint8List imageBytes, InputImageRotation rotation) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) throw StateError('Could not decode image');
    return _applyRotation(decoded, rotation);
  }

  /// Decodes file bytes, crops [face] bounding box (with padding), resizes to model input.
  Future<Float32List> preprocessFaceFromBytes({
    required Uint8List imageBytes,
    required Face face,
    required int imageWidth,
    required int imageHeight,
    InputImageRotation rotation = InputImageRotation.rotation0deg,
  }) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw StateError('Could not decode image');
    }

    final oriented = _applyRotation(decoded, rotation);
    final crop = _cropFace(oriented, face, imageWidth, imageHeight);
    final resized = img.copyResize(
      crop,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    return _toFaceNetInput(resized);
  }

  img.Image _applyRotation(img.Image source, InputImageRotation rotation) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return img.copyRotate(source, angle: 90);
      case InputImageRotation.rotation180deg:
        return img.copyRotate(source, angle: 180);
      case InputImageRotation.rotation270deg:
        return img.copyRotate(source, angle: 270);
      default:
        return source;
    }
  }

  img.Image _cropFace(
    img.Image source,
    Face face,
    int frameWidth,
    int frameHeight,
  ) {
    final box = face.boundingBox;
    final scaleX = source.width / frameWidth;
    final scaleY = source.height / frameHeight;

    var left = (box.left * scaleX).floor();
    var top = (box.top * scaleY).floor();
    var width = (box.width * scaleX).ceil();
    var height = (box.height * scaleY).ceil();

    final pad = (math.max(width, height) * 0.15).round();
    left = math.max(0, left - pad);
    top = math.max(0, top - pad);
    width = math.min(source.width - left, width + pad * 2);
    height = math.min(source.height - top, height + pad * 2);

    // Debug logging for crop coordinates
    debugPrint('=== CROP COORDINATES DEBUG ===');
    debugPrint('Source Image: ${source.width}x${source.height}');
    debugPrint('Frame Dimensions: ${frameWidth}x${frameHeight}');
    debugPrint('Scale X: $scaleX, Scale Y: $scaleY');
    debugPrint('ML Kit Bounding Box: left=${box.left}, top=${box.top}, width=${box.width}, height=${box.height}');
    debugPrint('Scaled Crop (before padding): left=$left, top=$top, width=$width, height=$height');
    debugPrint('Padding: $pad');
    debugPrint('Final Crop: left=$left, top=$top, width=$width, height=$height');
    debugPrint('=============================');

    return img.copyCrop(source, x: left, y: top, width: width, height: height);
  }

  /// FaceNet-style normalization: (pixel - 127.5) / 128.0 per channel.
  Float32List _toFaceNetInput(img.Image image) {
    final buffer = Float32List(inputSize * inputSize * 3);
    var i = 0;
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        buffer[i++] = (pixel.r.toDouble() - 127.5) / 128.0;
        buffer[i++] = (pixel.g.toDouble() - 127.5) / 128.0;
        buffer[i++] = (pixel.b.toDouble() - 127.5) / 128.0;
      }
    }
    return buffer;
  }

  /// Crops face region from [source] for quality metrics (sharpness / brightness).
  img.Image cropFaceRegion(
    img.Image source,
    Face face,
    int frameWidth,
    int frameHeight,
  ) =>
      _cropFace(source, face, frameWidth, frameHeight);

  /// Laplacian variance — higher = sharper. Used for quality gate.
  double estimateSharpness(img.Image faceCrop) {
    final gray = img.grayscale(
      img.copyResize(faceCrop, width: 128, height: 128),
    );
    var sum = 0.0;
    var sumSq = 0.0;
    var count = 0;

    for (var y = 1; y < gray.height - 1; y++) {
      for (var x = 1; x < gray.width - 1; x++) {
        final c = gray.getPixel(x, y).r.toDouble();
        final lap = -4 * c +
            gray.getPixel(x - 1, y).r.toDouble() +
            gray.getPixel(x + 1, y).r.toDouble() +
            gray.getPixel(x, y - 1).r.toDouble() +
            gray.getPixel(x, y + 1).r.toDouble();
        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }

    if (count == 0) return 0;
    final mean = sum / count;
    return (sumSq / count) - (mean * mean);
  }

  /// Mean luminance 0–255 for exposure check.
  double estimateBrightness(img.Image faceCrop) {
    var total = 0.0;
    final pixels = faceCrop.width * faceCrop.height;
    for (var y = 0; y < faceCrop.height; y++) {
      for (var x = 0; x < faceCrop.width; x++) {
        final p = faceCrop.getPixel(x, y);
        total += 0.299 * p.r.toDouble() + 0.587 * p.g.toDouble() + 0.114 * p.b.toDouble();
      }
    }
    return total / pixels;
  }

  /// Saves cropped face image to device storage for inspection/debugging.
  Future<String?> saveCroppedFaceImage(img.Image faceCrop, {String? suffix}) async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'face_crop_${timestamp}${suffix ?? ''}.png';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(img.encodePng(faceCrop));
      
      debugPrint('=== CROPPED FACE IMAGE SAVED ===');
      debugPrint('File Path: $filePath');
      debugPrint('Dimensions: ${faceCrop.width}x${faceCrop.height}');
      debugPrint('File Size: ${await file.length()} bytes');
      debugPrint('================================');
      
      return filePath;
    } catch (e) {
      debugPrint('Error saving cropped face image: $e');
      return null;
    }
  }
}
