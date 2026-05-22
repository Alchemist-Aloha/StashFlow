import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSecureStorage {
  AppSecureStorage({
    FlutterSecureStorage? secureStorage,
    SharedPreferences? sharedPreferences,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _sharedPreferences = sharedPreferences;

  static const String _fallbackPrefix = 'secure_fallback_';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences? _sharedPreferences;
  SharedPreferences? _lazyPrefs;

  Future<String?> read({required String key}) async {
    try {
      return await _secureStorage.read(key: key);
    } on PlatformException catch (e) {
      if (!_shouldFallback(e)) rethrow;
      final prefs = await _resolvePrefs();
      return prefs?.getString('$_fallbackPrefix$key');
    }
  }

  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      return delete(key: key);
    }
    try {
      await _secureStorage.write(key: key, value: value);
      return;
    } on PlatformException catch (e) {
      if (!_shouldFallback(e)) rethrow;
      final prefs = await _resolvePrefs();
      await prefs?.setString('$_fallbackPrefix$key', value);
    }
  }

  Future<void> delete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
    } on PlatformException catch (e) {
      if (!_shouldFallback(e)) rethrow;
    }
    final prefs = await _resolvePrefs();
    await prefs?.remove('$_fallbackPrefix$key');
  }

  bool _shouldFallback(PlatformException e) {
    if (e.code == '-34018') return true;
    final message = (e.message ?? '').toLowerCase();
    return message.contains('required entitlement') ||
        message.contains('unexpected security result code');
  }

  Future<SharedPreferences?> _resolvePrefs() async {
    if (_sharedPreferences != null) return _sharedPreferences;
    _lazyPrefs ??= await SharedPreferences.getInstance();
    return _lazyPrefs;
  }
}

final secureStorageProvider = Provider<AppSecureStorage>((ref) {
  return AppSecureStorage();
});
