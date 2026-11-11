import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/app_lock_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('first read already reflects a saved lock', () async {
    SharedPreferences.setMockInitialValues({
      'app_lock_enabled': true,
      'app_lock_on_launch': true,
    });
    FlutterSecureStorage.setMockInitialValues({'app_lock_passcode': '1234'});
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final settings = container.read(appLockSettingsProvider);

    expect(settings.enabled, isTrue);
    expect(settings.lockOnLaunch, isTrue);
    expect(settings.hasPasscode, isTrue);
  });
}
