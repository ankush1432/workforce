import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supervisor_app/features/attendance/presentation/attendance_providers.dart';
import 'package:supervisor_app/features/employees/data/employee_repository.dart';
import 'package:supervisor_app/features/employees/domain/employee_model.dart';
import 'package:supervisor_app/features/employees/presentation/widgets/face_status_chip.dart';
import 'package:supervisor_app/shared/widgets/loading_view.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';

class EmployeeDetailPage extends ConsumerWidget {
  const EmployeeDetailPage({super.key, required this.id, this.employee});

  final int id;
  final EmployeeModel? employee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // If employee is not provided (e.g., when returning from face registration), fetch it
    final employeeAsync = employee != null
        ? AsyncValue.data(employee)
        : ref.watch(_employeeProvider(id));

    return employeeAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.employeeDetails)),
        body: const LoadingView(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.employeeDetails)),
        body: Center(child: Text('${l10n.error}: $e')),
      ),
      data: (emp) {
        final todayAsync = ref.watch(employeeTodayAttendanceProvider(id));
        final today = todayAsync.valueOrNull;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.employeeDetails)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (emp!.needsFaceRegistration) ...[
                  Material(
                    color:
                    theme.colorScheme.errorContainer.withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: theme.colorScheme.onErrorContainer),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.faceNotRegistered,
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
                    label: Text(l10n.registerFace),
                  ),
                ],
                if (today != null) ...[
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    theme,
                    title: l10n.todayAttendance,
                    children: [
                      if(today.checkInAt!=null)
                      _buildInfoRow(
                        theme,
                        l10n.checkInTime,
                        _formatTime(today.checkInAt!),
                      ),
                      if(today.checkOutAt!=null)
                      _buildInfoRow(
                        theme,
                        l10n.checkOutTime,
                        _formatTime(today.checkOutAt!),
                      ),

                    ],
                  ),
                ],
                const SizedBox(height: 16),
                _buildSectionCard(
                  theme,
                  title: l10n.employeeInformation,
                  children: [

                    _buildInfoRow(theme, l10n.employeeName, emp.fullName ?? '-'),
                    _buildInfoRow(
                        theme, l10n.employeeCode, emp.employeeCode),
                    _buildCopyableRow(
                      context,
                      theme,
                      l10n.email,
                      emp.email ?? '-',
                      emp.email ?? "-",
                    ),
                    _buildCopyableRow(
                      context,
                      theme,
                      l10n.phone,
                      emp.phone ?? '-',
                      emp.phone ?? "-",
                    ),
                    _buildInfoRow(
                      theme,
                      l10n.faceRegistrationStatus,
                      '',
                      trailing: FaceStatusChip(
                          status: emp.faceStatus),
                    ),
                    _buildInfoRow(
                      theme,
                      l10n.activeStatus,
                      '',
                      trailing: _buildActiveStatusChip(context,theme, emp.isActive),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  theme,
                  title: l10n.departmentDesignation,
                  children: [
                    _buildInfoRow(
                      theme,
                      l10n.department,
                      emp.departmentRelation?.name ?? emp.department ?? '-',
                    ),
                    _buildInfoRow(
                      theme,
                      l10n.designation,
                      emp.designationRelation?.title ?? '-',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  theme,
                  title: l10n.siteInformation,
                  children: [
                    _buildInfoRow(
                      theme,
                      l10n.siteName,
                      emp.site?.name ?? '-',
                    ),
                    _buildInfoRow(
                      theme,
                      l10n.siteAddress,
                      emp.site?.address ?? '-',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  theme,
                  title: l10n.shiftInformation,
                  children: [
                    _buildInfoRow(
                      theme,
                      l10n.shiftName,
                      emp.shift?.name ?? '-',
                    ),
                    _buildInfoRow(
                      theme,
                      l10n.shiftTime,
                      _formatShiftTime(
                          emp.shift?.startTime, emp.shift?.endTime),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  theme,
                  title: l10n.supervisorInformation,
                  children: [
                    _buildInfoRow(
                      theme,
                      l10n.supervisorName,
                      emp.supervisor?.fullName ?? '-',
                    ),
                  ],
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard(ThemeData theme,
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: trailing ??
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableRow(BuildContext context, ThemeData theme, String label,
      String value, String? copyValue) {
    final l10n = AppLocalizations.of(context)!;
    
    if (copyValue == null || copyValue.isEmpty || copyValue == '-') {
      return _buildInfoRow(theme, label, value);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: copyValue));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.copiedToClipboard)),
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.copy,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStatusChip(BuildContext context,ThemeData theme, bool? isActive) {
    final l10n = AppLocalizations.of(context)!;
    
    if (isActive == null) {
      return const Text('-');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isActive ? l10n.active : l10n.inactive,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isActive
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatShiftTime(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return '-';

    try {
      final start = DateFormat('HH:mm:ss').parse(startTime);
      final end = DateFormat('HH:mm:ss').parse(endTime);
      final startFormatted = DateFormat('hh:mm a').format(start);
      final endFormatted = DateFormat('hh:mm a').format(end);
      return '$startFormatted - $endFormatted';
    } catch (_) {
      return '$startTime - $endTime';
    }
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
