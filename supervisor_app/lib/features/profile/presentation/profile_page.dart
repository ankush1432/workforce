import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider).valueOrNull;
    final supervisor = auth?.supervisor;

    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Image.asset("assets/images/app_logo.png",width: 35,height: 35,),
          SizedBox(width: 24,),
          Text(l10n.profile),
        ],
      )),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(supervisor?['full_name'] ?? supervisor?['first_name'] ?? l10n.supervisor),
            subtitle: Text(supervisor?['email'] ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            onTap: () => context.push('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(l10n.signOut),
            onTap: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
