/// End-to-end checks against a real Stash server seeded by
/// https://github.com/Alchemist-Aloha/stash-test-server.
///
/// Skipped unless `STASH_URL` is set, so the regular `flutter test` run is
/// unaffected. CI provides `STASH_URL`, `STASH_API_KEY`, `STASH_USERNAME`,
/// `STASH_PASSWORD` and `STASH_FIXTURE` (path to the profile JSON). Locally,
/// run the server's `scripts/up.sh`, then:
///
/// ```bash
/// set -a; source ../stash-test-server/stash-test-server.env; set +a
/// flutter test test/e2e
/// ```
///
/// The tests deliberately use plain `test()` (no widget binding) so requests
/// reach the real network; see `test/flutter_test_config.dart`.
@Tags(['e2e'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
import 'package:stash_app_flutter/core/data/auth/auth_service.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/data/preferences/secure_storage_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/galleries/data/repositories/graphql_gallery_repository.dart';
import 'package:stash_app_flutter/features/groups/data/repositories/graphql_group_repository.dart';
import 'package:stash_app_flutter/features/images/data/repositories/graphql_image_repository.dart';
import 'package:stash_app_flutter/features/performers/data/repositories/graphql_performer_repository.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/setup/domain/models/server_profile.dart';
import 'package:stash_app_flutter/features/studios/data/repositories/graphql_studio_repository.dart';
import 'package:stash_app_flutter/features/tags/data/repositories/graphql_tag_repository.dart';

final Map<String, String> _env = Platform.environment;
final String? _skipReason = (_env['STASH_URL'] ?? '').isEmpty
    ? 'STASH_URL not set; start stash-test-server to run e2e tests'
    : null;

String _requireEnv(String name) {
  final value = _env[name];
  if (value == null || value.isEmpty) {
    throw StateError('$name must be set for e2e tests');
  }
  return value;
}

/// In-memory replacement for the platform keychain.
class _MemoryFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _values = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.remove(key);
  }
}

/// Fixture profile shared with stash-test-server (`fixtures/profile.json`).
class _Fixture {
  _Fixture(this.json);

  final Map<String, dynamic> json;

  Map<String, dynamic> get expected => json['expected'] as Map<String, dynamic>;

  int count(String key) => expected[key] as int;

  Map<String, dynamic> get scenes => json['scenes'] as Map<String, dynamic>;

  Map<String, dynamic> scene(String key) => scenes[key] as Map<String, dynamic>;

  List<String> names(String section) => [
    for (final entry in json[section] as List<dynamic>)
      (entry as Map<String, dynamic>)['name'] as String,
  ];

  List<String> get sceneTitles => [
    for (final entry in scenes.values)
      if ((entry as Map<String, dynamic>)['title'] case final String title)
        title,
  ];
}

Future<_Fixture> _loadFixture() async {
  final file = File(_requireEnv('STASH_FIXTURE'));
  final decoded = jsonDecode(await file.readAsString());
  return _Fixture(decoded as Map<String, dynamic>);
}

/// Builds the same profile-bound GraphQL client the app uses for [profile].
Future<({GraphQLClient client, ProviderContainer container})> _clientFor(
  ServerProfile profile,
  Map<String, String> credentials,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final secureStorage = AppSecureStorage(
    secureStorage: _MemoryFlutterSecureStorage(),
    sharedPreferences: prefs,
  );
  for (final MapEntry(:key, :value) in credentials.entries) {
    await secureStorage.write(key: 'profile_${profile.id}_$key', value: value);
  }
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      secureStorageProvider.overrideWithValue(secureStorage),
    ],
  );
  final client = await container.read(
    profileGraphqlClientProvider(profile).future,
  );
  return (client: client, container: container);
}

/// Requests [path] (relative or absolute) with [headers].
///
/// Returns the status code and the number of body bytes received, so callers
/// can assert that generated media is actually served, not just routed.
Future<({int status, int bytes})> _fetch(
  String path,
  Map<String, String> headers, {
  String? range,
}) async {
  final uri = Uri.parse(_requireEnv('STASH_URL')).resolve(path);
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    headers.forEach(request.headers.set);
    if (range != null) request.headers.set(HttpHeaders.rangeHeader, range);
    final response = await request.close();
    final bytes = await response.fold<int>(0, (n, chunk) => n + chunk.length);
    return (status: response.statusCode, bytes: bytes);
  } finally {
    client.close(force: true);
  }
}

Matcher _served([List<int> statuses = const [200]]) =>
    isA<({int status, int bytes})>()
        .having((r) => r.status, 'status', isIn(statuses))
        .having((r) => r.bytes, 'bytes', greaterThan(0));

void main() {
  late _Fixture fixture;

  setUpAll(() async {
    if (_skipReason != null) return;
    fixture = await _loadFixture();
  });

  group('API key profile', skip: _skipReason, () {
    late GraphQLClient client;
    late ProviderContainer container;
    late Map<String, Scene> scenesByTitle;

    setUpAll(() async {
      final profile = ServerProfile(
        id: 'e2e-api-key',
        name: 'stash-test-server',
        baseUrl: _requireEnv('STASH_URL'),
        authMode: AuthMode.apiKey,
      );
      final built = await _clientFor(profile, {
        'api_key': _requireEnv('STASH_API_KEY'),
      });
      client = built.client;
      container = built.container;

      final page = await GraphQLSceneRepository(client)
          .findScenesPage(perPage: 100);
      scenesByTitle = {for (final s in page.scenes) s.title: s};
    });

    tearDownAll(() => container.dispose());

    test('lists every fixture scene', () async {
      final page = await GraphQLSceneRepository(client)
          .findScenesPage(perPage: 100);
      expect(page.totalCount, fixture.count('scenes'));
      expect(scenesByTitle.keys, containsAll(fixture.sceneTitles));
    });

    test('filters organized scenes server-side', () async {
      final page = await GraphQLSceneRepository(client)
          .findScenesPage(perPage: 100, organized: true);
      expect(page.totalCount, fixture.count('organized_scenes'));
    });

    test('loads full scene details', () async {
      final want = fixture.scene('Aurora Pictures/Coastal Drift.mp4');
      final summary = scenesByTitle['Coastal Drift'];
      expect(summary, isNotNull);

      final scene = await GraphQLSceneRepository(client)
          .getSceneById(summary!.id, refresh: true);
      expect(scene.studioName, want['studio']);
      expect(scene.rating100, want['rating100']);
      expect(scene.organized, isTrue);
      expect(scene.oCounter, want['o_count']);
      expect(scene.playCount, want['play_count']);
      expect(
        scene.performerNames,
        unorderedEquals(want['performers'] as List<dynamic>),
      );
      expect(scene.tagNames, unorderedEquals(want['tags'] as List<dynamic>));
      expect(
        scene.captions.map((c) => c.languageCode),
        unorderedEquals(['en', 'de']),
      );
      expect(
        scene.markers.map((m) => m.title),
        unorderedEquals([
          for (final m in want['markers'] as List<dynamic>)
            (m as Map<String, dynamic>)['title'],
        ]),
      );
      expect(scene.groups.map((g) => (g.name, g.sceneIndex)).toList(), [
        ('Tidal Trilogy', 1),
      ]);
      expect(scene.files.first.width, 1920);
      expect(scene.files.first.height, 1080);
    });

    test('serves generated media and streams with API key auth', () async {
      final scene = await GraphQLSceneRepository(client)
          .getSceneById(scenesByTitle['Coastal Drift']!.id);
      final headers = {'ApiKey': _requireEnv('STASH_API_KEY')};

      expect(await _fetch(scene.paths.screenshot!, headers), _served());
      expect(await _fetch(scene.paths.preview!, headers), _served());
      expect(await _fetch(scene.paths.sprite!, headers), _served());
      expect(await _fetch(scene.paths.vtt!, headers), _served());
      expect(
        await _fetch(scene.paths.stream!, headers, range: 'bytes=0-1023'),
        _served([200, 206]),
      );
    });

    test('lists performers, studios, tags and groups', () async {
      final performers = await GraphQLPerformerRepository(client)
          .findPerformers(perPage: 100);
      expect(
        performers.map((p) => p.name),
        unorderedEquals(fixture.names('performers')),
      );
      final mara = performers.singleWhere((p) => p.name == 'Mara Quill');
      expect(mara.favorite, isTrue);
      expect(mara.birthdate, '1990-03-14');
      expect(mara.aliasList, contains('M. Quill'));
      expect(mara.sceneCount, greaterThanOrEqualTo(2));

      final studios = await GraphQLStudioRepository(client)
          .findStudios(perPage: 100);
      expect(
        studios.map((s) => s.name),
        unorderedEquals(fixture.names('studios')),
      );
      // The list fragment omits parent_studio; only the detail query has it.
      final aurora = await GraphQLStudioRepository(client).getStudioById(
        studios.singleWhere((s) => s.name == 'Aurora Pictures').id,
        refresh: true,
      );
      expect(aurora.parentStudio?.name, 'Meridian Media Group');

      final tags = await GraphQLTagRepository(client).findTags(perPage: 100);
      expect(tags.map((t) => t.name), unorderedEquals(fixture.names('tags')));
      final fractal = tags.singleWhere((t) => t.name == 'Fractal');
      expect(fractal.parents.map((p) => p.name), ['Abstract']);

      final groups = await GraphQLGroupRepository(client)
          .findGroups(perPage: 100);
      expect(
        groups.map((g) => g.name),
        unorderedEquals(fixture.names('groups')),
      );
    });

    test('lists images and galleries', () async {
      final images = await GraphQLImageRepository(client)
          .findImages(perPage: 100);
      expect(images, hasLength(fixture.count('images')));

      final galleries = await GraphQLGalleryRepository(client)
          .findGalleries(perPage: 100);
      expect(
        galleries.map((g) => g.title),
        unorderedEquals([
          for (final g in fixture.json['galleries'] as List<dynamic>)
            (g as Map<String, dynamic>)['title'],
        ]),
      );
    });

    test('rejects an invalid API key', () async {
      final built = await _clientFor(
        ServerProfile(
          id: 'e2e-bad-key',
          baseUrl: _requireEnv('STASH_URL'),
          authMode: AuthMode.apiKey,
        ),
        {'api_key': 'not-a-valid-key'},
      );
      addTearDown(built.container.dispose);
      await expectLater(
        GraphQLSceneRepository(built.client).findScenesPage(perPage: 1),
        throwsA(anything),
      );
    });
  });

  group('password profile', skip: _skipReason, () {
    test('logs in and queries with the session cookie', () async {
      final url = _requireEnv('STASH_URL');
      final graphqlEndpoint = Uri.parse(normalizeGraphqlServerUrl(url));

      // Mirrors AuthService.create(), minus the on-disk cookie jar.
      final cookieJar = CookieJar();
      final dio = Dio(
        BaseOptions(
          followRedirects: true,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 500,
        ),
      )..interceptors.add(CookieManager(cookieJar));
      final auth = AuthService(dio: dio, cookieJar: cookieJar);

      final loggedIn = await auth.login(
        graphqlEndpoint: graphqlEndpoint,
        username: _requireEnv('STASH_USERNAME'),
        password: _requireEnv('STASH_PASSWORD'),
      );
      expect(loggedIn, isTrue, reason: 'Stash /login rejected fixture creds');

      final cookieHeader = await auth.cookieHeaderFor(
        requestUri: graphqlEndpoint,
      );
      expect(cookieHeader, isNotEmpty);

      final built = await _clientFor(
        ServerProfile(
          id: 'e2e-password',
          baseUrl: url,
          authMode: AuthMode.password,
        ),
        {
          'username': _requireEnv('STASH_USERNAME'),
          'password': _requireEnv('STASH_PASSWORD'),
          'cookie_header': cookieHeader,
        },
      );
      addTearDown(built.container.dispose);

      final page = await GraphQLSceneRepository(built.client)
          .findScenesPage(perPage: 1);
      expect(page.totalCount, fixture.count('scenes'));
    });

    test('rejects a wrong password', () async {
      final cookieJar = CookieJar();
      final dio = Dio(
        BaseOptions(
          followRedirects: true,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 500,
        ),
      )..interceptors.add(CookieManager(cookieJar));
      final auth = AuthService(dio: dio, cookieJar: cookieJar);
      final endpoint = Uri.parse(
        normalizeGraphqlServerUrl(_requireEnv('STASH_URL')),
      );
      final loggedIn = await auth.login(
        graphqlEndpoint: endpoint,
        username: _requireEnv('STASH_USERNAME'),
        password: 'definitely-wrong',
      );
      final cookie = await auth.cookieHeaderFor(requestUri: endpoint);
      expect(loggedIn && cookie.isNotEmpty, isFalse);
    });
  });
}
