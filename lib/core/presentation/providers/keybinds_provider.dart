import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    return Keybind(
      LogicalKeyboardKey(json['keyId']),
      control: json['control'] ?? false,
      shift: json['shift'] ?? false,
      alt: json['alt'] ?? false,
      meta: json['meta'] ?? false,
    );
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
    if (alt) parts.add('Alt');
    if (meta) parts.add('Meta');

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
    KeybindAction.nextScene: const Keybind(LogicalKeyboardKey.keyN),
    KeybindAction.previousScene: const Keybind(LogicalKeyboardKey.keyB),
    KeybindAction.speedUp: const Keybind(LogicalKeyboardKey.bracketRight),
    KeybindAction.speedDown: const Keybind(LogicalKeyboardKey.bracketLeft),
    KeybindAction.resetSpeed: const Keybind(LogicalKeyboardKey.backspace),
    KeybindAction.closePlayer: const Keybind(LogicalKeyboardKey.escape),
    KeybindAction.nextImage: const Keybind(LogicalKeyboardKey.arrowRight),
    KeybindAction.previousImage: const Keybind(LogicalKeyboardKey.arrowLeft),
    KeybindAction.back: const Keybind(LogicalKeyboardKey.escape),
  };

  Map<String, dynamic> toJson() {
    return binds.map((key, value) => MapEntry(key.name, value.toJson()));
  }

  factory Keybinds.fromJson(Map<String, dynamic> json) {
    final Map<KeybindAction, Keybind> loadedBinds = {};
    for (var action in KeybindAction.values) {
      if (json.containsKey(action.name)) {
        loadedBinds[action] = Keybind.fromJson(json[action.name]);
      } else if (defaultBinds.containsKey(action)) {
        loadedBinds[action] = defaultBinds[action]!;
      }
    }
    return Keybinds(loadedBinds);
  }
}

class KeybindsNotifier extends Notifier<Keybinds> {
  @override
  Keybinds build() {
    _load();
    return Keybinds(Keybinds.defaultBinds);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('desktop_keybinds');
    if (jsonStr != null) {
      try {
        state = Keybinds.fromJson(json.decode(jsonStr));
      } catch (_) {}
    }
  }

  Future<void> setBind(KeybindAction action, Keybind bind) async {
    final newBinds = Map<KeybindAction, Keybind>.from(state.binds);
    newBinds[action] = bind;
    state = Keybinds(newBinds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('desktop_keybinds', json.encode(state.toJson()));
  }

  Future<void> resetToDefaults() async {
    state = Keybinds(Keybinds.defaultBinds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('desktop_keybinds');
  }
}

final keybindsProvider = NotifierProvider<KeybindsNotifier, Keybinds>(() {
  return KeybindsNotifier();
});
