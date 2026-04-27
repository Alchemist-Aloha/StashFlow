import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AuthService {
  AuthService({required Dio dio, required this.cookieJar}) : _dio = dio;

  static Future<CookieJar>? _sharedCookieJarFuture;

  final Dio _dio;
  final CookieJar cookieJar;

  static Future<AuthService> create() async {
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
    debugPrint('AuthService: Attempting login to $loginUri for user: $trimmedUsername');
    Response response;
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
    } on DioException catch (e) {
      debugPrint('AuthService: Login failed with DioException: ${e.message}');
      if (e.response != null) {
        debugPrint('AuthService: Error response body: ${e.response?.data}');
      }
      return false;
    }

    if (response.statusCode == 200) {
      if (kIsWeb) {
        // On the web, the browser securely handles the session cookie.
        // We inject a dummy cookie so `cookieJar` isn't empty,
        // which preserves the app's logged-in state logic.
        final dummyCookie = Cookie('web_session', 'active')
          ..domain = loginUri.host
          ..path = '/';
        await cookieJar.saveFromResponse(loginUri, [dummyCookie]);
      }
      return true;
    }
    return false;
  }

  Future<void> logout({required Uri graphqlEndpoint}) async {
    final logoutUri = _resolveEndpoint(graphqlEndpoint, 'logout');
    try {
      await _dio.getUri(logoutUri);
    } catch (_) {
      // Best effort endpoint call; always clear local cookie state.
    }

    await clearCookies();
  }

  Future<void> clearCookies() => cookieJar.deleteAll();

  Future<String> cookieHeaderFor({required Uri requestUri}) async {
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
