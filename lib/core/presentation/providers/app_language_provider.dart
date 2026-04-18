import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/preferences/shared_preferences_provider.dart';

const appLanguagePreferenceKey = 'app_language';

class AppLanguageNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final languageCode = prefs.getString(appLanguagePreferenceKey);
    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }

    if (languageCode.contains('_')) {
      final parts = languageCode.split('_');
      if (parts.length == 2) {
        // Treat common script codes (e.g. Hans/Hant) as scriptCode, not country.
        if (parts[1] == 'Hans' || parts[1] == 'Hant') {
          return Locale.fromSubtags(
            languageCode: parts[0],
            scriptCode: parts[1],
          );
        }
        return Locale(parts[0], parts[1]);
      }
      if (parts.length == 3) {
        return Locale.fromSubtags(
          languageCode: parts[0],
          scriptCode: parts[1],
          countryCode: parts[2],
        );
      }
    }
    return Locale(languageCode);
  }

  Future<void> setLanguage(String? languageCode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (languageCode == null || languageCode.isEmpty) {
      state = null;
      await prefs.remove(appLanguagePreferenceKey);
    } else {
      if (languageCode.contains('_')) {
        final parts = languageCode.split('_');
        if (parts.length == 2) {
          if (parts[1] == 'Hans' || parts[1] == 'Hant') {
            state = Locale.fromSubtags(
              languageCode: parts[0],
              scriptCode: parts[1],
            );
          } else {
            state = Locale(parts[0], parts[1]);
          }
        } else if (parts.length == 3) {
          state = Locale.fromSubtags(
            languageCode: parts[0],
            scriptCode: parts[1],
            countryCode: parts[2],
          );
        } else {
          state = Locale(languageCode);
        }
      } else {
        state = Locale(languageCode);
      }
      await prefs.setString(appLanguagePreferenceKey, languageCode);
    }
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, Locale?>(
  AppLanguageNotifier.new,
);

const supportedLanguages = {
  null: 'System Default',
  'en': 'English',
  'es': 'Español',
  'zh_Hans': '简体中文',
  'zh_Hant': '繁體中文',
  'ja': '日本語',
  'ko': '한국어',
  'fr': 'Français',
  'it': 'Italiano',
  'de': 'Deutsch',
  'ru': 'Русский',
};
