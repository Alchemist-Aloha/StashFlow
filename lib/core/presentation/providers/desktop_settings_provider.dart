import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DesktopSettings {
  final double volume;
  final bool isMuted;

  DesktopSettings({this.volume = 1.0, this.isMuted = false});

  DesktopSettings copyWith({double? volume, bool? isMuted}) {
    return DesktopSettings(
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class DesktopSettingsNotifier extends Notifier<DesktopSettings> {
  @override
  DesktopSettings build() {
    _loadSettings();
    return DesktopSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      volume: prefs.getDouble('desktop_volume') ?? 1.0,
      isMuted: prefs.getBool('desktop_is_muted') ?? false,
    );
  }

  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: clampedVolume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('desktop_volume', clampedVolume);
  }

  Future<void> toggleMute() async {
    final newMute = !state.isMuted;
    state = state.copyWith(isMuted: newMute);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('desktop_is_muted', newMute);
  }
}

final desktopSettingsProvider =
    NotifierProvider<DesktopSettingsNotifier, DesktopSettings>(() {
      return DesktopSettingsNotifier();
    });
