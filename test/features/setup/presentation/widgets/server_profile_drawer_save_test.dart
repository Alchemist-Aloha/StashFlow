import 'dart:async';
import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
import 'package:stash_app_flutter/core/data/auth/auth_provider.dart';
import 'package:stash_app_flutter/core/data/auth/auth_service.dart';
import 'package:stash_app_flutter/core/data/preferences/secure_storage_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/features/setup/domain/models/server_profile.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/server_profiles_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/server_profile_drawer.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

class MemoryStorage extends AppSecureStorage {
  final values = <String, String>{};

  @override
  Future<String?> read({required String key}) async => values[key];

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

class LoginService extends AuthService {
  LoginService() : super(dio: Dio(), cookieJar: CookieJar());

  Completer<bool>? response;
  final passwords = <String>[];

  @override
  Future<bool> login({
    required Uri graphqlEndpoint,
    required String username,
    required String password,
  }) {
    passwords.add(password);
    return response?.future ?? Future.value(password == 'correct');
  }

  @override
  Future<String> cookieHeaderFor({required Uri requestUri}) async =>
      'session=fresh';
}

void main() {
  late MemoryStorage storage;
  late LoginService service;
  late ProviderContainer container;

  Future<void> openDrawer(
    WidgetTester tester, {
    ServerProfile? profile,
    double scale = 1,
    String language = 'en',
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 1200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({
      if (profile != null) ...{
        'server_profiles': jsonEncode([profile.toJson()]),
        'active_server_profile_id': profile.id,
      },
    });
    final prefs = await SharedPreferences.getInstance();
    storage = MemoryStorage();
    service = LoginService();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStorageProvider.overrideWithValue(storage),
        authServiceProvider.overrideWith((ref) async => service),
      ],
    );
    container.listen(serverProfilesProvider, (_, _) {});
    container.listen(activeServerProfileIdProvider, (_, _) {});
    addTearDown(() {
      container.dispose();
      service.dio.close(force: true);
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.buildTheme(
            Brightness.light,
            const Color(0xFF0F766E),
            fontSizeFactor: scale,
          ),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(language),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => ServerProfileDrawer(profile: profile),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  AppLocalizations l10n(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(ServerProfileDrawer)))!;

  Future<void> fillPasswordForm(WidgetTester tester) async {
    final strings = l10n(tester);
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'http://local/graphql',
    );
    await tester.tap(find.text(strings.settings_server_auth_password));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), 'alice');
    await tester.enterText(find.byType(TextFormField).at(3), 'wrong');
  }

  Future<void> save(WidgetTester tester) async {
    final button = find.widgetWithText(
      ElevatedButton,
      l10n(tester).common_save,
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  for (final scale in [0.8, 1.5]) {
    testWidgets(
      'failed new profile save can retry without duplicates at $scale',
      (tester) async {
        await openDrawer(tester, scale: scale, language: 'de');
        await fillPasswordForm(tester);
        final strings = l10n(tester);
        await save(tester);

        expect(find.byType(ServerProfileDrawer), findsOneWidget);
        expect(find.text(strings.settings_server_login_failed), findsOneWidget);
        expect(container.read(serverProfilesProvider), hasLength(1));
        final id = container.read(serverProfilesProvider).single.id;
        expect(storage.values['profile_${id}_password'], 'wrong');
        expect(tester.takeException(), isNull);
        final error = tester.widget<Semantics>(
          find
              .ancestor(
                of: find.text(strings.settings_server_login_failed),
                matching: find.byType(Semantics),
              )
              .first,
        );
        expect(error.properties.liveRegion, isTrue);

        await tester.enterText(find.byType(TextFormField).at(3), 'correct');
        await save(tester);

        expect(find.byType(ServerProfileDrawer), findsNothing);
        expect(container.read(serverProfilesProvider).single.id, id);
        expect(storage.values['profile_${id}_password'], 'correct');
        expect(service.passwords.last, 'correct');
        expect(container.read(authProvider).cookieHeader, 'session=fresh');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('existing password profile stays open on failed login', (
    tester,
  ) async {
    const profile = ServerProfile(
      id: 'existing',
      baseUrl: 'http://local/graphql',
      authMode: AuthMode.password,
    );
    await openDrawer(tester, profile: profile);
    await fillPasswordForm(tester);
    await save(tester);

    expect(find.byType(ServerProfileDrawer), findsOneWidget);
    expect(
      find.text(l10n(tester).settings_server_login_failed),
      findsOneWidget,
    );
    expect(container.read(serverProfilesProvider).single.id, profile.id);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'pending save blocks duplicate submission and tolerates dismissal',
    (tester) async {
      await openDrawer(tester);
      await fillPasswordForm(tester);
      service.response = Completer<bool>();
      await save(tester);

      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, l10n(tester).common_save),
      );
      expect(saveButton.onPressed, isNull);
      expect(service.passwords, hasLength(1));
      expect(container.read(serverProfilesProvider), hasLength(1));
      await tester.tap(find.text(l10n(tester).common_cancel));
      await tester.pumpAndSettle();
      service.response!.complete(false);
      await tester.pumpAndSettle();

      expect(find.byType(ServerProfileDrawer), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('API key profile still closes without password login', (
    tester,
  ) async {
    await openDrawer(tester);
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'http://local/graphql',
    );
    await save(tester);

    expect(find.byType(ServerProfileDrawer), findsNothing);
    expect(service.passwords, isEmpty);
    expect(container.read(serverProfilesProvider), hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
