import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/features/employees/data/employee_repository.dart';
import 'package:supervisor_app/features/employees/domain/employee_model.dart';

final employeesProvider = FutureProvider<List<EmployeeModel>>(
  (ref) => ref.read(employeeRepositoryProvider).getEmployees(),
);

Future<void> refreshEmployeesCache(WidgetRef ref) async {
  ref.invalidate(employeesProvider);
  await ref.read(employeesProvider.future);
}
