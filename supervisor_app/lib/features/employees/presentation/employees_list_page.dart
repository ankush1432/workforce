import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/features/employees/domain/face_registration_status.dart';
import 'package:supervisor_app/features/employees/presentation/employees_provider.dart';
import 'package:supervisor_app/features/employees/presentation/widgets/face_status_chip.dart';
import 'package:supervisor_app/shared/widgets/empty_state.dart';
import 'package:supervisor_app/shared/widgets/loading_view.dart';

class EmployeesListPage extends ConsumerWidget {
  const EmployeesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => refreshEmployeesCache(ref),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshEmployeesCache(ref),
        child: employees.when(
          loading: () => const LoadingView(),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.5,
                child: Center(child: Text('Error: $e')),
              ),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return  ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [EmptyState(message: 'No employees found')],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final emp = list[i];
                final needsRegistration = emp.needsFaceRegistration;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/employees/${emp.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor: theme.colorScheme.onPrimaryContainer,
                            child: Text(
                              emp.firstName.isNotEmpty ? emp.firstName[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  emp.displayName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${emp.employeeCode} · ${emp.department ?? "—"}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                FaceStatusChip(status: emp.faceStatus, compact: true),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (emp.faceStatus == FaceRegistrationStatus.registered)
                                Icon(
                                  Icons.verified_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                              if (needsRegistration) ...[
                                const SizedBox(height: 8),
                                FilledButton.tonal(
                                  onPressed: () => context.push(
                                      '/employees/${emp.id}/register-face?returnTo=employee'),
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: const Text('Register'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
