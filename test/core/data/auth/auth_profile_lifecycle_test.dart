import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
import 'package:stash_app_flutter/core/data/auth/auth_provider.dart';
import 'package:stash_app_flutter/core/data/auth/auth_service.dart';
import 'package:stash_app_flutter/core/data/preferences/secure_storage_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/setup/domain/models/server_profile.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/server_profiles_provider.dart';

const profileA = ServerProfile(
  id: 'a',
  baseUrl: 'http://server-a/graphql',
  authMode: AuthMode.password,
);
const profileB = ServerProfile(
  id: 'b',
  baseUrl: 'http://server-b/graphql',
  authMode: AuthMode.password,
);

class ProfileSelection extends Notifier<ServerProfile> {
  @override
  ServerProfile build() => profileA;

  void select(ServerProfile profile) => state = profile;
}

final selectionProvider = NotifierProvider<ProfileSelection, ServerProfile>(
  ProfileSelection.new,
);

class DelayedStorage extends AppSecureStorage {
  final values = <String, String>{
    'profile_a_username': 'alice',
    'profile_a_password': 'secret-a',
    'profile_a_cookie_header': 'session=A',
    'profile_b_username': 'bob',
    'profile_b_password': 'secret-b',
    'profile_b_cookie_header': 'session=B',
  };
  String? blockedKey;
  final gate = Completer<void>();

  @override
  Future<String?> read({required String key}) async {
    final value = values[key];
    if (key == blockedKey) await gate.future;
    return value;
  }

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({required String key}) async => values.remove(key);
}

class DelayedLoginService extends AuthService {
  DelayedLoginService() : super(dio: Dio(), cookieJar: CookieJar());

  final response = Completer<bool>();
  final requests = <(Uri, String, String)>[];

  @override
  Future<bool> login({
    required Uri graphqlEndpoint,
    required String username,
    required String password,
  }) {
    requests.add((graphqlEndpoint, username, password));
    return response.future;
  }
}

Future<void> settle() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late DelayedStorage storage;
  late DelayedLoginService service;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = DelayedStorage();
    service = DelayedLoginService();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStorageProvider.overrideWithValue(storage),
        activeProfileProvider.overrideWith(
          (ref) => ref.watch(selectionProvider),
        ),
        authServiceProvider.overrideWith((ref) async => service),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    service.dio.close(force: true);
  });

  test(
    'late hydration cannot replace the active profile credentials',
    () async {
      storage.blockedKey = 'profile_a_username';
      container.read(authProvider);
      await settle();
      container.read(selectionProvider.notifier).select(profileB);
      container.read(authProvider);
      await settle();
      expect(container.read(authProvider).username, 'bob');

      storage.gate.complete();
      await settle();

      final state = container.read(authProvider);
      expect(state.username, 'bob');
      expect(state.password, 'secret-b');
      expect(state.cookieHeader, 'session=B');
    },
  );

  test('late login response cannot update a different profile', () async {
    container.read(authProvider);
    await settle();
    final login = container.read(authProvider.notifier).login();
    await settle();
    expect(service.requests.single, (
      Uri.parse(profileA.baseUrl),
      'alice',
      'secret-a',
    ));

    container.read(selectionProvider.notifier).select(profileB);
    container.read(authProvider);
    await settle();
    service.response.complete(false);
    expect(await login, false);

    final state = container.read(authProvider);
    expect(state.username, 'bob');
    expect(state.cookieHeader, 'session=B');
    expect(state.loginStatus, AuthLoginStatus.loggedIn);
    expect(state.errorMessage, isNull);
  });

  test('disposed hydration does not access notifier state', () async {
    storage.blockedKey = 'profile_a_username';
    container.read(authProvider);
    await settle();
    container.dispose();
    storage.gate.complete();
    await settle();
  });
}
