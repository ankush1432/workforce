import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/error/error_handler.dart';
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

      final data = response.data;
      if (data == null) {
        debugPrint('No response data from server');
        return _getCachedEmployees();
      }

      final dataList = data['data'];
      if (dataList == null || dataList is! List) {
        debugPrint('Invalid employee data format');
        return _getCachedEmployees();
      }

      final list = dataList
          .map((e) {
            try {
              return EmployeeModel.fromJson(Map<String, dynamic>.from(e));
            } catch (e) {
              debugPrint('Error parsing employee: $e');
              return null;
            }
          })
          .whereType<EmployeeModel>()
          .toList();

      await _cacheEmployees(list);
      return list;
    } catch (e) {
      debugPrint('Error fetching employees: $e');
      return _getCachedEmployees();
    }
  }

  Future<EmployeeModel> getEmployee(int id) async {
    try {
      final response = await _dio.get('/supervisor/employees/$id');
      final data = response.data;
      if (data == null) {
        throw Exception('No response data from server');
      }
      final employeeData = data['data'];
      if (employeeData == null) {
        throw Exception('No employee data in response');
      }
      return EmployeeModel.fromJson(Map<String, dynamic>.from(employeeData as Map));
    } on DioException catch (e) {
      debugPrint('Error fetching employee: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> _cacheEmployees(List<EmployeeModel> employees) async {
    await HiveBoxes.employeesBox.put(
      'list',
      employees.map((e) => e.toJson()).toList(),
    );
  }

  List<EmployeeModel> _getCachedEmployees() {
    try {
      final raw = HiveBoxes.employeesBox.get('list');
      if (raw == null || raw is! List) return [];
      return raw
          .map((e) {
            try {
              return EmployeeModel.fromJson(Map<String, dynamic>.from(e));
            } catch (e) {
              debugPrint('Error parsing cached employee: $e');
              return null;
            }
          })
          .whereType<EmployeeModel>()
          .toList();
    } catch (e) {
      debugPrint('Error getting cached employees: $e');
      return [];
    }
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
