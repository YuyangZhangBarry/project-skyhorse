import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_provider.dart';

const _kLocaleKey = 'app_locale';

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_initialLocale(_prefs));

  static Locale _initialLocale(SharedPreferences prefs) {
    final saved = prefs.getString(_kLocaleKey);
    if (saved != null) return Locale(saved);
    final system = PlatformDispatcher.instance.locale.languageCode;
    return Locale(system == 'zh' ? 'zh' : 'en');
  }

  void toggle() {
    final next = state.languageCode == 'zh' ? const Locale('en') : const Locale('zh');
    state = next;
    _prefs.setString(_kLocaleKey, next.languageCode);
  }

}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref.watch(sharedPreferencesProvider));
});
