import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/core/error/app_exception.dart';
import 'package:supervisor_app/core/error/error_handler.dart';
import 'package:supervisor_app/core/utils/dialog_helper.dart';
import 'package:supervisor_app/features/attendance/data/attendance_repository.dart';
import 'package:supervisor_app/features/face/presentation/widgets/face_camera_capture_widget.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';

class FaceVerificationPage extends ConsumerStatefulWidget {
  const FaceVerificationPage({
    super.key,
    required this.employeeId,
    required this.action,
  });

  final int? employeeId;
  final String action;

  bool get isCheckIn => action == 'check_in';

  bool get isFaceAttendanceMode => employeeId == null;

  @override
  ConsumerState<FaceVerificationPage> createState() =>
      _FaceVerificationPageState();
}

class _FaceVerificationPageState extends ConsumerState<FaceVerificationPage> {
  bool _submitting = false;
  bool _disposed = false;
  bool _dialogShowing = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _onCaptureComplete() {
    debugPrint('CAPTURE COMPLETE - FaceVerificationPage');
    setState(() => _submitting = false);
  }

  Future<void> _onVerified(
      List<double> embedding, double qualityScore, String? faceImage) async {
    if (_submitting || _disposed) return;
    
    debugPrint('Face Attendance Started - isCheckIn: ${widget.isCheckIn}');
    setState(() => _submitting = true);

    try {
      Map<String, dynamic> result;

      // Face attendance mode - no employee_id, backend matches face
      final repository = ref.read(attendanceRepositoryProvider);
      
      debugPrint('Face Detected - qualityScore: $qualityScore');
      debugPrint('Embedding Generated - length: ${embedding.length}');
      
      if (widget.isCheckIn) {
        debugPrint('API Request Started - checkInByFace');
        result = await repository.checkInByFace(
            embedding: embedding, faceImage: faceImage).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Face verification timed out');
            },
          );
        debugPrint('API Response Received - checkInByFace');
      } else {
        debugPrint('API Request Started - checkOutByFace');
        result = await repository.checkOutByFace(
            embedding: embedding, faceImage: faceImage).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Face verification timed out');
            },
          );
        debugPrint('API Response Received - checkOutByFace');
      }

      if (_disposed) return;
      if (!mounted) return;
      
      debugPrint('Attendance Success - isCheckIn: ${widget.isCheckIn}');
      _showFaceAttendanceSuccessDialog(result);
    } on DioException catch (e) {
      debugPrint('Attendance Failed - DioException: ${e.message}');
      if (_disposed) return;
      if (mounted) {
        final errorMessage = ErrorHandler.extractBackendMessage(e);
        _showErrorDialog(errorMessage);
      }
      return;
    } on TimeoutException catch (e) {
      debugPrint('Attendance Failed - TimeoutException: $e');
      if (_disposed) return;
      if (mounted) {
        _showErrorDialog('Request timed out. Please try again.');
      }
    } on SocketException catch (e) {
      debugPrint('Attendance Failed - SocketException: $e');
      if (_disposed) return;
      if (mounted) {
        _showErrorDialog('No internet connection. Please check your network and try again.');
      }
    } on AppException catch (e) {
      debugPrint('Attendance Failed - AppException: ${e.message}');
      if (_disposed) return;
      if (mounted) {
        setState(() {
          _submitting = false;
        });
        _showErrorDialog(e.message);
      }
    } on Exception catch (e) {
      debugPrint('Attendance Failed - Exception: $e');
      if (_disposed) return;
      if (mounted) {
        _showErrorDialog('An error occurred. Please try again.');
      }
    } finally {
      debugPrint('Attendance cleanup completed');
      // Always reset submitting state, even on error
      if (!_disposed && mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showErrorDialog(String errorMessage) {
    debugPrint('ERROR DIALOG SHOWN - FaceVerificationPage');
    if (_dialogShowing) return;
    
    setState(() => _dialogShowing = true);
    
    DialogHelper.showError(
      context,
      title: widget.isCheckIn ? 'Check-In Failed' : 'Check-Out Failed',
      message: errorMessage,
      buttonText: 'OK',
    ).then((_) {
      debugPrint('ERROR DIALOG CLOSED - FaceVerificationPage');
      if (!mounted) return;

      _dialogShowing = false;
      context.go('/dashboard');
    });
  }

  void _showFaceAttendanceSuccessDialog(Map<String, dynamic> result) {
    if (_dialogShowing) return;
    
    setState(() => _dialogShowing = true);
    final l10n = AppLocalizations.of(context)!;
    
    // Defensive null checks for data extraction
    final data = result['data'] is Map<String, dynamic> 
        ? result['data'] as Map<String, dynamic> 
        : null;
    final employeeName = data?['employee_name']?.toString() ?? 'Unknown';
    final employeeCode = data?['employee_code']?.toString() ?? 'Unknown';
    
    // Defensive null check for confidence
    double confidence = 0.0;
    if (data?['confidence'] != null) {
      try {
        confidence = data!['confidence'] is num 
            ? (data['confidence'] as num).toDouble() 
            : double.tryParse(data['confidence'].toString()) ?? 0.0;
      } catch (e) {
        debugPrint('Error parsing confidence: $e');
      }
    }
    
    final attendance = data?['attendance'] is Map<String, dynamic>
        ? data!['attendance'] as Map<String, dynamic>
        : null;
    final checkTime = attendance != null
        ? (widget.isCheckIn
            ? attendance['check_in_time']?.toString()
            : attendance['check_out_time']?.toString())
        : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isCheckIn ? l10n.checkInSuccessful : l10n.checkOutSuccessful,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _InfoRow(label: l10n.employeeName, value: employeeName),
            _InfoRow(label: l10n.employeeCode, value: employeeCode),
            if (checkTime != null) _InfoRow(label: l10n.time, value: checkTime),
            _InfoRow(
                label: l10n.confidence,
                value: '${(confidence * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.go('/dashboard');
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _dialogShowing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCheckIn ? l10n.checkIn : l10n.checkOut),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _submitting || _disposed
              ? null
              : () => context.go('/dashboard')

        ),
      ),
      body: _buildFaceAttendanceMode(),
    );
  }

  Widget _buildFaceAttendanceMode() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final action = widget.isCheckIn ? 'Check-In' : 'Check-Out';
    final hint = l10n.attendanceWillContinue(action);
    
    return Stack(
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
                primaryActionLabel: widget.isCheckIn
                    ? l10n.verifyAndCheckIn
                    : l10n.verifyAndCheckOut,
                enableAutoCapture: true,
                onCaptured: _submitting || _disposed ? (_, __, ___) async{} : _onVerified,
                onCaptureComplete: _onCaptureComplete,
              ),
            ),
          ],
        ),
        if (_submitting)
          const ColoredBox(
            color: Colors.black38,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
