import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Builds [InputImage] from a [CameraImage] with correct Android/iOS rotation.
InputImage? inputImageFromCameraImage(
  CameraImage image,
  CameraDescription camera, {
  DeviceOrientation? deviceOrientation,
}) {
  final rotation = _rotationFromCamera(camera, deviceOrientation);
  if (rotation == null) return null;

  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) return null;

  final plane = image.planes.first;

  return InputImage.fromBytes(
    bytes: _concatenatePlanes(image.planes),
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: plane.bytesPerRow,
    ),
  );
}

InputImageRotation? _rotationFromCamera(
  CameraDescription camera,
  DeviceOrientation? deviceOrientation,
) {
  final sensor = camera.sensorOrientation;

  if (Platform.isIOS) {
    return InputImageRotationValue.fromRawValue(sensor);
  }

  if (Platform.isAndroid) {
    var rotationCompensation = _orientations[deviceOrientation ?? DeviceOrientation.portraitUp];
    if (rotationCompensation == null) return null;

    if (camera.lensDirection == CameraLensDirection.front) {
      rotationCompensation = (sensor + rotationCompensation) % 360;
    } else {
      rotationCompensation = (sensor - rotationCompensation + 360) % 360;
    }
    return InputImageRotationValue.fromRawValue(rotationCompensation);
  }

  return InputImageRotation.rotation0deg;
}

const _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

Uint8List _concatenatePlanes(List<Plane> planes) {
  final buffer = WriteBuffer();
  for (final plane in planes) {
    buffer.putUint8List(plane.bytes);
  }
  return buffer.done().buffer.asUint8List();
}

/// Still capture from [CameraController.takePicture].
InputImage inputImageFromCapture(String path) => InputImage.fromFilePath(path);
