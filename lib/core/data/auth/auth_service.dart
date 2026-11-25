import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../features/setup/domain/models/server_profile.dart';
import 'server_certificate_policy.dart';
import '../../utils/app_log_store.dart';

class AuthService {
  AuthService({required this._dio, required this.cookieJar});

  static Future<CookieJar>? _sharedCookieJarFuture;

  final Dio _dio;
  final CookieJar cookieJar;

  /// Stands in for the session cookie on web, where the browser keeps the
  /// real HttpOnly cookie and `cookie_jar` stores nothing. It only marks the
  /// session as logged in; web requests never send it.
  static const webSessionMarker = 'web_session=active';

  bool _webSessionActive = false;

  static Future<AuthService> create({ServerProfile? profile}) async {
    final cookieJar = await createPersistCookieJar();

    final dio = Dio(
      BaseOptions(
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 500,
        extra: kIsWeb
            ? <String, dynamic>{'withCredentials': true}
            : const <String, dynamic>{},
      ),
    );

    configureServerCertificates(dio, profile);

    if (!kIsWeb) {
      dio.interceptors.add(CookieManager(cookieJar));
    }

    return AuthService(dio: dio, cookieJar: cookieJar);
  }

  static Future<CookieJar> createPersistCookieJar() async {
    if (kIsWeb) {
      // Web cannot persist filesystem cookies; keep the same API with in-memory storage.
      return CookieJar(ignoreExpires: false);
    }

    _sharedCookieJarFuture ??= () async {
      final supportDir = await getApplicationSupportDirectory();
      final cookiePath = p.join(supportDir.path, 'stashflow_cookies');
      return PersistCookieJar(
        ignoreExpires: false,
        storage: FileStorage(cookiePath),
      );
    }();

    return _sharedCookieJarFuture!;
  }

  Dio get dio => _dio;

  Future<bool> login({
    required Uri graphqlEndpoint,
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.isEmpty) {
      return false;
    }

    final loginUri = _resolveEndpoint(graphqlEndpoint, 'login');
    debugPrint(
      'AuthService: Attempting login to $loginUri for user: $trimmedUsername',
    );
    Response<dynamic> response;
    try {
      response = await _dio.postUri(
        loginUri,
        data: <String, String>{
          'username': trimmedUsername,
          'password': password,
          'returnURL': '/',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: const <String, String>{'accept': '*/*'},
          extra: kIsWeb ? <String, dynamic>{'withCredentials': true} : null,
        ),
      );
      debugPrint('AuthService: Login response status: ${response.statusCode}');
    } on DioException catch (e, stackTrace) {
      AppLogStore.instance.addError(
        'login',
        e,
        stackTrace,
        source: 'auth_service',
      );
      return false;
    }

    if (response.statusCode == 200) {
      if (kIsWeb) _webSessionActive = true;
      return true;
    }
    return false;
  }

  Future<void> logout({required Uri graphqlEndpoint}) async {
    final logoutUri = _resolveEndpoint(graphqlEndpoint, 'logout');
    try {
      await _dio.getUri<dynamic>(logoutUri);
    } on DioException catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'logout',
        error,
        stackTrace,
        source: 'auth_service',
      );
      // Best effort endpoint call; always clear local cookie state.
    }

    await clearCookies();
  }

  Future<void> clearCookies() {
    _webSessionActive = false;
    return cookieJar.deleteAll();
  }

  Future<String> cookieHeaderFor({required Uri requestUri}) async {
    if (kIsWeb) return _webSessionActive ? webSessionMarker : '';
    final cookies = await cookieJar.loadForRequest(requestUri);
    if (cookies.isEmpty) {
      return '';
    }

    return cookies
        .where((cookie) => cookie.name.isNotEmpty)
        .map((cookie) => '${cookie.name}=${cookie.value}')
        .join('; ')
        .trim();
  }

  Uri _resolveEndpoint(Uri endpoint, String route) {
    final segments = endpoint.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (segments.isNotEmpty && segments.last.toLowerCase() == 'graphql') {
      segments[segments.length - 1] = route;
    } else {
      segments.add(route);
    }

    return endpoint.replace(
      pathSegments: segments,
      query: null,
      fragment: null,
    );
  }
}
