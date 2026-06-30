import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supervisor_app/core/error/error_handler.dart';
import 'package:supervisor_app/core/network/dio_client.dart';
import 'package:supervisor_app/core/storage/hive_boxes.dart';
import 'package:supervisor_app/features/attendance/domain/attendance_model.dart';
import 'package:uuid/uuid.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.read(dioProvider));
});

class AttendanceRepository {
  AttendanceRepository(this._dio);

  final Dio _dio;
  final _uuid = const Uuid();

  Future<AttendanceModel?> getTodayForEmployee(int employeeId) async {
    try {
      final response = await _dio.get('/supervisor/employees/$employeeId/attendance/today');
      final data = response.data;
      if (data == null) return null;
      final raw = data['data'];
      if (raw == null) return null;
      return AttendanceModel.fromJson(Map<String, dynamic>.from(raw));
    } catch (e) {
      debugPrint('Error fetching today attendance: $e');
      return null;
    }
  }

  Future<List<AttendanceModel>> getAttendanceHistory({
    int? employeeId,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/supervisor/attendance',
        queryParameters: {
          if (employeeId != null) 'employee_id': employeeId,
          'page': page,
          'per_page': perPage,
        },
      );

      final list = _parseAttendanceList(response.data);
      await _cacheHistory(list);
      return list;
    } catch (e) {
      debugPrint('Error fetching attendance history: $e');
      return _getCachedHistory();
    }
  }

  List<AttendanceModel> _parseAttendanceList(dynamic responseData) {
    if (responseData == null || responseData is! Map) return [];

    final data = responseData['data'];
    if (data is List) {
      return data
          .map((e) {
            try {
              return AttendanceModel.fromJson(Map<String, dynamic>.from(e));
            } catch (e) {
              debugPrint('Error parsing attendance item: $e');
              return null;
            }
          })
          .whereType<AttendanceModel>()
          .toList();
    }

    return [];
  }

  Future<void> _cacheHistory(List<AttendanceModel> items) async {
    await HiveBoxes.attendanceBox.put(
      'history',
      items.map((e) => e.toJson()).toList(),
    );
  }

  List<AttendanceModel> _getCachedHistory() {
    try {
      final raw = HiveBoxes.attendanceBox.get('history');
      if (raw == null || raw is! List) return [];
      return raw
          .map((e) {
            try {
              return AttendanceModel.fromJson(Map<String, dynamic>.from(e));
            } catch (e) {
              debugPrint('Error parsing cached attendance: $e');
              return null;
            }
          })
          .whereType<AttendanceModel>()
          .toList();
    } catch (e) {
      debugPrint('Error getting cached history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> checkIn({
    required int employeeId,
    required int siteId,
    required List<double> embedding,
    int? shiftId,
  }) async {
    final position = await _currentPosition();
    final deviceId = await _deviceId();
    final payload = {
      'employee_id': employeeId,
      'site_id': siteId,
      if (shiftId != null) 'shift_id': shiftId,
      'embedding': embedding,
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'device_id': deviceId,
    };

    return _postOrQueue('check_in', 'attendance', payload);
  }

  Future<Map<String, dynamic>> checkOut({
    required int employeeId,
    required List<double> embedding,
  }) async {
    final position = await _currentPosition();
    final deviceId = await _deviceId();
    final payload = {
      'employee_id': employeeId,
      'embedding': embedding,
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'device_id': deviceId,
    };

    return _postOrQueue('check_out', 'attendance', payload);
  }

  Future<Map<String, dynamic>> checkInByFace({
    required List<double> embedding,
    String? faceImage,
  }) async {
    final position = await _currentPosition();
    final deviceId = await _deviceId();
    final payload = {
      'embedding': embedding,
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'device_id': deviceId,
      if (faceImage != null) 'face_image': faceImage,
    };

    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = !connectivity.contains(ConnectivityResult.none);

    if (isOnline) {
      try {
        final response = await _dio.post('/supervisor/attendance/check-in-by-face', data: payload);
        final data = response.data;
        if (data == null) {
          throw Exception('No response data from server');
        }
        return Map<String, dynamic>.from(data);
      } on DioException catch (e) {
        debugPrint('Check-in by face error: ${e.message}, Status: ${e.response?.statusCode}');
        final appException = ErrorHandler.handleError(e);
        throw appException;
      }
    }

    throw Exception('Face-based check-in requires internet connection');
  }

  Future<Map<String, dynamic>> checkOutByFace({
    required List<double> embedding,
    String? faceImage,
  }) async {
    final position = await _currentPosition();
    final deviceId = await _deviceId();
    final payload = {
      'embedding': embedding,
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'device_id': deviceId,
      if (faceImage != null) 'face_image': faceImage,
    };

    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = !connectivity.contains(ConnectivityResult.none);

    if (isOnline) {
      try {
        final response = await _dio.post('/supervisor/attendance/check-out-by-face', data: payload);
        final data = response.data;
        if (data == null) {
          throw Exception('No response data from server');
        }
        return Map<String, dynamic>.from(data);
      } on DioException catch (e) {
        debugPrint('Check-out by face error: ${e.message}, Status: ${e.response?.statusCode}');
        final appException = ErrorHandler.handleError(e);
        throw appException;
      }
    }

    throw Exception('Face-based check-out requires internet connection');
  }

  Future<Map<String, dynamic>> _postOrQueue(
    String action,
    String entityType,
    Map<String, dynamic> payload,
  ) async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = !connectivity.contains(ConnectivityResult.none);

    if (isOnline) {
      try {
        final path = action == 'check_in'
            ? '/supervisor/attendance/check-in'
            : '/supervisor/attendance/check-out';
        final response = await _dio.post(path, data: payload);
        final data = response.data;
        if (data == null) {
          throw Exception('No response data from server');
        }
        return Map<String, dynamic>.from(data);
      } on DioException catch (e) {
        debugPrint('API error, queuing for offline: $e');
        await _enqueue(action, entityType, payload);
        rethrow;
      }
    }

    await _enqueue(action, entityType, payload);
    return {'message': 'Saved offline. Will sync when online.', 'offline': true};
  }

  Future<void> _enqueue(String action, String entityType, Map<String, dynamic> payload) async {
    try {
      final queue = List<Map<String, dynamic>>.from(
        (HiveBoxes.offlineBox.get('queue') as List?)?.cast<Map>() ?? [],
      );
      queue.add({
        'id': _uuid.v4(),
        'entity_type': entityType,
        'action': action,
        'payload': payload,
        'created_at': DateTime.now().toIso8601String(),
      });
      await HiveBoxes.offlineBox.put('queue', queue);
    } catch (e) {
      debugPrint('Error enqueuing offline request: $e');
    }
  }

  Future<Position?> _currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return null;
      
      // Add timeout to prevent hanging using new API
      return await Geolocator.getCurrentPosition(

      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  Future<String> _deviceId() async {
    var id = HiveBoxes.settingsBox.get('device_id') as String?;
    if (id == null) {
      id = _uuid.v4();
      await HiveBoxes.settingsBox.put('device_id', id);
    }
    return id;
  }
}
