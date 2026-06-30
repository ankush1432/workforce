import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:supervisor_app/core/utils/logger.dart';

/// Builds [InputImage] from a [CameraImage] with correct Android/iOS rotation.
InputImage? inputImageFromCameraImage(
  CameraImage image,
  CameraDescription camera, {
  DeviceOrientation? deviceOrientation,
}) {
  try {
    final rotation = _rotationFromCamera(camera, deviceOrientation);
    if (rotation == null) {
      AppLogger.error('Failed to determine camera rotation');
      return null;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      AppLogger.error('Unsupported image format: ${image.format.raw}');
      return null;
    }

    if (image.planes.isEmpty) {
      AppLogger.error('No image planes available');
      return null;
    }

    final plane = image.planes.first;

    // Debug logging for camera metadata
    debugPrint('=== CAMERA METADATA DEBUG ===');
    debugPrint('Image Dimensions: ${image.width}x${image.height}');
    debugPrint('Sensor Orientation: ${camera.sensorOrientation}');
    debugPrint('Lens Direction: ${camera.lensDirection}');
    debugPrint('Device Orientation: $deviceOrientation');
    debugPrint('Calculated Rotation: $rotation');
    debugPrint('Image Format: ${image.format.raw} -> $format');
    debugPrint('Bytes Per Row: ${plane.bytesPerRow}');
    debugPrint('Number of Planes: ${image.planes.length}');
    debugPrint('============================');

    return InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  } catch (e) {
    AppLogger.error('Error creating InputImage from camera: $e');
    return null;
  }
}

InputImageRotation? _rotationFromCamera(
  CameraDescription camera,
  DeviceOrientation? deviceOrientation,
) {
  final sensor = camera.sensorOrientation;

  if (Platform.isIOS) {
    final rotation = InputImageRotationValue.fromRawValue(sensor);
    if (rotation == null) {
      AppLogger.error('Invalid iOS sensor orientation: $sensor');
    }
    return rotation;
  }

  if (Platform.isAndroid) {
    var rotationCompensation = _orientations[deviceOrientation ?? DeviceOrientation.portraitUp];
    if (rotationCompensation == null) {
      AppLogger.error('Unknown device orientation: $deviceOrientation');
      return null;
    }

    // Debug logging for rotation calculation
    debugPrint('=== ROTATION CALCULATION DEBUG ===');
    debugPrint('Sensor Orientation: $sensor');
    debugPrint('Device Orientation: $deviceOrientation');
    debugPrint('Rotation Compensation (base): $rotationCompensation');
    debugPrint('Lens Direction: ${camera.lensDirection}');

    if (camera.lensDirection == CameraLensDirection.front) {
      rotationCompensation = (sensor + rotationCompensation) % 360;
      debugPrint('Front Camera Formula: (sensor + rotationCompensation) % 360 = $rotationCompensation');
    } else {
      rotationCompensation = (sensor - rotationCompensation + 360) % 360;
      debugPrint('Back Camera Formula: (sensor - rotationCompensation + 360) % 360 = $rotationCompensation');
    }
    
    final rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    if (rotation == null) {
      AppLogger.error('Invalid Android rotation compensation: $rotationCompensation');
    }
    debugPrint('Final Rotation: $rotation');
    debugPrint('=================================');
    return rotation;
  }

  // Fallback for web or other platforms
  return InputImageRotation.rotation0deg;
}

const _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

Uint8List _concatenatePlanes(List<Plane> planes) {
  try {
    final buffer = WriteBuffer();
    for (final plane in planes) {
      buffer.putUint8List(plane.bytes);
    }
    return buffer.done().buffer.asUint8List();
  } catch (e) {
    AppLogger.error('Error concatenating image planes: $e');
    rethrow;
  }
}

/// Still capture from [CameraController.takePicture].
InputImage inputImageFromCapture(String path) => InputImage.fromFilePath(path);
