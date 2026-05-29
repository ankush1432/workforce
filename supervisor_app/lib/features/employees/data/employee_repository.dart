import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/network/dio_client.dart';
import 'package:supervisor_app/core/storage/hive_boxes.dart';
import 'package:supervisor_app/features/employees/domain/employee_model.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(ref.read(dioProvider));
});

class EmployeeRepository {
  EmployeeRepository(this._dio);

  final Dio _dio;

  Future<List<EmployeeModel>> getEmployees({bool? faceRegistered}) async {
    try {
      final response = await _dio.get('/supervisor/employees', queryParameters: {
        if (faceRegistered != null) 'face_registered': faceRegistered,
        'per_page': 100,
      });

      final list = (response.data['data'] as List)
          .map((e) => EmployeeModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      await _cacheEmployees(list);
      return list;
    } catch (_) {
      return _getCachedEmployees();
    }
  }

  Future<EmployeeModel> getEmployee(int id) async {
    final response = await _dio.get('/supervisor/employees/$id');
    return EmployeeModel.fromJson(Map<String, dynamic>.from(response.data['data']));
  }

  Future<void> _cacheEmployees(List<EmployeeModel> employees) async {
    await HiveBoxes.employeesBox.put(
      'list',
      employees.map((e) => e.toJson()).toList(),
    );
  }

  List<EmployeeModel> _getCachedEmployees() {
    final raw = HiveBoxes.employeesBox.get('list');
    if (raw is! List) return [];
    return raw.map((e) => EmployeeModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> updateEmployeeInCache(EmployeeModel employee) async {
    final cached = _getCachedEmployees();
    final index = cached.indexWhere((e) => e.id == employee.id);
    if (index >= 0) {
      cached[index] = employee;
    } else {
      cached.add(employee);
    }
    await _cacheEmployees(cached);
  }

  Future<List<EmployeeModel>> refreshEmployees() => getEmployees();
}
