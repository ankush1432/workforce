import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/core/error/app_exception.dart';
import 'package:supervisor_app/core/error/error_handler.dart';
import 'package:supervisor_app/core/utils/dialog_helper.dart';
import 'package:supervisor_app/features/employees/presentation/employees_provider.dart';
import 'package:supervisor_app/features/face/data/face_repository.dart';
import 'package:supervisor_app/features/face/presentation/widgets/face_camera_capture_widget.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';

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
  bool _disposed = false;
  bool _dialogShowing = false;
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
    _disposed = true;
    _successController.dispose();
    super.dispose();
  }

  void _navigateAfterSuccess() {
    switch (widget.returnTo) {
      case 'home':
        context.go('/dashboard');
      default:
        context.go('/employees');
    }
  }

  void _onCaptureComplete() {
    debugPrint('CAPTURE COMPLETE - FaceRegisterPage');
    setState(() => _submitting = false);
  }

  Future<void> _onCaptured(
      List<double> embedding, double qualityScore, String? faceImage) async {
    if (_submitting || _success || _disposed) return;

    debugPrint('Face Registration Started - employeeId: ${widget.employeeId}');
    setState(() => _submitting = true);

    try {
      debugPrint('Face Detected - qualityScore: $qualityScore');
      debugPrint('Embedding Generated - length: ${embedding.length}');
      
      // Add timeout protection
      debugPrint('API Request Started - registerFace');
      await ref.read(faceRepositoryProvider).registerFace(
            employeeId: widget.employeeId,
            embedding: embedding,
            qualityScore: qualityScore,
            faceImage: faceImage,
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Face registration timed out');
            },
          );
      debugPrint('API Response Received - registerFace');

      await refreshEmployeesCache(ref);

      if (_disposed) return;
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _success = true;
      });

      debugPrint('Registration Success - employeeId: ${widget.employeeId}');
      await _successController.forward(from: 0);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (_disposed) return;
      if (mounted) {
        _showSuccessDialog();
      }
    } on DioException catch (e) {
      debugPrint('Registration Failed - DioException: ${e.message}');
      if (!_disposed && mounted) {
        setState(() {
          _submitting = false;
        });
      }
      if (mounted) {
        final errorMessage = ErrorHandler.extractBackendMessage(e);
        
        // Handle duplicate face error with employee details
        if (e.response?.data is Map) {
          final data = e.response!.data as Map;
          final type = data['type']?.toString();
          
          if (type == 'duplicate_face') {
            final message = data['message']?.toString();
            final employeeName = data['employee_name']?.toString();
            final similarityValue = data['similarity'];
            
            // Defensive null checks for similarity conversion
            String? similarity;
            if (similarityValue != null) {
              try {
                final numValue = similarityValue is num ? similarityValue : double.tryParse(similarityValue.toString());
                if (numValue != null) {
                  similarity = '${(numValue.toDouble() * 100).toStringAsFixed(1)}%';
                }
              } catch (e) {
                debugPrint('Error converting similarity value: $e');
              }
            }
            
            _showDuplicateFaceDialog(
              message ?? 'This face is already registered to another employee',
              employeeName,
              similarity,
            );
          } else {
            _showErrorDialog(errorMessage);
          }
        } else {
          _showErrorDialog(errorMessage);
        }
      }
    } on TimeoutException catch (e) {
      debugPrint('Registration Failed - TimeoutException: $e');
      if (_disposed) return;
      if (mounted) {
        _showErrorDialog('Request timed out. Please try again.');
      }
    } on SocketException catch (e) {
      debugPrint('Registration Failed - SocketException: $e');
      if (_disposed) return;
      if (mounted) {
        _showErrorDialog('No internet connection. Please check your network and try again.');
      }
    } on AppException catch (e) {
      debugPrint('Registration Failed - AppException: ${e.message}');
      if (_disposed) return;
      if (mounted) {
        setState(() {
          _submitting = false;
        });
        _showErrorDialog(e.message);
      }
    } on Exception catch (e) {
      debugPrint('Registration Failed - Exception: $e');
      if (_disposed) return;
      if (mounted) {
        _showErrorDialog('An error occurred. Please try again.');
      }
    } finally {
      debugPrint('Registration cleanup completed');
      // Always reset submitting state, even on error
      if (!_disposed && mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    debugPrint('ERROR DIALOG SHOWN - FaceRegisterPage');
    if (_dialogShowing) return;
    
    setState(() => _dialogShowing = true);
    
    DialogHelper.showError(
      context,
      title: 'Registration Failed',
      message: message,
      buttonText: 'OK',
    ).then((_) {
      debugPrint('ERROR DIALOG CLOSED - FaceRegisterPage');
      if (mounted) {
        setState(() => _dialogShowing = false);
        context.go('/dashboard');
      }
    });
  }

  void _showDuplicateFaceDialog(String message, String? employeeName, String? similarity) {
    debugPrint('DUPLICATE FACE DIALOG SHOWN - FaceRegisterPage');
    if (_dialogShowing) return;
    
    setState(() => _dialogShowing = true);
    
    String fullMessage = message;
    if (employeeName != null && employeeName.isNotEmpty) {
      fullMessage += '\n\nEmployee: $employeeName';
    }
    if (similarity != null && similarity.isNotEmpty) {
      fullMessage += '\nSimilarity: $similarity';
    }
    
    DialogHelper.showError(
      context,
      title: 'Duplicate Face Detected',
      message: fullMessage,
      buttonText: 'OK',
    ).then((_) {
      debugPrint('DUPLICATE FACE DIALOG CLOSED - FaceRegisterPage');
      if (mounted) {
        setState(() => _dialogShowing = false);
        context.go('/dashboard');
      }
    });
  }

  void _showSuccessDialog() {
    if (_dialogShowing) return;
    
    setState(() => _dialogShowing = true);
    
    DialogHelper.showSuccess(
      context,
      title: 'Registration Successful',
      message: 'Face has been registered successfully.',
      buttonText: 'OK',
    ).then((_) {
      if (mounted) {
        setState(() => _dialogShowing = false);
        _navigateAfterSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hint = switch (widget.returnTo) {
      'check_in' => l10n.registrationWillContinueToCheckIn,
      'check_out' => l10n.registrationWillContinueToCheckOut,
      _ => l10n.positionFaceInsideCircle,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerFace),
        leading: _submitting || _success || _disposed
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/employees'),
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
                  primaryActionLabel: l10n.captureAndRegister,
                  enableAutoCapture: true,
                  onCaptured: _submitting || _success || _disposed
                      ? (List<double> embedding, double qualityScore,
                          String? faceImage)async {}
                      : _onCaptured,
                  onCaptureError: () {
                    debugPrint('Capture error callback - resetting state');
                    setState(() => _submitting = false);
                  },
                  onCaptureComplete: _onCaptureComplete,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 72, color: theme.colorScheme.primary),
                          const SizedBox(height: 12),
                          Text(
                            l10n.faceRegistered,
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
        ],
      ),
    );
  }
}
