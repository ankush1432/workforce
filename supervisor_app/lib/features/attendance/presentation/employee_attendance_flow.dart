import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/features/attendance/presentation/attendance_providers.dart';
import 'package:supervisor_app/features/employees/domain/employee_model.dart';

enum EmployeeAttendanceAction { checkIn, checkOut }

extension on EmployeeAttendanceAction {
  String get routeAction => switch (this) {
        EmployeeAttendanceAction.checkIn => 'check_in',
        EmployeeAttendanceAction.checkOut => 'check_out',
      };

  String get returnTo => routeAction;
}

/// Starts check-in/out from employee detail — no duplicate employee selection.
Future<void> startEmployeeAttendance({
  required BuildContext context,
  required WidgetRef ref,
  required EmployeeModel employee,
  required EmployeeAttendanceAction action,
}) async {
  final today = await ref.read(employeeTodayAttendanceProvider(employee.id).future);

  if (action == EmployeeAttendanceAction.checkIn && (today?.hasCheckIn ?? false)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already Checked In')),
      );
    }
    return;
  }

  if (action == EmployeeAttendanceAction.checkOut) {
    if (!(today?.hasCheckIn ?? false)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee must check in first')),
        );
      }
      return;
    }
    if (today?.hasCheckOut ?? false) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already Checked Out')),
        );
      }
      return;
    }
  }

  if (!context.mounted) return;

  if (employee.needsFaceRegistration) {
    context.push(
      '/employees/${employee.id}/register-face?returnTo=${action.returnTo}',
    );
    return;
  }

  context.push('/employees/${employee.id}/verify-face?action=${action.routeAction}');
}

void invalidateEmployeeAttendance(WidgetRef ref, int employeeId) {
  ref.invalidate(employeeTodayAttendanceProvider(employeeId));
  ref.invalidate(attendanceHistoryProvider);
}
