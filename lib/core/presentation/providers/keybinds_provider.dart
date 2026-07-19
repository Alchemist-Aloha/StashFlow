import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum KeybindContext { global, video, image }

enum KeybindAction {
  playPause,
  seekForward,
  seekBackward,
  seekForwardLarge,
  seekBackwardLarge,
  volumeUp,
  volumeDown,
  toggleMute,
  toggleFullscreen,
  togglePip,
  nextScene,
  previousScene,
  speedUp,
  speedDown,
  resetSpeed,
  closePlayer,
  nextImage,
  previousImage,
  back,
  nextTab,
  previousTab,
  tab1,
  tab2,
  tab3,
  tab4,
  tab5,
  tab6,
  tab7,
  tab8,
  tab9,
  firstImage,
  lastImage,
  closeImage,
}

extension KeybindActionContext on KeybindAction {
  KeybindContext get context => switch (this) {
    KeybindAction.back ||
    KeybindAction.nextTab ||
    KeybindAction.previousTab ||
    KeybindAction.tab1 ||
    KeybindAction.tab2 ||
    KeybindAction.tab3 ||
    KeybindAction.tab4 ||
    KeybindAction.tab5 ||
    KeybindAction.tab6 ||
    KeybindAction.tab7 ||
    KeybindAction.tab8 ||
    KeybindAction.tab9 => KeybindContext.global,
    KeybindAction.nextImage ||
    KeybindAction.previousImage ||
    KeybindAction.firstImage ||
    KeybindAction.lastImage ||
    KeybindAction.closeImage => KeybindContext.image,
    _ => KeybindContext.video,
  };
}

class Keybind {
  final LogicalKeyboardKey key;
  final bool control;
  final bool shift;
  final bool alt;
  final bool meta;

  const Keybind(
    this.key, {
    this.control = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });

  Map<String, dynamic> toJson() => {
    'keyId': key.keyId,
    'control': control,
    'shift': shift,
    'alt': alt,
    'meta': meta,
  };

  factory Keybind.fromJson(Map<String, dynamic> json) {
    final keyId = json['keyId'];
    if (keyId is! int) throw const FormatException('Invalid keyId');

    return Keybind(
      LogicalKeyboardKey(keyId),
      control: _readBool(json, 'control'),
      shift: _readBool(json, 'shift'),
      alt: _readBool(json, 'alt'),
      meta: _readBool(json, 'meta'),
    );
  }

  static bool _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return false;
    if (value is! bool) throw FormatException('Invalid $key');
    return value;
  }

  SingleActivator toActivator() => SingleActivator(
    key,
    control: control,
    shift: shift,
    alt: alt,
    meta: meta,
  );

  String get label {
    final List<String> parts = [];
    if (control) parts.add('Ctrl');
    if (shift) parts.add('Shift');
    if (alt) {
      parts.add(
        defaultTargetPlatform == TargetPlatform.macOS ? 'Option' : 'Alt',
      );
    }
    if (meta) {
      parts.add(defaultTargetPlatform == TargetPlatform.macOS ? 'Cmd' : 'Meta');
    }

    if (key == LogicalKeyboardKey.space) {
      parts.add('Space');
    } else if (key.keyLabel.trim().isEmpty) {
      // Fallback for keys with empty labels (like some function keys or special keys)
      parts.add(key.debugName ?? 'Unknown');
    } else {
      parts.add(key.keyLabel);
    }

    return parts.join(' + ');
  }

  @override
  bool operator ==(Object other) =>
      other is Keybind &&
      key == other.key &&
      control == other.control &&
      shift == other.shift &&
      alt == other.alt &&
      meta == other.meta;

  @override
  int get hashCode => Object.hash(key, control, shift, alt, meta);
}

class Keybinds {
  final Map<KeybindAction, Keybind> binds;

  Keybinds(this.binds);

  static Map<KeybindAction, Keybind> get defaultBinds => {
    KeybindAction.playPause: const Keybind(LogicalKeyboardKey.space),
    KeybindAction.seekForward: const Keybind(LogicalKeyboardKey.arrowRight),
    KeybindAction.seekBackward: const Keybind(LogicalKeyboardKey.arrowLeft),
    KeybindAction.seekForwardLarge: const Keybind(LogicalKeyboardKey.keyL),
    KeybindAction.seekBackwardLarge: const Keybind(LogicalKeyboardKey.keyJ),
    KeybindAction.volumeUp: const Keybind(LogicalKeyboardKey.arrowUp),
    KeybindAction.volumeDown: const Keybind(LogicalKeyboardKey.arrowDown),
    KeybindAction.toggleMute: const Keybind(LogicalKeyboardKey.keyM),
    KeybindAction.toggleFullscreen: const Keybind(LogicalKeyboardKey.keyF),
    KeybindAction.togglePip: const Keybind(LogicalKeyboardKey.keyP),
    KeybindAction.nextScene: const Keybind(
      LogicalKeyboardKey.keyN,
      shift: true,
    ),
    KeybindAction.previousScene: const Keybind(
      LogicalKeyboardKey.keyP,
      shift: true,
    ),
    KeybindAction.speedUp: const Keybind(LogicalKeyboardKey.bracketRight),
    KeybindAction.speedDown: const Keybind(LogicalKeyboardKey.bracketLeft),
    KeybindAction.resetSpeed: const Keybind(LogicalKeyboardKey.backspace),
    KeybindAction.closePlayer: const Keybind(LogicalKeyboardKey.escape),
    KeybindAction.nextImage: const Keybind(LogicalKeyboardKey.arrowRight),
    KeybindAction.previousImage: const Keybind(LogicalKeyboardKey.arrowLeft),
    KeybindAction.back: const Keybind(LogicalKeyboardKey.arrowLeft, alt: true),
    KeybindAction.nextTab: const Keybind(LogicalKeyboardKey.tab, control: true),
    KeybindAction.previousTab: const Keybind(
      LogicalKeyboardKey.tab,
      control: true,
      shift: true,
    ),
    KeybindAction.tab1: const Keybind(LogicalKeyboardKey.digit1, control: true),
    KeybindAction.tab2: const Keybind(LogicalKeyboardKey.digit2, control: true),
    KeybindAction.tab3: const Keybind(LogicalKeyboardKey.digit3, control: true),
    KeybindAction.tab4: const Keybind(LogicalKeyboardKey.digit4, control: true),
    KeybindAction.tab5: const Keybind(LogicalKeyboardKey.digit5, control: true),
    KeybindAction.tab6: const Keybind(LogicalKeyboardKey.digit6, control: true),
    KeybindAction.tab7: const Keybind(LogicalKeyboardKey.digit7, control: true),
    KeybindAction.tab8: const Keybind(LogicalKeyboardKey.digit8, control: true),
    KeybindAction.tab9: const Keybind(LogicalKeyboardKey.digit9, control: true),
    KeybindAction.firstImage: const Keybind(LogicalKeyboardKey.home),
    KeybindAction.lastImage: const Keybind(LogicalKeyboardKey.end),
    KeybindAction.closeImage: const Keybind(LogicalKeyboardKey.escape),
  };

  Map<String, dynamic> toJson() {
    return {
      for (final action in KeybindAction.values)
        action.name: binds[action]?.toJson(),
    };
  }

  factory Keybinds.fromJson(Map<String, dynamic> json) {
    final Map<KeybindAction, Keybind> loadedBinds = {};
    for (var action in KeybindAction.values) {
      if (json.containsKey(action.name) && json[action.name] == null) continue;
      final saved = json[action.name];
      if (saved is Map) {
        try {
          loadedBinds[action] = Keybind.fromJson(
            Map<String, dynamic>.from(saved),
          );
          continue;
        } on FormatException {
          // Fall through to this action's default without losing other binds.
        }
      }
      loadedBinds[action] = defaultBinds[action]!;
    }
    return Keybinds(loadedBinds);
  }
}

bool _contextsOverlap(KeybindAction a, KeybindAction b) =>
    a.context == b.context ||
    a.context == KeybindContext.global ||
    b.context == KeybindContext.global;

KeyEventResult dispatchKeybindEvent(
  KeyEvent event,
  Map<ShortcutActivator, VoidCallback> bindings,
) {
  var result = KeyEventResult.ignored;
  for (final entry in bindings.entries) {
    if (entry.key.accepts(event, HardwareKeyboard.instance)) {
      entry.value();
      result = KeyEventResult.handled;
    }
  }
  return result;
}

class KeybindsNotifier extends Notifier<Keybinds> {
  int _revision = 0;

  @override
  Keybinds build() {
    _load();
    return Keybinds(Keybinds.defaultBinds);
  }

  Future<void> _load() async {
    final revision = _revision;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('desktop_keybinds');
    if (jsonStr != null && revision == _revision) {
      try {
        state = Keybinds.fromJson(json.decode(jsonStr));
      } catch (_) {}
    }
  }

  Future<List<KeybindAction>> setBind(
    KeybindAction action,
    Keybind bind,
  ) async {
    _revision++;
    final newBinds = Map<KeybindAction, Keybind>.from(state.binds);
    final displaced = <KeybindAction>[];
    newBinds.removeWhere((other, existing) {
      final conflict =
          other != action &&
          existing == bind &&
          _contextsOverlap(action, other);
      if (conflict) displaced.add(other);
      return conflict;
    });
    newBinds[action] = bind;
    state = Keybinds(newBinds);
    await _save();
    return displaced;
  }

  Future<void> unbind(KeybindAction action) async {
    _revision++;
    final newBinds = Map<KeybindAction, Keybind>.from(state.binds)
      ..remove(action);
    state = Keybinds(newBinds);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('desktop_keybinds', json.encode(state.toJson()));
  }

  Future<void> resetToDefaults() async {
    _revision++;
    state = Keybinds(Keybinds.defaultBinds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('desktop_keybinds');
  }
}

final keybindsProvider = NotifierProvider<KeybindsNotifier, Keybinds>(() {
  return KeybindsNotifier();
});
