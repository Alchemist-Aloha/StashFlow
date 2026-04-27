import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/setup/domain/models/server_profile.dart';
import '../../../features/setup/presentation/providers/server_profiles_provider.dart';
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
  String _getAuthModeKey(String profileId) => 'profile_${profileId}_auth_mode';
  String _getUsernameKey(String profileId) => 'profile_${profileId}_username';
  String _getPasswordKey(String profileId) => 'profile_${profileId}_password';
  String _getCookieHeaderKey(String profileId) =>
      'profile_${profileId}_cookie_header';

  @override
  AuthState build() {
    final profile = ref.watch(activeProfileProvider);
    _hydrateForProfile(profile);
    return const AuthState.initial();
  }

  Future<void> _hydrateForProfile(ServerProfile? profile) async {
    if (profile == null) {
      state = const AuthState.initial().copyWith(hydrated: true);
      return;
    }

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
    final storedCookieHeader =
        await secureStorage.read(key: _getCookieHeaderKey(profile.id)) ?? '';

    String cookieHeader = storedCookieHeader;
    AuthLoginStatus loginStatus = AuthLoginStatus.loggedOut;

    if (mode == AuthMode.password) {
      if (cookieHeader.isEmpty) {
        cookieHeader = await _refreshCookieHeaderForProfile(profile);
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
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_getAuthModeKey(profile.id), mode.name);

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

    final secureStorage = ref.read(secureStorageProvider);
    final trimmed = username.trim();

    if (trimmed.isEmpty) {
      await secureStorage.delete(key: _getUsernameKey(profile.id));
    } else {
      await secureStorage.write(key: _getUsernameKey(profile.id), value: trimmed);
    }

    state = state.copyWith(username: trimmed, clearError: true);
  }

  Future<void> updatePassword(String password) async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    final secureStorage = ref.read(secureStorageProvider);

    if (password.isEmpty) {
      await secureStorage.delete(key: _getPasswordKey(profile.id));
    } else {
      await secureStorage.write(key: _getPasswordKey(profile.id), value: password);
    }

    state = state.copyWith(password: password, clearError: true);
  }

  Future<bool> login() async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return false;

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

    state = state.copyWith(
      loginStatus: AuthLoginStatus.loggingIn,
      clearError: true,
    );
    debugPrint('AuthProvider: Initiating login process...');

    try {
      final service = await ref.read(authServiceProvider.future);
      final endpointUri = Uri.parse(endpoint);
      final ok = await service.login(
        graphqlEndpoint: endpointUri,
        username: state.username,
        password: state.password,
      );

      if (!ok) {
        debugPrint('AuthProvider: Login failed (invalid credentials or server error).');
        state = state.copyWith(
          loginStatus: AuthLoginStatus.error,
          errorMessage: 'Invalid username or password.',
        );
        return false;
      }

      final cookieHeader = await service.cookieHeaderFor(
        requestUri: endpointUri,
      );
      debugPrint('AuthProvider: Cookie header acquired: ${cookieHeader.isNotEmpty}');
      final secureStorage = ref.read(secureStorageProvider);
      if (cookieHeader.isEmpty) {
        await secureStorage.delete(key: _getCookieHeaderKey(profile.id));
      } else {
        await secureStorage.write(
            key: _getCookieHeaderKey(profile.id), value: cookieHeader);
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
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;

    final endpoint = profile.baseUrl.trim();
    final secureStorage = ref.read(secureStorageProvider);

    if (endpoint.isNotEmpty) {
      try {
        final service = await ref.read(authServiceProvider.future);
        await service.logout(graphqlEndpoint: Uri.parse(endpoint));
      } catch (_) {
        // Always clear local auth state even if endpoint call fails.
      }
    }

    await secureStorage.delete(key: _getCookieHeaderKey(profile.id));
    state = state.copyWith(
      cookieHeader: '',
      loginStatus: AuthLoginStatus.loggedOut,
      clearError: true,
    );
  }

  Future<String> refreshCookieHeader() async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return '';

    final cookieHeader = await _refreshCookieHeaderForProfile(profile);
    final secureStorage = ref.read(secureStorageProvider);

    if (cookieHeader.isEmpty) {
      await secureStorage.delete(key: _getCookieHeaderKey(profile.id));
    } else {
      await secureStorage.write(
          key: _getCookieHeaderKey(profile.id), value: cookieHeader);
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

  Future<String> _refreshCookieHeaderForProfile(ServerProfile profile) async {
    final endpoint = profile.baseUrl.trim();
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
}
