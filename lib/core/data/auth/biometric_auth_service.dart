import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../utils/app_log_store.dart';

/// Wraps the system biometric prompt (fingerprint / face unlock).
///
/// Only Android is supported; every other platform reports unavailable so the
/// app lock falls back to its passcode.
class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  bool get _platformSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Whether the device has biometric hardware with at least one enrollment.
  Future<bool> isAvailable() async {
    if (!_platformSupported) return false;
    try {
      return await _auth.isDeviceSupported() &&
          (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on Exception catch (e, stackTrace) {
      AppLogStore.instance.addError(
        'isAvailable',
        e,
        stackTrace,
        source: 'biometric_auth_service',
      );
      return false;
    }
  }

  /// Shows the system biometric prompt. Returns false on cancel, failure,
  /// lockout, or any platform error so callers can fall back to the passcode.
  Future<bool> authenticate(String reason) async {
    if (!_platformSupported) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on Exception catch (e, stackTrace) {
      AppLogStore.instance.addError(
        'authenticate',
        e,
        stackTrace,
        source: 'biometric_auth_service',
      );
      return false;
    }
  }
}

final biometricAuthServiceProvider = Provider<BiometricAuthService>(
  (ref) => BiometricAuthService(),
);

/// Whether biometric unlock can be offered on this device.
final biometricAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(biometricAuthServiceProvider).isAvailable(),
);
