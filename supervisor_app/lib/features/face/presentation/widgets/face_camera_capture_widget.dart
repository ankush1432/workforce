import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:supervisor_app/core/config/app_config.dart';
import 'package:supervisor_app/core/permissions/camera_permission_service.dart';
import 'package:supervisor_app/features/face/data/face_embedding_service.dart';
import 'package:supervisor_app/features/face/data/input_image_utils.dart';
import 'package:supervisor_app/features/face/data/liveness_detection_service.dart';
import 'package:supervisor_app/features/face/presentation/widgets/liveness_overlay.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';

/// Helper function to convert image to base64 in isolate
String? _convertImageToBase64(String imagePath) {
  try {
    final imageBytes = File(imagePath).readAsBytesSync();
    return base64Encode(imageBytes);
  } catch (e) {
    debugPrint('Error converting image to base64 in isolate: $e');
    return null;
  }
}

typedef FaceCaptureCallback = Future<void> Function(
    List<double> embedding,
    double qualityScore,
    String? faceImage,
    );

typedef FaceCaptureCompleteCallback = void Function();
typedef FaceCaptureResetCallback = void Function();

/// Camera preview with permissions, liveness UI, quality checks, and FaceNet capture.
class FaceCameraCaptureWidget extends ConsumerStatefulWidget {
  const FaceCameraCaptureWidget({
    super.key,
    required this.onCaptured,
    this.requireLiveness = true,
    this.primaryActionLabel = 'Capture',
    this.enableAutoCapture = false,
    this.onCaptureError,
    this.onCaptureComplete,
    this.onRequestReset,
  });

  final FaceCaptureCallback onCaptured;
  final bool requireLiveness;
  final String primaryActionLabel;
  final bool enableAutoCapture;
  final VoidCallback? onCaptureError;
  final FaceCaptureCompleteCallback? onCaptureComplete;
  final FaceCaptureResetCallback? onRequestReset;



  @override
  ConsumerState<FaceCameraCaptureWidget> createState() =>
      _FaceCameraCaptureWidgetState();
}

class _FaceCameraCaptureWidgetState extends ConsumerState<FaceCameraCaptureWidget>  with WidgetsBindingObserver{
  CameraController? _controller;
  LivenessSession? _livenessSession;
  bool _processing = false;
  String? _status;
  DateTime? _statusLockedUntil;
  LivenessStep? _lastStep;
  int _frameIndex = 0;
  bool _permissionDenied = false;
  bool _permanentlyDenied = false;
  bool _autoCaptureStarted = false;
  String? _errorMessage;
  String? _lockedFaceImageBase64;

  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _switchingCamera = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPipeline());
  }

  void _setStatus(String message, {Duration lock = Duration.zero}) {
    if (!mounted) return;
    setState(() {
      _status = message;
      _statusLockedUntil =
      lock == Duration.zero ? null : DateTime.now().add(lock);
    });
  }

  bool get _statusLocked =>
      _statusLockedUntil != null && DateTime.now().isBefore(_statusLockedUntil!);

  void resetState() {
    debugPrint('Resetting camera capture state');
    setState(() {
      _processing = false;
      _autoCaptureStarted = false;
      _statusLockedUntil = null;
      _errorMessage = null;
      _lockedFaceImageBase64 = null;
      _status = null;
    });
    
    // Reset liveness session
    _livenessSession?.reset();
    _lastStep = null;
    
    // Restart camera stream if needed
    if (_controller != null &&
        _controller!.value.isInitialized &&
        widget.requireLiveness &&
        !_controller!.value.isStreamingImages) {
      _controller!.startImageStream(_onCameraImage);
    }
  }

  Future<void> _initPipeline() async {
    _livenessSession = ref.read(faceEmbeddingServiceProvider).startLivenessSession();
    final l10n = AppLocalizations.of(context)!;

    final permission =
    await ref.read(cameraPermissionServiceProvider).requestCameraAccess();

    if (permission == CameraPermissionStatus.denied) {
      setState(() {
        _permissionDenied = true;
        _status = l10n.cameraPermissionRequired;
      });
      return;
    }

    if (permission == CameraPermissionStatus.permanentlyDenied) {
      setState(() {
        _permanentlyDenied = true;
        _status = l10n.enableCameraInSystemSettings;
      });
      return;
    }

    try {
      await ref.read(faceEmbeddingServiceProvider).warmUp();
      await _initCamera();
    } catch (e) {
      final msg = e.toString().contains('facenet') || e.toString().contains('asset')
          ? l10n.faceModelMissing
          : l10n.initFailed(e.toString());
      _setStatus(msg);
    }
  }
  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    // Front camera default
    _cameraIndex = _cameras.indexWhere(
          (e) => e.lensDirection == CameraLensDirection.front,
    );

    if (_cameraIndex == -1) {
      _cameraIndex = 0;
    }

    await _initializeCamera(_cameraIndex);
  }

  Future<void> _initializeCamera(int index) async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_cameras.isEmpty || index >= _cameras.length) {
      _setStatus(l10n.noCameraAvailable);
      return;
    }

    final camera = _cameras[index];
    debugPrint(
      "Selected Camera: ${camera.name} - ${camera.lensDirection}",
    );

    try {
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();

      // Enable wake lock to prevent screen locking during face operations
      await WakelockPlus.enable();

      try {
        await controller.setFlashMode(FlashMode.off);
      } catch (_) {}

      if (!mounted) {
        await controller.dispose();
        return;
      }

      if (widget.requireLiveness) {
        await controller.startImageStream(_onCameraImage);
      }

      if (mounted) {
        setState(() {
          _controller = controller;
          _status = widget.requireLiveness
              ? (_livenessSession?.instruction ?? l10n.centerYourFace)
              : l10n.alignFace;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      _setStatus(l10n.cameraInitializationFailed(e.toString()));
    }
  }

  Future<void> _changeCamera(int newIndex) async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_switchingCamera) return;
    if (newIndex < 0 || newIndex >= _cameras.length) return;

    final oldController = _controller;

    setState(() {
      _switchingCamera = true;
      _controller = null;
    });

    await Future.delayed(Duration.zero);

    try {
      if (oldController != null) {
        try {
          if (oldController.value.isStreamingImages) {
            await oldController.stopImageStream();
          }
        } catch (e) {
          debugPrint('Error stopping image stream during camera switch: $e');
        }

        try {
          await oldController.dispose();
        } catch (e) {
          debugPrint('Error disposing old camera: $e');
        }
      }

      _cameraIndex = newIndex;

      await _initializeCamera(_cameraIndex);
    } catch (e) {
      debugPrint('Change Camera Error: $e');
      _setStatus(l10n.failedToSwitchCamera);
    } finally {
      if (mounted) {
        setState(() {
          _switchingCamera = false;
        });
      }
    }
  }
  Future<void> _onCameraImage(CameraImage image) async {
    final controller = _controller;

    // Stop processing if auto-capture has started or processing is in progress
    if (_processing ||
        _autoCaptureStarted ||
        controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    _frameIndex++;
    if (_frameIndex % AppConfig.livenessFrameSkip != 0) return;

    final input = inputImageFromCameraImage(
      image,
      controller.description,
      deviceOrientation: controller.value.deviceOrientation,
    );
    if (input == null || _livenessSession == null) return;

    try {
      await ref.read(faceEmbeddingServiceProvider).processLivenessFrame(
        input,
        _livenessSession!,
      );

      final session = _livenessSession!;
      if (_lastStep != session.step) {
        _lastStep = session.step;
        debugPrint(
            'Liveness changed: $_lastStep -> ${session.step}'
        );
        // Lock face when liveness completes to avoid second face detection
        if (session.step == LivenessStep.completed && !session.hasLockedFace) {
          await _lockFaceOnLivenessComplete();
        }

        // Trigger auto-capture when liveness completes
        if (widget.enableAutoCapture &&
            session.step == LivenessStep.completed &&
            !_autoCaptureStarted) {
          _autoCaptureStarted = true;
          _triggerAutoCapture();
        }
      }

      if (mounted && !_statusLocked) {
        setState(() => _status = session.instruction);
      }
      debugPrint(
          'Instruction=${session.instruction} '
              'Step=${session.step} '
              'Complete=${session.isComplete}'
      );
    } catch (e) {
      debugPrint('Error processing camera frame: $e');
    }
  }

  Future<void> _lockFaceOnLivenessComplete() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _livenessSession == null) return;

    try {
      // Stop image stream temporarily to capture a clean frame
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }

      // Capture the current frame
      final file = await controller.takePicture();
      final inputImage = inputImageFromCapture(file.path);

      // Generate embedding from the captured frame
      final result = await ref.read(faceEmbeddingServiceProvider).generateEmbeddingWithQuality(
        inputImage,
        requireLiveness: false, // Liveness already verified
        livenessSession: _livenessSession,
      );

      // Convert image to base64 in isolate to prevent blocking main thread
      String? faceImageBase64;
      try {
        faceImageBase64 = await compute(_convertImageToBase64, file.path);
      } catch (e) {
        debugPrint('Error converting image to base64: $e');
        faceImageBase64 = null;
      }

      // Lock the face data in the session
      _livenessSession!.lockFace(
        imagePath: file.path,
        embedding: result.embedding,
        quality: result.qualityScore,
      );

      // Store the base64 image for later use
      _lockedFaceImageBase64 = faceImageBase64;

      // Restart image stream
      if (mounted && controller.value.isInitialized && widget.requireLiveness) {
        await controller.startImageStream(_onCameraImage);
      }
    } catch (e) {
      debugPrint('Error locking face: $e');
      // If locking fails, restart image stream and continue
      // Don't show error to user - they can still try manual capture
      if (mounted &&
          controller.value.isInitialized &&
          widget.requireLiveness &&
          !controller.value.isStreamingImages) {
        await controller.startImageStream(_onCameraImage);
      }
    }
  }

  Future<void> _triggerAutoCapture() async {
    // Wait 750ms before capturing after liveness completes
    debugPrint('AUTO CAPTURE STARTED');
    
    // Stop image stream to prevent further processing
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
      debugPrint('Camera stream stopped for auto-capture');
    }
    
    await Future<void>.delayed(const Duration(milliseconds: 750));
    
    if (mounted && _livenessSession != null) {
      // Show "Face Verified" status
      _livenessSession!.markFaceVerified();
      setState(() => _status = 'Face Verified');
      
      // Wait a moment for UI update, then process with locked face
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _processWithLockedFace();
      }
    }
  }

  Future<void> _capture() async {
    if (_processing ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    if (widget.requireLiveness && !(_livenessSession?.isComplete ?? false)) {
      _setStatus(
        'Complete liveness first: ${_livenessSession?.instruction ?? "center your face"}',
        lock: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _processing = true;
      _statusLockedUntil = null;
      _errorMessage = null;
      _status = 'Processing face…';
    });

    try {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      final file = await _controller!.takePicture();
      final inputImage = inputImageFromCapture(file.path);

      final result =
      await ref.read(faceEmbeddingServiceProvider).generateEmbeddingWithQuality(
        inputImage,
        requireLiveness: widget.requireLiveness,
        livenessSession: _livenessSession,
      );

      // Convert image to base64 in isolate to prevent blocking main thread
      String? faceImageBase64;
      try {
        faceImageBase64 = await compute(_convertImageToBase64, file.path);
      } catch (e) {
        // If image conversion fails, continue without it
        faceImageBase64 = null;
      }

      widget.onCaptured(result.embedding, result.qualityScore, faceImageBase64);
    } catch (e) {
      debugPrint('Capture error: $e');
      String userErrorMessage = _getUserFriendlyErrorMessage(e);
      setState(() {
        _errorMessage = userErrorMessage;
        _processing = false;
      });
      
      // Reset all state for retry
      resetState();
      
      // Notify parent of capture error
      widget.onCaptureError?.call();
    } finally {
      // Always reset processing state, even on error
      if (mounted) {
        setState(() => _processing = false);

        if (widget.requireLiveness &&
            _controller != null &&
            _controller!.value.isInitialized &&
            !_controller!.value.isStreamingImages) {
          await _controller!.startImageStream(
            _onCameraImage,
          );
        }
      }
    }
  }

  Future<void> _processWithLockedFace() async {
    debugPrint('PROCESS STARTED - _processWithLockedFace');
    
    if (_livenessSession == null || !_livenessSession!.hasLockedFace) {
      // Fallback to regular capture if face is not locked
      await _capture();
      return;
    }

    setState(() {
      _processing = true;
      _statusLockedUntil = null;
      _errorMessage = null;
      _status = 'Processing...';
    });

    try {
      // Stop camera stream before processing
      if (_controller != null && _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      // Reuse the locked face data - no second face detection needed
      final embedding = _livenessSession!.lockedFaceEmbedding!;
      final quality = _livenessSession!.lockedFaceQuality!;
      final faceImage = _lockedFaceImageBase64;

      // Directly use the locked data without running face detection again
      debugPrint('Calling widget.onCaptured...');
      await widget.onCaptured(embedding, quality, faceImage);
      debugPrint('PROCESS FINISHED - widget.onCaptured completed');
      
      // Notify parent that capture is complete (for state reset)
      widget.onCaptureComplete?.call();
    } catch (e) {
      debugPrint('PROCESS ERROR - _processWithLockedFace: $e');
      // Provide user-friendly error message for all error cases
      String userErrorMessage = _getUserFriendlyErrorMessage(e);
      
      _autoCaptureStarted = false;
      setState(() {
        _errorMessage = userErrorMessage;
        _processing = false;
      });
      
      if (widget.enableAutoCapture) {
        // Reset liveness session for retry
        _livenessSession?.reset();
        _autoCaptureStarted = false;
        _lastStep = null;
      }
      
      // Restart camera stream on error for retry
      if (_controller != null &&
          _controller!.value.isInitialized &&
          widget.requireLiveness &&
          !_controller!.value.isStreamingImages) {
        await _controller!.startImageStream(_onCameraImage);
      }
      
      // Notify parent that capture is complete (for state reset)
      widget.onCaptureComplete?.call();
    } finally {
      // Always reset processing state, even on error
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('face not matched') || 
        errorStr.contains('face verification failed')) {
      return 'Face not recognized. Please try again.';
    }
    if (errorStr.contains('already checked in')) {
      return 'Employee already checked in today.';
    }
    if (errorStr.contains('already checked out')) {
      return 'Employee already checked out today.';
    }
    if (errorStr.contains('must check in first') || 
        errorStr.contains('must check in before check out')) {
      return 'Employee must check in before check out.';
    }
    if (errorStr.contains('no internet') || 
        errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return 'No internet connection.';
    }
    if (errorStr.contains('timeout') || 
        errorStr.contains('timed out')) {
      return 'Request timed out. Please try again.';
    }
    if (errorStr.contains('server error') || 
        errorStr.contains('internal server error') ||
        errorStr.contains('500') ||
        errorStr.contains('502') ||
        errorStr.contains('503')) {
      return 'Server error. Please try again later.';
    }
    
    // Default error message
    return 'An error occurred. Please try again.';
  }

  void _retryCapture() {
    setState(() {
      _errorMessage = null;
      _autoCaptureStarted = false;
      _processing = false;
      _lockedFaceImageBase64 = null;
    });
    _livenessSession?.reset();
    _lastStep = null;
    
    // Restart camera stream for retry
    if (_controller != null &&
        _controller!.value.isInitialized &&
        widget.requireLiveness &&
        !_controller!.value.isStreamingImages) {
      _controller!.startImageStream(_onCameraImage);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    final controller = _controller;
    _controller = null;
    
    if (controller != null) {
      try {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
      } catch (e) {
        debugPrint('Error stopping image stream: $e');
      }
      
      try {
        await controller.dispose();
      } catch (e) {
        debugPrint('Error disposing camera: $e');
      }
    }

    // Disable wake lock when camera is disposed
    try {
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint('Error disabling wake lock: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permanentlyDenied) {
      return _PermissionFallback(
        message: _status ?? 'Camera permission denied',
        showSettings: true,
        onRetry: () => ref.read(cameraPermissionServiceProvider).openSettings(),
      );
    }

    if (_permissionDenied) {
      return _PermissionFallback(
        message: _status ?? 'Camera permission denied',
        onRetry: _initPipeline,
      );
    }

    final session = _livenessSession;
    final initialized =
        _controller != null &&
            _controller!.value.isInitialized;

    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_controller != null &&
                    _controller!.value.isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: 1 / _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                  )
                else
                  const Center(child: CircularProgressIndicator()),
                if (widget.requireLiveness && session != null && initialized)
                  LivenessOverlay(session: session),
                if (_errorMessage != null)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Material(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _retryCapture,
                              child: Text(AppLocalizations.of(context)!.retry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                getSettingToolbar()


              ],
            ),
          ),
        ),

        // Hide manual button when auto-capture is enabled
        if (!widget.enableAutoCapture)
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed:  _processing ||
                  _switchingCamera  || !initialized ? null : _capture,
              child: _processing
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(widget.primaryActionLabel),
            ),
          ),
      ],
    );
  }
  Future<void> _switchCamera() async {
    final currentLens =
        _controller?.description.lensDirection;

    int newIndex;

    if (currentLens == CameraLensDirection.front) {
      newIndex = _cameras.indexWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
      );
    } else {
      newIndex = _cameras.indexWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
      );
    }

    if (newIndex == -1) return;

    await _changeCamera(newIndex);
  }



 Widget getSettingToolbar() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(30),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.cameraswitch,
            color: Colors.white,
          ),
          onPressed: _switchCamera,
        ),
      ),
    );
 }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (_controller == null || !_controller!.value.isInitialized) {
          _initializeCamera(_cameraIndex);
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Release camera when app goes to background to save resources
        _disposeCamera();
        break;
    }
  }
}

class _PermissionFallback extends StatelessWidget {
  const _PermissionFallback({
    required this.message,
    this.onRetry,
    this.showSettings = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_photography_outlined,
                size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (onRetry != null)
              FilledButton(
                onPressed: onRetry,
                child: Text(showSettings ? 'Open Settings' : 'Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
