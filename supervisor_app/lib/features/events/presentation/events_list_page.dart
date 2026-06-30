import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supervisor_app/features/events/presentation/events_provider.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';
import 'package:supervisor_app/shared/widgets/empty_state.dart';
import 'package:supervisor_app/shared/widgets/loading_view.dart';

class EventsListPage extends ConsumerWidget {
  const EventsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final events = ref.watch(eventsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/images/app_logo.png",width: 35,height: 35,),
            SizedBox(width: 24,),
            Text(l10n.events),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(eventsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(eventsProvider),
        child: events.when(
          loading: () => const LoadingView(),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.5,
                child: Center(child: Text('${l10n.error}: $e')),
              ),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return  ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  EmptyState(
                    message: l10n.noEventsAvailable,
                    subtitle: l10n.noEventsPublished,
                    icon: Icons.event_outlined,
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final event = list[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/events/${event.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event.bannerImage != null) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 160,
                            child: Image.network(
                              event.bannerImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 160,
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.event_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 160,
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.event_rounded, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (event.location != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  event.location!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                _formatRange(event.startDate, event.endDate),
                                style: theme.textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatRange(String start, String end) {
    try {
      final s = DateTime.parse(start).toLocal();
      final e = DateTime.parse(end).toLocal();
      return '${DateFormat.MMMd().format(s)} – ${DateFormat.MMMd().format(e)}';
    } catch (_) {
      return '$start – $end';
    }
  }
}
