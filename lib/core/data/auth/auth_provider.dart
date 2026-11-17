import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/setup/domain/models/server_profile.dart';
import '../../../features/setup/presentation/providers/profile_credentials_provider.dart';
import '../../../features/setup/presentation/providers/server_profiles_provider.dart';
import '../preferences/secure_storage_provider.dart';
import '../preferences/shared_preferences_provider.dart';
import 'auth_mode.dart';
import 'auth_service.dart';
import '../../utils/app_log_store.dart';

enum AuthLoginStatus { loggedOut, loggingIn, loggedIn, error }

class AuthState {
  const AuthState({
    required this.mode,
    required this.username,
    required this.password,
    required this.loginStatus,
    required this.cookieHeader,
    this.errorMessage,
    this.hydrated = false,
  });

  const AuthState.initial()
    : mode = AuthMode.password,
      username = '',
      password = '',
      loginStatus = AuthLoginStatus.loggedOut,
      cookieHeader = '',
      errorMessage = null,
      hydrated = false;

  final AuthMode mode;
  final String username;
  final String password;
  final AuthLoginStatus loginStatus;
  final String cookieHeader;
  final String? errorMessage;
  final bool hydrated;

  AuthState copyWith({
    AuthMode? mode,
    String? username,
    String? password,
    AuthLoginStatus? loginStatus,
    String? cookieHeader,
    String? errorMessage,
    bool clearError = false,
    bool? hydrated,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      username: username ?? this.username,
      password: password ?? this.password,
      loginStatus: loginStatus ?? this.loginStatus,
      cookieHeader: cookieHeader ?? this.cookieHeader,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hydrated: hydrated ?? this.hydrated,
    );
  }
}

final authServiceProvider = FutureProvider<AuthService>((ref) async {
  return AuthService.create(profile: ref.watch(activeProfileProvider));
});

final authProvider = NotifierProvider<AuthProvider, AuthState>(
  AuthProvider.new,
);

class AuthProvider extends Notifier<AuthState> {
  int _generation = 0;
  Future<void> _hydration = Future.value();
  Future<bool>? _loginFuture;

  void _credentialsChanged() {
    _generation++;
    _loginFuture = null;
  }

  bool _isCurrent(int generation, ServerProfile profile) =>
      ref.mounted &&
      generation == _generation &&
      ref.read(activeProfileProvider) == profile;

  String _getAuthModeKey(String profileId) => 'profile_${profileId}_auth_mode';
  String _getUsernameKey(String profileId) => 'profile_${profileId}_username';
  String _getPasswordKey(String profileId) => 'profile_${profileId}_password';
  String _getCookieHeaderKey(String profileId) =>
      'profile_${profileId}_cookie_header';

  @override
  AuthState build() {
    final profile = ref.watch(activeProfileProvider);
    final generation = ++_generation;
    _loginFuture = null;
    ref.onDispose(() => _generation++);
    if (profile == null) {
      return const AuthState.initial().copyWith(hydrated: true);
    }
    _hydration = _hydrateForProfile(profile, generation);
    unawaited(_hydration);
    return const AuthState.initial();
  }

  Future<void> _hydrateForProfile(ServerProfile profile, int generation) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final secureStorage = ref.read(secureStorageProvider);

    final modeRaw = prefs.getString(_getAuthModeKey(profile.id));
    final mode = AuthMode.values.firstWhere(
      (e) => e.name == modeRaw,
      orElse: () => profile.authMode,
    );

    final username =
        await secureStorage.read(key: _getUsernameKey(profile.id)) ?? '';
    final password =
        await secureStorage.read(key: _getPasswordKey(profile.id)) ?? '';
    if (!_isCurrent(generation, profile)) return;

    final loginStatus = mode == AuthMode.basic || mode == AuthMode.bearer
        ? AuthLoginStatus.loggedIn
        : AuthLoginStatus.loggedOut;
    state = state.copyWith(
      mode: mode,
      username: username,
      password: password,
      loginStatus: loginStatus,
      cookieHeader: '',
      hydrated: true,
      clearError: true,
    );
    // A serialized Cookie header has no expiry or server-side validity metadata.
    if (mode == AuthMode.password &&
        username.isNotEmpty &&
        password.isNotEmpty) {
      unawaited(login());
    }
  }

  Future<void> setMode(AuthMode mode) async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    final generation = _generation;
    await _hydration;
    if (!_isCurrent(generation, profile)) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_getAuthModeKey(profile.id), mode.name);
    if (!_isCurrent(generation, profile)) return;

    if (state.mode != mode) _credentialsChanged();
    AuthLoginStatus loginStatus = state.loginStatus;
    if (mode == AuthMode.apiKey) {
      loginStatus = AuthLoginStatus.loggedOut;
    } else if (mode == AuthMode.basic || mode == AuthMode.bearer) {
      loginStatus = AuthLoginStatus.loggedIn;
    }

    state = state.copyWith(
      mode: mode,
      loginStatus: loginStatus,
      clearError: true,
    );
  }

  Future<void> updateUsername(String username) async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    final generation = _generation;
    await _hydration;
    if (!_isCurrent(generation, profile)) return;
    final secureStorage = ref.read(secureStorageProvider);
    final trimmed = username.trim();

    if (trimmed.isEmpty) {
      await secureStorage.delete(key: _getUsernameKey(profile.id));
    } else {
      await secureStorage.write(
        key: _getUsernameKey(profile.id),
        value: trimmed,
      );
    }

    if (!_isCurrent(generation, profile)) return;
    if (state.username != trimmed) _credentialsChanged();
    state = state.copyWith(username: trimmed, clearError: true);
  }

  Future<void> updatePassword(String password) async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    final generation = _generation;
    await _hydration;
    if (!_isCurrent(generation, profile)) return;
    final secureStorage = ref.read(secureStorageProvider);

    if (password.isEmpty) {
      await secureStorage.delete(key: _getPasswordKey(profile.id));
    } else {
      await secureStorage.write(
        key: _getPasswordKey(profile.id),
        value: password,
      );
    }

    if (!_isCurrent(generation, profile)) return;
    if (state.password != password) _credentialsChanged();
    state = state.copyWith(password: password, clearError: true);
  }

  /// Waits for stored credentials and shares an in-flight attempt for this revision.
  Future<bool> login() {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return Future.value(false);
    return _loginFuture ??= _loginWhenReady(profile, _generation);
  }

  Future<bool> _loginWhenReady(ServerProfile profile, int generation) async {
    try {
      await _hydration;
      if (!_isCurrent(generation, profile)) return false;
      return await _login(profile, generation);
    } finally {
      if (ref.mounted && generation == _generation) _loginFuture = null;
    }
  }

  Future<bool> _login(ServerProfile profile, int generation) async {
    if (state.mode != AuthMode.password) {
      return false;
    }

    final endpoint = profile.baseUrl.trim();
    if (endpoint.isEmpty) {
      state = state.copyWith(
        loginStatus: AuthLoginStatus.error,
        errorMessage: 'Server URL is not configured.',
      );
      return false;
    }

    if (state.username.trim().isEmpty || state.password.isEmpty) {
      state = state.copyWith(
        loginStatus: AuthLoginStatus.error,
        errorMessage: 'Username and password are required.',
      );
      return false;
    }

    final username = state.username;
    final password = state.password;
    state = state.copyWith(
      loginStatus: AuthLoginStatus.loggingIn,
      cookieHeader: '',
      clearError: true,
    );
    debugPrint('AuthProvider: Initiating login process...');

    try {
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.delete(key: _getCookieHeaderKey(profile.id));
      if (!_isCurrent(generation, profile)) return false;
      ref.invalidate(profileCookieHeaderProvider(profile.id));
      final service = await ref.read(authServiceProvider.future);
      if (!_isCurrent(generation, profile)) return false;
      final endpointUri = Uri.parse(endpoint);
      final ok = await service.login(
        graphqlEndpoint: endpointUri,
        username: username,
        password: password,
      );
      if (!_isCurrent(generation, profile)) return false;

      if (!ok) {
        debugPrint(
          'AuthProvider: Login failed (invalid credentials or server error).',
        );
        state = state.copyWith(
          loginStatus: AuthLoginStatus.error,
          errorMessage: 'Invalid username or password.',
        );
        return false;
      }

      final cookieHeader = await service.cookieHeaderFor(
        requestUri: endpointUri,
      );
      if (!_isCurrent(generation, profile)) return false;
      debugPrint(
        'AuthProvider: Cookie header acquired: ${cookieHeader.isNotEmpty}',
      );
      if (cookieHeader.isEmpty) {
        await secureStorage.delete(key: _getCookieHeaderKey(profile.id));
      } else {
        await secureStorage.write(
          key: _getCookieHeaderKey(profile.id),
          value: cookieHeader,
        );
      }
      if (!_isCurrent(generation, profile)) return false;
      ref.invalidate(profileCookieHeaderProvider(profile.id));

      state = state.copyWith(
        cookieHeader: cookieHeader,
        loginStatus: cookieHeader.isEmpty
            ? AuthLoginStatus.loggedOut
            : AuthLoginStatus.loggedIn,
        clearError: true,
      );

      return cookieHeader.isNotEmpty;
    } on Object catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'login',
        error,
        stackTrace,
        source: 'auth_provider',
      );
      // Auth recovery must also handle storage and provider failures.
      if (!_isCurrent(generation, profile)) return false;
      state = state.copyWith(
        loginStatus: AuthLoginStatus.error,
        errorMessage: 'Login failed: $error',
      );
      return false;
    }
  }

  Future<void> logout() async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    var generation = _generation;
    await _hydration;
    if (!_isCurrent(generation, profile)) return;
    _credentialsChanged();
    generation = _generation;
    final endpoint = profile.baseUrl.trim();
    final secureStorage = ref.read(secureStorageProvider);

    if (endpoint.isNotEmpty) {
      try {
        final service = await ref.read(authServiceProvider.future);
        if (!_isCurrent(generation, profile)) return;
        await service.logout(graphqlEndpoint: Uri.parse(endpoint));
      } on Object catch (error, stackTrace) {
        AppLogStore.instance.addError(
          'logout',
          error,
          stackTrace,
          source: 'auth_provider',
        );
        // Auth recovery must also handle storage and provider failures.
        // Always clear local auth state even if endpoint call fails.
      }
    }

    await secureStorage.delete(key: _getCookieHeaderKey(profile.id));
    if (!_isCurrent(generation, profile)) return;
    state = state.copyWith(
      cookieHeader: '',
      loginStatus: AuthLoginStatus.loggedOut,
      clearError: true,
    );
  }

  Future<String> refreshCookieHeader() async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return '';

    final generation = _generation;
    final cookieHeader = await _refreshCookieHeaderForProfile(profile);
    if (!_isCurrent(generation, profile)) return '';
    final secureStorage = ref.read(secureStorageProvider);

    if (cookieHeader.isEmpty) {
      await secureStorage.delete(key: _getCookieHeaderKey(profile.id));
    } else {
      await secureStorage.write(
        key: _getCookieHeaderKey(profile.id),
        value: cookieHeader,
      );
    }
    if (!_isCurrent(generation, profile)) return '';
    ref.invalidate(profileCookieHeaderProvider(profile.id));

    state = state.copyWith(
      cookieHeader: cookieHeader,
      loginStatus: cookieHeader.isEmpty
          ? AuthLoginStatus.loggedOut
          : AuthLoginStatus.loggedIn,
      clearError: true,
    );

    return cookieHeader;
  }

  Future<String> _refreshCookieHeaderForProfile(ServerProfile profile) async {
    final endpoint = profile.baseUrl.trim();
    if (endpoint.isEmpty) {
      return '';
    }

    try {
      final service = await ref.read(authServiceProvider.future);
      return await service.cookieHeaderFor(requestUri: Uri.parse(endpoint));
    } on Object catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'refreshCookieHeaderForProfile',
        error,
        stackTrace,
        source: 'auth_provider',
      );
      // Auth recovery must also handle storage and provider failures.
      return '';
    }
  }
}
