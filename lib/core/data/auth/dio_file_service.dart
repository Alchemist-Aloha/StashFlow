import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'auth_service.dart';

class DioFileService extends FileService {
  DioFileService();

  Dio? _dio;
  Future<void>? _initFuture;

  Future<void> _ensureInitialized() async {
    if (_dio != null) {
      return;
    }
    if (_initFuture != null) {
      return _initFuture;
    }

    _initFuture = () async {
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

    return _initFuture;
  }

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    await _ensureInitialized();

    final response = await _dio!.getUri<ResponseBody>(
      Uri.parse(url),
      options: Options(responseType: ResponseType.stream, headers: headers),
    );

    return _DioGetResponse(response);
  }
}

class _DioGetResponse implements FileServiceResponse {
  _DioGetResponse(this._response) : _receivedTime = DateTime.now();

  final Response<ResponseBody> _response;
  final DateTime _receivedTime;

  String? _header(String name) {
    return _response.headers.value(name);
  }

  @override
  Stream<List<int>> get content => _response.data!.stream;

  @override
  int? get contentLength {
    final fromBody = _response.data?.contentLength;
    if (fromBody != null && fromBody >= 0) {
      return fromBody;
    }

    final rawHeader = _header(HttpHeaders.contentLengthHeader);
    return int.tryParse(rawHeader ?? '');
  }

  @override
  int get statusCode => _response.statusCode ?? 500;

  @override
  DateTime get validTill {
    var ageDuration = const Duration(days: 7);
    final controlHeader = _header(HttpHeaders.cacheControlHeader);
    if (controlHeader == null) {
      return _receivedTime.add(ageDuration);
    }

    final controlSettings = controlHeader.split(',');
    for (final setting in controlSettings) {
      final normalized = setting.trim().toLowerCase();
      if (normalized == 'no-cache') {
        ageDuration = Duration.zero;
      }
      if (normalized.startsWith('max-age=')) {
        final seconds = int.tryParse(normalized.split('=').last) ?? 0;
        if (seconds > 0) {
          ageDuration = Duration(seconds: seconds);
        }
      }
    }

    return _receivedTime.add(ageDuration);
  }

  @override
  String? get eTag => _header(HttpHeaders.etagHeader);

  @override
  String get fileExtension => '';
}
