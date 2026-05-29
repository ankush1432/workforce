import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/features/face/presentation/providers/face_capture_state_provider.dart';
import 'package:supervisor_app/features/face/presentation/widgets/face_camera_capture_widget.dart';

class FaceScanPage extends ConsumerStatefulWidget {
  const FaceScanPage({super.key});

  @override
  ConsumerState<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends ConsumerState<FaceScanPage> {
  List<double>? _lastEmbedding;
  double? _quality;
  String? _status;

  void _onCaptured(List<double> embedding, double qualityScore) {
    ref.read(lastFaceEmbeddingProvider.notifier).state = (
      embedding: embedding,
      quality: qualityScore,
    );
    setState(() {
      _lastEmbedding = embedding;
      _quality = qualityScore;
      _status = 'Face captured (${embedding.length}-D). Proceed to check-in.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Scan')),
      body: Column(
        children: [
          Expanded(
            child: FaceCameraCaptureWidget(
              requireLiveness: true,
              primaryActionLabel: 'Scan Face',
              onCaptured: _onCaptured,
            ),
          ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_status!, textAlign: TextAlign.center),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/check-in'),
                    child: const Text('Check-In'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _lastEmbedding == null ? null : () => context.go('/check-in'),
                    child: const Text('Use Scan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
