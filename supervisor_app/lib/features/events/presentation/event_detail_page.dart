import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supervisor_app/features/events/presentation/events_provider.dart';
import 'package:supervisor_app/shared/widgets/loading_view.dart';

class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: eventAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('$e')),
        data: (event) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              if (event.location != null)
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(event.location!),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(_format(event.startDate, event.endDate)),
                ],
              ),
              const SizedBox(height: 20),
              if (event.description != null && event.description!.isNotEmpty)
                Text(event.description!, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }

  String _format(String start, String end) {
    try {
      final s = DateTime.parse(start).toLocal();
      final e = DateTime.parse(end).toLocal();
      return '${DateFormat.yMMMd().add_jm().format(s)} – ${DateFormat.yMMMd().add_jm().format(e)}';
    } catch (_) {
      return '$start – $end';
    }
  }
}
