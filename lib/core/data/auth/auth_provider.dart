import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences/secure_storage_provider.dart';
import '../preferences/shared_preferences_provider.dart';
import 'auth_mode.dart';
import 'auth_service.dart';

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
  return AuthService.create();
});

final authProvider = NotifierProvider<AuthProvider, AuthState>(
  AuthProvider.new,
);

class AuthProvider extends Notifier<AuthState> {
  static const _authModePrefKey = 'auth_mode';
  static const _usernameKey = 'server_username';
  static const _passwordKey = 'server_password';
  static const _cookieHeaderKey = 'server_cookie_header';

  @override
  AuthState build() {
    _hydrate();
    return const AuthState.initial();
  }

  Future<void> _hydrate() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final secureStorage = ref.read(secureStorageProvider);

    final modeRaw = prefs.getString(_authModePrefKey);
    final mode = AuthMode.values.firstWhere(
      (e) => e.name == modeRaw,
      orElse: () => AuthMode.apiKey,
    );

    final username = await secureStorage.read(key: _usernameKey) ?? '';
    final password = await secureStorage.read(key: _passwordKey) ?? '';
    final storedCookieHeader =
        await secureStorage.read(key: _cookieHeaderKey) ?? '';

    String cookieHeader = storedCookieHeader;
    AuthLoginStatus loginStatus = AuthLoginStatus.loggedOut;

    if (mode == AuthMode.password) {
      if (cookieHeader.isEmpty) {
        cookieHeader = await _refreshCookieHeader();
      }
      loginStatus = cookieHeader.isNotEmpty
          ? AuthLoginStatus.loggedIn
          : AuthLoginStatus.loggedOut;
    } else if (mode == AuthMode.basic || mode == AuthMode.bearer) {
      loginStatus = AuthLoginStatus.loggedIn;
    }

    state = state.copyWith(
      mode: mode,
      username: username,
      password: password,
      loginStatus: loginStatus,
      cookieHeader: cookieHeader,
      hydrated: true,
      clearError: true,
    );
  }

  Future<void> setMode(AuthMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_authModePrefKey, mode.name);

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
    final secureStorage = ref.read(secureStorageProvider);
    final trimmed = username.trim();

    if (trimmed.isEmpty) {
      await secureStorage.delete(key: _usernameKey);
    } else {
      await secureStorage.write(key: _usernameKey, value: trimmed);
    }

    state = state.copyWith(username: trimmed, clearError: true);
  }

  Future<void> updatePassword(String password) async {
    final secureStorage = ref.read(secureStorageProvider);

    if (password.isEmpty) {
      await secureStorage.delete(key: _passwordKey);
    } else {
      await secureStorage.write(key: _passwordKey, value: password);
    }

    state = state.copyWith(password: password, clearError: true);
  }

  Future<bool> login() async {
    if (state.mode != AuthMode.password) {
      return false;
    }

    final endpoint = _readServerUrl();
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

    state = state.copyWith(
      loginStatus: AuthLoginStatus.loggingIn,
      clearError: true,
    );

    try {
      final service = await ref.read(authServiceProvider.future);
      final endpointUri = Uri.parse(endpoint);
      final ok = await service.login(
        graphqlEndpoint: endpointUri,
        username: state.username,
        password: state.password,
      );

      if (!ok) {
        state = state.copyWith(
          loginStatus: AuthLoginStatus.error,
          errorMessage: 'Invalid username or password.',
        );
        return false;
      }

      final cookieHeader = await service.cookieHeaderFor(
        requestUri: endpointUri,
      );
      final secureStorage = ref.read(secureStorageProvider);
      if (cookieHeader.isEmpty) {
        await secureStorage.delete(key: _cookieHeaderKey);
      } else {
        await secureStorage.write(key: _cookieHeaderKey, value: cookieHeader);
      }

      state = state.copyWith(
        cookieHeader: cookieHeader,
        loginStatus: cookieHeader.isEmpty
            ? AuthLoginStatus.loggedOut
            : AuthLoginStatus.loggedIn,
        clearError: true,
      );

      return cookieHeader.isNotEmpty;
    } catch (error) {
      state = state.copyWith(
        loginStatus: AuthLoginStatus.error,
        errorMessage: 'Login failed: $error',
      );
      return false;
    }
  }

  Future<void> logout() async {
    final endpoint = _readServerUrl();
    final secureStorage = ref.read(secureStorageProvider);

    if (endpoint.isNotEmpty) {
      try {
        final service = await ref.read(authServiceProvider.future);
        await service.logout(graphqlEndpoint: Uri.parse(endpoint));
      } catch (_) {
        // Always clear local auth state even if endpoint call fails.
      }
    }

    await secureStorage.delete(key: _cookieHeaderKey);
    state = state.copyWith(
      cookieHeader: '',
      loginStatus: AuthLoginStatus.loggedOut,
      clearError: true,
    );
  }

  Future<String> refreshCookieHeader() async {
    final cookieHeader = await _refreshCookieHeader();
    final secureStorage = ref.read(secureStorageProvider);

    if (cookieHeader.isEmpty) {
      await secureStorage.delete(key: _cookieHeaderKey);
    } else {
      await secureStorage.write(key: _cookieHeaderKey, value: cookieHeader);
    }

    state = state.copyWith(
      cookieHeader: cookieHeader,
      loginStatus: cookieHeader.isEmpty
          ? AuthLoginStatus.loggedOut
          : AuthLoginStatus.loggedIn,
      clearError: true,
    );

    return cookieHeader;
  }

  Future<String> _refreshCookieHeader() async {
    final endpoint = _readServerUrl();
    if (endpoint.isEmpty) {
      return '';
    }

    try {
      final service = await ref.read(authServiceProvider.future);
      return service.cookieHeaderFor(requestUri: Uri.parse(endpoint));
    } catch (_) {
      return '';
    }
  }

  String _readServerUrl() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString('server_base_url')?.trim() ?? '';
  }
}
