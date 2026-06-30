import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/error/app_exception.dart';
import 'package:supervisor_app/core/error/error_handler.dart';
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
    try {
      final response = await _dio.get('/supervisor/employees/$employeeId/face/status');
      final data = response.data;
      if (data == null) {
        throw ServerException('No response data from server');
      }
      final dataMap = data['data'];
      if (dataMap == null) {
        throw ServerException('No face status data in response');
      }
      final result = FaceRegistrationResult.fromJson(Map<String, dynamic>.from(dataMap as Map));
      if (result.employee != null) {
        await _employees.updateEmployeeInCache(result.employee!);
      }
      return result;
    } on DioException catch (e) {
      debugPrint('Error getting face status: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  Future<FaceRegistrationResult> registerFace({
    required int employeeId,
    required List<double> embedding,
    required double qualityScore,
    String? faceImage,
  }) async {
    try {
      final response = await _dio.post(
        '/supervisor/employees/$employeeId/face/register',
        data: {
          'embedding': embedding,
          'quality_score': qualityScore,
          if (faceImage != null) 'face_image': faceImage,
        },
      );

      final data = response.data;
      if (data == null) {
        throw ServerException('No response data from server');
      }

      // Check if the response indicates an error (duplicate face)
      if (data['success'] == false) {
        final message = data['message']?.toString() ?? 'Face registration failed';
        throw ValidationException(message);
      }

      final dataMap = data['data'];
      if (dataMap == null) {
        throw ServerException('No registration data in response');
      }
      final result = FaceRegistrationResult.fromJson(Map<String, dynamic>.from(dataMap as Map));
      if (result.employee != null) {
        await _employees.updateEmployeeInCache(result.employee!);
      }
      return result;
    } on DioException catch (e) {
      debugPrint('Error registering face: $e');
      throw ErrorHandler.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error registering face: $e');
      throw ApiException('Face registration failed: $e');
    }
  }
}
