import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/features/events/data/event_repository.dart';
import 'package:supervisor_app/features/events/domain/event_model.dart';

final eventsProvider = FutureProvider<List<EventModel>>(
  (ref) => ref.read(eventRepositoryProvider).getEvents(),
);

final eventDetailProvider = FutureProvider.family<EventModel, int>(
  (ref, id) => ref.read(eventRepositoryProvider).getEvent(id),
);
