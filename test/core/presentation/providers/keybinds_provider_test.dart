import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/providers/keybinds_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('uses common navigation and media defaults', () {
    final binds = Keybinds.defaultBinds;

    expect(
      binds[KeybindAction.back],
      const Keybind(LogicalKeyboardKey.arrowLeft, alt: true),
    );
    expect(
      binds[KeybindAction.nextTab],
      const Keybind(LogicalKeyboardKey.tab, control: true),
    );
    expect(
      binds[KeybindAction.previousTab],
      const Keybind(LogicalKeyboardKey.tab, control: true, shift: true),
    );
    expect(
      binds[KeybindAction.tab1],
      const Keybind(LogicalKeyboardKey.digit1, control: true),
    );
    expect(
      binds[KeybindAction.tab9],
      const Keybind(LogicalKeyboardKey.digit9, control: true),
    );
    expect(
      binds[KeybindAction.nextScene],
      const Keybind(LogicalKeyboardKey.keyN, shift: true),
    );
    expect(
      binds[KeybindAction.previousScene],
      const Keybind(LogicalKeyboardKey.keyP, shift: true),
    );
    expect(
      binds[KeybindAction.firstImage],
      const Keybind(LogicalKeyboardKey.home),
    );
    expect(
      binds[KeybindAction.lastImage],
      const Keybind(LogicalKeyboardKey.end),
    );
  });

  test('missing and malformed entries fall back independently', () {
    final loaded = Keybinds.fromJson({
      KeybindAction.playPause.name: {'keyId': 'invalid'},
      KeybindAction.toggleMute.name: {
        'keyId': LogicalKeyboardKey.keyX.keyId,
        'control': false,
        'shift': false,
        'alt': false,
        'meta': false,
      },
    });

    expect(
      loaded.binds[KeybindAction.playPause],
      Keybinds.defaultBinds[KeybindAction.playPause],
    );
    expect(
      loaded.binds[KeybindAction.toggleMute],
      const Keybind(LogicalKeyboardKey.keyX),
    );
    expect(
      loaded.binds[KeybindAction.nextTab],
      Keybinds.defaultBinds[KeybindAction.nextTab],
    );
  });

  test('assigning an overlapping shortcut moves it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final displaced = await container
        .read(keybindsProvider.notifier)
        .setBind(
          KeybindAction.nextImage,
          const Keybind(LogicalKeyboardKey.arrowLeft, alt: true),
        );

    expect(displaced, [KeybindAction.back]);
    expect(container.read(keybindsProvider).binds[KeybindAction.back], isNull);
  });

  test('video and image contexts may reuse a shortcut', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final displaced = await container
        .read(keybindsProvider.notifier)
        .setBind(
          KeybindAction.nextImage,
          const Keybind(LogicalKeyboardKey.arrowRight),
        );

    expect(displaced, isEmpty);
    expect(
      container.read(keybindsProvider).binds[KeybindAction.seekForward],
      const Keybind(LogicalKeyboardKey.arrowRight),
    );
  });

  test('unbind persists the missing action', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(keybindsProvider.notifier)
        .unbind(KeybindAction.resetSpeed);

    final prefs = await SharedPreferences.getInstance();
    final saved = json.decode(prefs.getString('desktop_keybinds')!);
    expect(saved, containsPair(KeybindAction.resetSpeed.name, null));
  });
}
