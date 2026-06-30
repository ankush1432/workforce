import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).uri.path;

    int index = 0;
    if (location.startsWith('/employees')) index = 1;
    if (location.startsWith('/events')) index = 2;
    if (location.startsWith('/profile') || location.startsWith('/settings')) index = 3;

    final hideNav = location.contains('register-face') ||
        location.contains('verify-face');

    return Scaffold(
      body: child,
      bottomNavigationBar: hideNav
          ? null
          : NavigationBar(
              selectedIndex: index.clamp(0, 3),
              onDestinationSelected: (i) {
                switch (i) {
                  case 0:
                    context.go('/dashboard');
                  case 1:
                    context.go('/employees');
                  case 2:
                    context.go('/events');
                  case 3:
                    context.go('/profile');
                }
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: l10n.home,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: const Icon(Icons.people_rounded),
                  label: l10n.employees,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.event_outlined),
                  selectedIcon: const Icon(Icons.event_rounded),
                  label: l10n.events,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: l10n.profile,
                ),
              ],
            ),
    );
  }
}
