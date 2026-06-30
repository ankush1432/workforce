import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/core/localization/language_provider.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final controller = ref.read(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLanguage),
      ),
      body: ListView(
        children: [
          _LanguageTile(
            language: l10n.english,
            localeCode: 'en',
            isSelected: currentLocale == 'en',
            onTap: () => _selectLanguage(context, controller, 'en'),
          ),
          _LanguageTile(
            language: l10n.hindi,
            localeCode: 'hi',
            isSelected: currentLocale == 'hi',
            onTap: () => _selectLanguage(context, controller, 'hi'),
          ),
          _LanguageTile(
            language: l10n.marathi,
            localeCode: 'mr',
            isSelected: currentLocale == 'mr',
            onTap: () => _selectLanguage(context, controller, 'mr'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectLanguage(
    BuildContext context,
    LocaleController controller,
    String localeCode,
  ) async {
    await controller.setLocale(localeCode);
    if (context.mounted) {
      context.go('/dashboard');
    }
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.localeCode,
    required this.isSelected,
    required this.onTap,
  });

  final String language;
  final String localeCode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : const Icon(Icons.radio_button_unchecked),
      onTap: onTap,
    );
  }
}
