import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supervisor_app/features/attendance/presentation/attendance_providers.dart';
import 'package:supervisor_app/features/attendance/presentation/employee_attendance_flow.dart';
import 'package:supervisor_app/features/employees/data/employee_repository.dart';
import 'package:supervisor_app/features/employees/presentation/widgets/face_status_chip.dart';
import 'package:supervisor_app/shared/widgets/loading_view.dart';

class EmployeeDetailPage extends ConsumerWidget {
  const EmployeeDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeFuture = ref.watch(_employeeProvider(id));
    final todayAsync = ref.watch(employeeTodayAttendanceProvider(id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Employee Details')),
      body: employeeFuture.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('$e')),
        data: (emp) {
          final today = todayAsync.valueOrNull;
          final checkedIn = today?.hasCheckIn ?? false;
          final checkedOut = today?.hasCheckOut ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(emp.displayName, style: theme.textTheme.headlineSmall),
                Text(
                  emp.employeeCode,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (emp.department != null) ...[
                  const SizedBox(height: 4),
                  Text(emp.department!),
                ],
                const SizedBox(height: 20),
                // FaceStatusChip(status: emp.faceStatus),
                if (emp.needsFaceRegistration) ...[
                  const SizedBox(height: 16),
                  Material(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: theme.colorScheme.onErrorContainer),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Face Not Registered',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.push(
                      '/employees/$id/register-face?returnTo=employee',
                    ),
                    icon: const Icon(Icons.face_rounded),
                    label: const Text('Register Face'),
                  ),
                ],
                if (today != null) ...[
                  const SizedBox(height: 20),
                  Text('Today', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (today.checkInAt != null)
                            Text('Check-in: ${_formatTime(today.checkInAt!)}'),
                          if (today.checkOutAt != null)
                            Text('Check-out: ${_formatTime(today.checkOutAt!)}'),
                          if (today.shiftName != null) Text('Shift: ${today.shiftName}'),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: checkedIn
                      ? null
                      : () => startEmployeeAttendance(
                            context: context,
                            ref: ref,
                            employee: emp,
                            action: EmployeeAttendanceAction.checkIn,
                          ),
                  icon: const Icon(Icons.login_rounded),
                  label: Text(checkedIn ? 'Already Checked In' : 'Check In'),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: !checkedIn || checkedOut
                      ? null
                      : () => startEmployeeAttendance(
                            context: context,
                            ref: ref,
                            employee: emp,
                            action: EmployeeAttendanceAction.checkOut,
                          ),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(checkedOut ? 'Already Checked Out' : 'Check Out'),
                ),
                if (!emp.needsFaceRegistration) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/employees/$id/register-face?returnTo=employee',
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Update Face'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      return DateFormat.jm().format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }
}

final _employeeProvider = FutureProvider.family((ref, int id) {
  return ref.read(employeeRepositoryProvider).getEmployee(id);
});
