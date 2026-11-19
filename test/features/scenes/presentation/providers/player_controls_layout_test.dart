import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_controls_layout.dart';

Future<ProviderContainer> _container(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('defaults keep playlist top right and random fullscreen-only', () async {
    final container = await _container({});
    final inline = container.read(inlinePlayerControlsLayoutProvider);
    final fullscreen = container.read(fullscreenPlayerControlsLayoutProvider);

    PlayerControlItem find(
      List<PlayerControlItem> items,
      PlayerControlButton b,
    ) => items.singleWhere((i) => i.button == b);
    expect(
      find(inline, PlayerControlButton.playlist).placement,
      PlayerControlPlacement.topRight,
    );
    expect(find(inline, PlayerControlButton.random).visible, isFalse);
    expect(find(fullscreen, PlayerControlButton.random).visible, isTrue);
    expect(
      find(inline, PlayerControlButton.cast).placement,
      PlayerControlPlacement.bottom,
    );
  });

  test(
    'restores saved order, drops unknown and duplicate ids, appends missing',
    () async {
      final container = await _container({
        PlayerControlsLayoutNotifier.inlineKey: jsonEncode([
          {'id': 'cast', 'visible': false, 'placement': 'topRight'},
          {'id': 'bogus'},
          {'id': 'cast', 'visible': true},
          {'id': 'speed', 'placement': 'nowhere'},
        ]),
      });
      final items = container.read(inlinePlayerControlsLayoutProvider);

      expect(items.length, PlayerControlButton.values.length);
      expect(items[0].button, PlayerControlButton.cast);
      expect(items[0].visible, isFalse);
      expect(items[0].placement, PlayerControlPlacement.topRight);
      expect(items[1].button, PlayerControlButton.speed);
      expect(items[1].placement, PlayerControlPlacement.bottom);
    },
  );

  test('malformed data falls back to defaults', () async {
    final container = await _container({
      PlayerControlsLayoutNotifier.fullscreenKey: '{"not": "a list"}',
    });
    expect(
      container
          .read(fullscreenPlayerControlsLayoutProvider)
          .map((i) => i.button),
      PlayerControlButton.values,
    );
  });

  test('edits persist and reset restores defaults', () async {
    final container = await _container({});
    final notifier = container.read(
      inlinePlayerControlsLayoutProvider.notifier,
    );

    await notifier.reorder(6, 0);
    await notifier.update(
      container
          .read(inlinePlayerControlsLayoutProvider)
          .first
          .copyWith(visible: false),
    );
    final prefs = container.read(sharedPreferencesProvider);
    final saved = jsonDecode(
      prefs.getString(PlayerControlsLayoutNotifier.inlineKey)!,
    ) as List;
    expect(saved.first, {
      'id': 'fullscreen',
      'visible': false,
      'placement': 'bottom',
    });

    await notifier.reset();
    expect(prefs.getString(PlayerControlsLayoutNotifier.inlineKey), isNull);
    expect(
      container.read(inlinePlayerControlsLayoutProvider).first.button,
      PlayerControlButton.stream,
    );
  });
}
