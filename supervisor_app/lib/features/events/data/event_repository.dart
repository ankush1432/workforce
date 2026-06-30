import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/network/dio_client.dart';
import 'package:supervisor_app/core/storage/hive_boxes.dart';
import 'package:supervisor_app/features/events/domain/event_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.read(dioProvider));
});

class EventRepository {
  EventRepository(this._dio);

  final Dio _dio;

  Future<List<EventModel>> getEvents() async {
    try {
      final response = await _dio.get('/supervisor/events', queryParameters: {
        'per_page': 50,
        'status': 'published',
      });

      final list = _parseList(response.data);
      await HiveBoxes.eventsBox.put('list', list.map((e) => e.toJson()).toList());
      return list;
    } catch (_) {
      return _cached();
    }
  }

  Future<EventModel> getEvent(int id) async {
    final response = await _dio.get('/supervisor/events/$id');
    return EventModel.fromJson(Map<String, dynamic>.from(response.data['data']));
  }

  List<EventModel> _parseList(dynamic data) {
    if (data is! Map) return [];
    final raw = data['data'];
    if (raw is! List) return [];
    return raw.map((e) => EventModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  List<EventModel> _cached() {
    final raw = HiveBoxes.eventsBox.get('list');
    if (raw is! List) return [];
    return raw.map((e) => EventModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
