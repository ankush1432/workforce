import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supervisor_app/features/attendance/domain/attendance_model.dart';
import 'package:supervisor_app/features/attendance/presentation/attendance_providers.dart';
import 'package:supervisor_app/shared/widgets/empty_state.dart';
import 'package:supervisor_app/shared/widgets/loading_view.dart';

class AttendanceHistoryPage extends ConsumerWidget {
  const AttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(attendanceHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(attendanceHistoryProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(attendanceHistoryProvider),
        child: history.when(
          loading: () => const LoadingView(),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.4,
                child: Center(child: Text('Error: $e')),
              ),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return  ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [EmptyState(message: 'No attendance records yet')],
              );
            }

            final grouped = _groupByDate(list);

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: grouped.length,
              itemBuilder: (_, i) {
                final entry = grouped[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                      child: Text(
                        entry.key,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    ...entry.value.map((a) => _AttendanceCard(record: a)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<MapEntry<String, List<AttendanceModel>>> _groupByDate(List<AttendanceModel> list) {
    final map = <String, List<AttendanceModel>>{};
    for (final item in list) {
      final label = item.attendanceDate.isNotEmpty
          ? item.attendanceDate
          : 'Unknown date';
      map.putIfAbsent(label, () => []).add(item);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.map((k) => MapEntry(k, map[k]!)).toList();
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.record});

  final AttendanceModel record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.employeeName ?? 'Employee #${record.employeeId}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusChip(status: record.status ?? 'present'),
              ],
            ),
            if (record.shiftName != null) ...[
              const SizedBox(height: 4),
              Text('Shift: ${record.shiftName}', style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TimeTile(
                    label: 'Check In',
                    time: record.checkInAt,
                    icon: Icons.login_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TimeTile(
                    label: 'Check Out',
                    time: record.checkOutAt,
                    icon: Icons.logout_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.icon,
  });

  final String label;
  final String? time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String display = '—';
    if (time != null) {
      try {
        display = DateFormat.jm().format(DateTime.parse(time!).toLocal());
      } catch (_) {
        display = time!;
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14),
              const SizedBox(width: 4),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(display, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
