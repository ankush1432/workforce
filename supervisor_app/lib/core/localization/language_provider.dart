import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/localization/locale_repository.dart';

final localeRepositoryProvider = Provider<LocaleRepository>((ref) {
  return LocaleRepository();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier(this._repository) : super('en') {
    _loadLocale();
  }

  final LocaleRepository _repository;

  Future<void> _loadLocale() async {
    final savedLocale = await _repository.getSavedLocale();
    if (savedLocale != null) {
      state = savedLocale;
    }
  }

  Future<void> setLocale(String localeCode) async {
    await _repository.saveLocale(localeCode);
    state = localeCode;
  }

  Future<void> clearLocale() async {
    await _repository.clearLocale();
    state = 'en';
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier(ref.read(localeRepositoryProvider));
});

final localeControllerProvider = Provider<LocaleController>((ref) {
  return LocaleController(ref.read(localeRepositoryProvider), ref.read(localeProvider.notifier));
});

class LocaleController {
  LocaleController(this._repository, this._notifier);

  final LocaleRepository _repository;
  final LocaleNotifier _notifier;

  Future<void> setLocale(String localeCode) async {
    await _repository.saveLocale(localeCode);
    _notifier.setLocale(localeCode);
  }

  Future<void> clearLocale() async {
    await _repository.clearLocale();
    _notifier.clearLocale();
  }

  Future<String> getSavedLocale() async {
    return await _repository.getSavedLocale() ?? 'en';
  }
}
