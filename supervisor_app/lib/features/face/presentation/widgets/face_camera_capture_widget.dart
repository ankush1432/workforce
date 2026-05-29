import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/config/app_config.dart';
import 'package:supervisor_app/core/permissions/camera_permission_service.dart';
import 'package:supervisor_app/features/face/data/face_embedding_service.dart';
import 'package:supervisor_app/features/face/data/input_image_utils.dart';
import 'package:supervisor_app/features/face/data/liveness_detection_service.dart';
import 'package:supervisor_app/features/face/presentation/widgets/liveness_overlay.dart';

typedef FaceCaptureCallback = void Function(
  List<double> embedding,
  double qualityScore,
);

/// Camera preview with permissions, liveness UI, quality checks, and FaceNet capture.
class FaceCameraCaptureWidget extends ConsumerStatefulWidget {
  const FaceCameraCaptureWidget({
    super.key,
    required this.onCaptured,
    this.requireLiveness = true,
    this.primaryActionLabel = 'Capture',
  });

  final FaceCaptureCallback onCaptured;
  final bool requireLiveness;
  final String primaryActionLabel;

  @override
  ConsumerState<FaceCameraCaptureWidget> createState() =>
      _FaceCameraCaptureWidgetState();
}

class _FaceCameraCaptureWidgetState extends ConsumerState<FaceCameraCaptureWidget> {
  CameraController? _controller;
  LivenessSession? _livenessSession;
  bool _processing = false;
  String? _status;
  DateTime? _statusLockedUntil;
  LivenessStep? _lastStep;
  int _frameIndex = 0;
  bool _permissionDenied = false;
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _initPipeline() async {
    _livenessSession = ref.read(faceEmbeddingServiceProvider).startLivenessSession();

    final permission =
        await ref.read(cameraPermissionServiceProvider).requestCameraAccess();

    if (permission == CameraPermissionStatus.denied) {
      setState(() {
        _permissionDenied = true;
        _status = 'Camera permission is required';
      });
      return;
    }

    if (permission == CameraPermissionStatus.permanentlyDenied) {
      setState(() {
        _permanentlyDenied = true;
        _status = 'Enable camera in system settings';
      });
      return;
    }

    try {
      await ref.read(faceEmbeddingServiceProvider).warmUp();
      await _initCamera();
    } catch (e) {
      final msg = e.toString().contains('facenet') || e.toString().contains('asset')
          ? 'Face model missing. Add assets/models/facenet.tflite'
          : 'Init failed: $e';
      _setStatus(msg);
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final lens = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      lens,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup:
          Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    await controller.initialize();

    if (!mounted) {
      await controller.dispose();
      return;
    }

    if (widget.requireLiveness) {
      await controller.startImageStream(_onCameraImage);
    }

    setState(() {
      _controller = controller;
      _status = widget.requireLiveness
          ? _livenessSession!.instruction
          : 'Align face and capture';
    });
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (_processing || _controller == null) return;

    _frameIndex++;
    if (_frameIndex % AppConfig.livenessFrameSkip != 0) return;

    final input = inputImageFromCameraImage(
      image,
      _controller!.description,
      deviceOrientation: _controller!.value.deviceOrientation,
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
      }

      if (mounted && !_statusLocked) {
        setState(() => _status = session.instruction);
      }
    } catch (_) {}
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

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

      widget.onCaptured(result.embedding, result.qualityScore);
    } catch (e) {
      _setStatus('$e', lock: const Duration(seconds: 3));
      if (_controller != null &&
          _controller!.value.isInitialized &&
          widget.requireLiveness &&
          !_controller!.value.isStreamingImages) {
        await _controller!.startImageStream(_onCameraImage);
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
    final initialized = _controller?.value.isInitialized == true;

    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (initialized)
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
              ],
            ),
          ),
        ),
        if (_status != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              _status!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _processing || !initialized ? null : _capture,
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
