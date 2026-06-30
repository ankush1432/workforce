import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/core/config/app_config.dart';
import 'package:supervisor_app/core/localization/language_provider.dart';
import 'package:supervisor_app/core/theme/app_theme.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.darkMode),
            value: themeMode == ThemeMode.dark,
            onChanged: (v) {
              ref.read(themeModeProvider.notifier).state =
                  v ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(_getLanguageName(currentLocale, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
             context.push("/language");
            },
          ),
          ListTile(
            title: Text(l10n.apiUrl),
            subtitle: Text(AppConfig.apiBaseUrl),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String localeCode, AppLocalizations l10n) {
    switch (localeCode) {
      case 'en':
        return l10n.english;
      case 'hi':
        return '${l10n.hindi} (Hindi)';
      case 'mr':
        return '${l10n.marathi} (Marathi)';
      default:
        return l10n.english;
    }
  }
}
