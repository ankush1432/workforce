import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/features/employees/presentation/employees_provider.dart';
import 'package:supervisor_app/features/face/data/face_repository.dart';
import 'package:supervisor_app/features/face/presentation/widgets/face_camera_capture_widget.dart';

class FaceRegisterPage extends ConsumerStatefulWidget {
  const FaceRegisterPage({
    super.key,
    required this.employeeId,
    this.returnTo,
  });

  final int employeeId;
  final String? returnTo;

  @override
  ConsumerState<FaceRegisterPage> createState() => _FaceRegisterPageState();
}

class _FaceRegisterPageState extends ConsumerState<FaceRegisterPage>
    with SingleTickerProviderStateMixin {
  bool _submitting = false;
  bool _success = false;
  String? _error;
  late final AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _navigateAfterSuccess() {
    final id = widget.employeeId;
    switch (widget.returnTo) {
      case 'check_in':
        context.go('/employees/$id/verify-face?action=check_in');
      case 'check_out':
        context.go('/employees/$id/verify-face?action=check_out');
      case 'home':
        context.go('/dashboard');
      default:
        context.go('/employees/$id');
    }
  }

  Future<void> _onCaptured(List<double> embedding, double qualityScore) async {
    if (_submitting || _success) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(faceRepositoryProvider).registerFace(
            employeeId: widget.employeeId,
            embedding: embedding,
            qualityScore: qualityScore,
          );

      await refreshEmployeesCache(ref);

      if (!mounted) return;

      setState(() {
        _submitting = false;
        _success = true;
      });

      await _successController.forward(from: 0);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (mounted) _navigateAfterSuccess();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hint = switch (widget.returnTo) {
      'check_in' => 'Registration will continue to check-in automatically.',
      'check_out' => 'Registration will continue to check-out automatically.',
      _ => 'Position the face inside the oval guide.',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Face'),
        leading: _submitting || _success
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/employees/${widget.employeeId}'),
              ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FaceCameraCaptureWidget(
                  requireLiveness: true,
                  primaryActionLabel: 'Capture & Register',
                  onCaptured: _submitting || _success ? (_, __) {} : _onCaptured,
                ),
              ),
            ],
          ),
          if (_submitting)
            ColoredBox(
              color: theme.colorScheme.scrim.withValues(alpha: 0.35),
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (_success)
            ColoredBox(
              color: theme.colorScheme.scrim.withValues(alpha: 0.45),
              child: Center(
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _successController,
                    curve: Curves.elasticOut,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 72, color: theme.colorScheme.primary),
                          const SizedBox(height: 12),
                          Text(
                            'Face Registered',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_error != null && !_submitting && !_success)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Material(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(child: Text(_error!)),
                      TextButton(
                        onPressed: () => setState(() => _error = null),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
