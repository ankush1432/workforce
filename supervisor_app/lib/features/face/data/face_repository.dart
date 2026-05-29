import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/network/dio_client.dart';
import 'package:supervisor_app/features/employees/data/employee_repository.dart';
import 'package:supervisor_app/features/face/domain/face_registration_result.dart';

final faceRepositoryProvider = Provider<FaceRepository>((ref) {
  return FaceRepository(
    ref.read(dioProvider),
    ref.read(employeeRepositoryProvider),
  );
});

class FaceRepository {
  FaceRepository(this._dio, this._employees);

  final Dio _dio;
  final EmployeeRepository _employees;

  Future<FaceRegistrationResult> getFaceStatus(int employeeId) async {
    final response = await _dio.get('/supervisor/employees/$employeeId/face/status');
    final data = Map<String, dynamic>.from(response.data['data'] as Map);
    final result = FaceRegistrationResult.fromJson(data);
    if (result.employee != null) {
      await _employees.updateEmployeeInCache(result.employee!);
    }
    return result;
  }

  Future<FaceRegistrationResult> registerFace({
    required int employeeId,
    required List<double> embedding,
    required double qualityScore,
  }) async {
    final response = await _dio.post(
      '/supervisor/employees/$employeeId/face/register',
      data: {
        'embedding': embedding,
        'quality_score': qualityScore,
      },
    );

    final data = Map<String, dynamic>.from(response.data['data'] as Map);
    final result = FaceRegistrationResult.fromJson(data);
    if (result.employee != null) {
      await _employees.updateEmployeeInCache(result.employee!);
    }
    return result;
  }
}
