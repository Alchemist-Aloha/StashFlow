import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// Keeps cached image downloads on the same persistent cookie jar as login.
class DioImageClient extends http.BaseClient {
  Dio? _dio;
  Future<void>? _initFuture;
  bool _closed = false;

  Future<void> _ensureInitialized() async {
    if (_dio != null) return;
    _initFuture ??= () async {
      final cookieJar = await AuthService.createPersistCookieJar();
      _dio = Dio(
        BaseOptions(
          followRedirects: true,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 500,
        ),
      );
      if (!kIsWeb) {
        _dio!.interceptors.add(CookieManager(cookieJar));
      }
    }();
    await _initFuture;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_closed) {
      throw http.ClientException('Image client is closed', request.url);
    }
    final cancelToken = CancelToken();
    if (request is http.Abortable) {
      unawaited(request.abortTrigger?.then((_) => cancelToken.cancel()));
    }
    await _ensureInitialized();
    if (_closed) {
      _dio!.close(force: true);
      throw http.ClientException('Image client is closed', request.url);
    }

    try {
      final response = await _dio!.requestUri<ResponseBody>(
        request.url,
        data: request.finalize(),
        cancelToken: cancelToken,
        options: Options(
          method: request.method,
          responseType: ResponseType.stream,
          headers: request.headers,
        ),
      );
      final body = response.data!;
      return http.StreamedResponse(
        body.stream.handleError(
          (Object error) => throw http.RequestAbortedException(request.url),
          test: (error) => error is DioException && CancelToken.isCancel(error),
        ),
        response.statusCode!,
        contentLength: body.contentLength < 0 ? null : body.contentLength,
        headers: response.headers.map.map(
          (name, values) => MapEntry(name, values.join(',')),
        ),
        request: request,
        isRedirect: response.isRedirect,
        reasonPhrase: response.statusMessage,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        throw http.RequestAbortedException(request.url);
      }
      rethrow;
    }
  }

  @override
  void close() {
    _closed = true;
    _dio?.close(force: true);
    super.close();
  }
}
