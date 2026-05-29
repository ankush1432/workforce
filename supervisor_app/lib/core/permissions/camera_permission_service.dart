import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final cameraPermissionServiceProvider = Provider<CameraPermissionService>(
  (ref) => CameraPermissionService(),
);

/// Handles camera (and storage for gallery fallback) permissions on Android/iOS.
class CameraPermissionService {
  Future<CameraPermissionStatus> requestCameraAccess() async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      return CameraPermissionStatus.granted;
    }

    if (status.isPermanentlyDenied) {
      return CameraPermissionStatus.permanentlyDenied;
    }

    status = await Permission.camera.request();
    if (status.isGranted) return CameraPermissionStatus.granted;
    if (status.isPermanentlyDenied) {
      return CameraPermissionStatus.permanentlyDenied;
    }
    return CameraPermissionStatus.denied;
  }

  Future<bool> openSettings() => openAppSettings();
}

enum CameraPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}
