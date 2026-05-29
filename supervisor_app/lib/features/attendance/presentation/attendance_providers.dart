import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/features/attendance/data/attendance_repository.dart';
import 'package:supervisor_app/features/attendance/domain/attendance_model.dart';

final employeeTodayAttendanceProvider =
    FutureProvider.family<AttendanceModel?, int>((ref, employeeId) {
  return ref.read(attendanceRepositoryProvider).getTodayForEmployee(employeeId);
});

final attendanceHistoryProvider = FutureProvider<List<AttendanceModel>>((ref) {
  return ref.read(attendanceRepositoryProvider).getAttendanceHistory();
});
