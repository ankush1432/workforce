import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/features/attendance/data/attendance_repository.dart';
import 'package:supervisor_app/features/attendance/presentation/attendance_providers.dart';
import 'package:supervisor_app/features/attendance/presentation/employee_attendance_flow.dart';
import 'package:supervisor_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:supervisor_app/features/employees/data/employee_repository.dart';
import 'package:supervisor_app/features/face/presentation/widgets/face_camera_capture_widget.dart';
import 'package:supervisor_app/shared/widgets/loading_view.dart';

class FaceVerificationPage extends ConsumerStatefulWidget {
  const FaceVerificationPage({
    super.key,
    required this.employeeId,
    required this.action,
  });

  final int employeeId;
  final String action;

  bool get isCheckIn => action == 'check_in';

  @override
  ConsumerState<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends ConsumerState<FaceVerificationPage> {
  bool _submitting = false;

  Future<void> _onVerified(List<double> embedding, double qualityScore) async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      if (widget.isCheckIn) {
        final auth = ref.read(authStateProvider).valueOrNull;
        final siteId = auth?.supervisor?['site_id'] as int? ?? 1;
        await ref.read(attendanceRepositoryProvider).checkIn(
              employeeId: widget.employeeId,
              siteId: siteId,
              embedding: embedding,
            );
      } else {
        await ref.read(attendanceRepositoryProvider).checkOut(
              employeeId: widget.employeeId,
              embedding: embedding,
            );
      }

      invalidateEmployeeAttendance(ref, widget.employeeId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isCheckIn ? 'Check-in recorded' : 'Check-out recorded'),
        ),
      );
      context.go('/employees/${widget.employeeId}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeAsync = ref.watch(_employeeProvider(widget.employeeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCheckIn ? 'Check In' : 'Check Out'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _submitting ? null : () => context.go('/employees/${widget.employeeId}'),
        ),
      ),
      body: employeeAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('$e')),
        data: (emp) => Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    'Verifying ${emp.displayName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FaceCameraCaptureWidget(
                    requireLiveness: true,
                    primaryActionLabel:
                        widget.isCheckIn ? 'Verify & Check In' : 'Verify & Check Out',
                    onCaptured: _submitting ? (_, __) {} : _onVerified,
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
        ),
      ),
    );
  }
}

final _employeeProvider = FutureProvider.family((ref, int id) {
  return ref.read(employeeRepositoryProvider).getEmployee(id);
});
