import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/desktop_settings_provider.dart';

void main() {
  test('desktop settings load synchronously and persist updates', () async {
    SharedPreferences.setMockInitialValues({
      'desktop_volume': 0.4,
      'desktop_is_muted': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final settings = container.read(desktopSettingsProvider);
    expect(settings.volume, 0.4);
    expect(settings.isMuted, isTrue);

    await container.read(desktopSettingsProvider.notifier).setVolume(2);
    await container.read(desktopSettingsProvider.notifier).toggleMute();

    expect(container.read(desktopSettingsProvider).volume, 1);
    expect(container.read(desktopSettingsProvider).isMuted, isFalse);
    expect(prefs.getDouble('desktop_volume'), 1);
    expect(prefs.getBool('desktop_is_muted'), isFalse);
  });
}
