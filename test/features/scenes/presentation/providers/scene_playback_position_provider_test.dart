import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_playback_position_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/server_profiles_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'server_profiles':
          '[{"id":"a","baseUrl":"http://a","authMode":"apiKey"},'
          '{"id":"b","baseUrl":"http://b","authMode":"apiKey"}]',
      'active_server_profile_id': 'a',
    });
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('retains only played scene positions after listeners leave', () async {
    final played = scenePlaybackPositionProvider('played');
    final unplayed = scenePlaybackPositionProvider('unplayed');
    final subscription = container.listen(unplayed, (_, _) {});
    expect(subscription.read(), isNull);
    container.read(played.notifier).update(const Duration(milliseconds: 12500));
    subscription.close();
    await container.pump();

    expect(container.exists(unplayed), isFalse);
    expect(container.read(played), 12.5);
    expect(container.read(scenePlaybackPositionProvider('other')), isNull);
  });

  test('accepts backward seeks and zero, ignores negative positions', () {
    final position = scenePlaybackPositionProvider('played');
    final notifier = container.read(position.notifier);
    notifier.update(const Duration(seconds: 90));
    notifier.update(const Duration(seconds: 20));
    expect(container.read(position), 20);
    notifier.update(Duration.zero);
    expect(container.read(position), 0);
    notifier.update(const Duration(seconds: -1));
    expect(container.read(position), 0);
  });

  test(
    'clears retained positions on server switch, including matching IDs',
    () async {
      final position = scenePlaybackPositionProvider('same-id');
      container.read(position.notifier).update(const Duration(seconds: 90));
      await container.read(activeServerProfileIdProvider.notifier).set('b');
      expect(container.read(position), isNull);
      container.read(position.notifier).update(const Duration(seconds: 30));
      await container.read(activeServerProfileIdProvider.notifier).set('a');
      expect(container.read(position), isNull);
    },
  );
}
