import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/data/preferences/secure_storage_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';

class AppLockSettings {
  final bool enabled;
  final int backgroundLockSeconds;
  final bool lockOnLaunch;
  final bool hasPasscode;

  /// Offer the system biometric prompt before the passcode on the lock screen.
  final bool biometricEnabled;

  const AppLockSettings({
    this.enabled = false,
    this.backgroundLockSeconds = 0,
    this.lockOnLaunch = false,
    this.hasPasscode = false,
    this.biometricEnabled = false,
  });

  AppLockSettings copyWith({
    bool? enabled,
    int? backgroundLockSeconds,
    bool? lockOnLaunch,
    bool? hasPasscode,
    bool? biometricEnabled,
  }) {
    return AppLockSettings(
      enabled: enabled ?? this.enabled,
      backgroundLockSeconds:
          backgroundLockSeconds ?? this.backgroundLockSeconds,
      lockOnLaunch: lockOnLaunch ?? this.lockOnLaunch,
      hasPasscode: hasPasscode ?? this.hasPasscode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}

class AppLockSettingsNotifier extends Notifier<AppLockSettings> {
  static const _enabledKey = 'app_lock_enabled';
  static const _backgroundLockSecondsKey = 'app_lock_background_seconds';
  static const _lockOnLaunchKey = 'app_lock_on_launch';
  static const _passcodeKey = 'app_lock_passcode';
  static const _biometricKey = 'app_lock_biometric';

  @override
  AppLockSettings build() {
    unawaited(_load());
    return const AppLockSettings();
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final storage = ref.read(secureStorageProvider);
    final savedPasscode = await storage.read(key: _passcodeKey);

    state = state.copyWith(
      enabled: prefs.getBool(_enabledKey) ?? false,
      backgroundLockSeconds: prefs.getInt(_backgroundLockSecondsKey) ?? 0,
      lockOnLaunch: prefs.getBool(_lockOnLaunchKey) ?? false,
      hasPasscode: (savedPasscode ?? '').isNotEmpty,
      biometricEnabled: prefs.getBool(_biometricKey) ?? false,
    );
  }

  Future<bool> verifyPasscode(String input) async {
    final storage = ref.read(secureStorageProvider);
    final savedPasscode = await storage.read(key: _passcodeKey);
    return savedPasscode != null && savedPasscode == input;
  }

  Future<void> setPasscode(String passcode) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _passcodeKey, value: passcode);
    state = state.copyWith(hasPasscode: true);
  }

  Future<void> clearPasscode() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: _passcodeKey);
    await setEnabled(false);
    state = state.copyWith(hasPasscode: false);
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_enabledKey, enabled);
    state = state.copyWith(enabled: enabled);
  }

  Future<void> setBackgroundLockSeconds(int seconds) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_backgroundLockSecondsKey, seconds);
    state = state.copyWith(backgroundLockSeconds: seconds);
  }

  Future<void> setLockOnLaunch(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_lockOnLaunchKey, enabled);
    state = state.copyWith(lockOnLaunch: enabled);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_biometricKey, enabled);
    state = state.copyWith(biometricEnabled: enabled);
  }
}

final appLockSettingsProvider =
    NotifierProvider<AppLockSettingsNotifier, AppLockSettings>(
      AppLockSettingsNotifier.new,
    );
