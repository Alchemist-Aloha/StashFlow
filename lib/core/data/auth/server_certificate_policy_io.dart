import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/setup/domain/models/server_profile.dart';

bool acceptsServerCertificate(ServerProfile? profile, String host, int port) {
  if (profile?.allowSelfSignedCertificates != true) return false;
  final baseUrl = profile!.baseUrl.trim();
  final uri = Uri.tryParse(
    baseUrl.contains('://') ? baseUrl : 'https://$baseUrl',
  );
  return uri?.scheme == 'https' && uri!.host == host && uri.port == port;
}

HttpClient serverHttpClient(ServerProfile? profile) =>
    HttpClient()
      ..badCertificateCallback = (_, host, port) =>
          acceptsServerCertificate(profile, host, port);

void configureServerCertificates(Dio dio, ServerProfile? profile) {
  if (profile?.allowSelfSignedCertificates != true) return;
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () => serverHttpClient(profile),
  );
}

class _ServerCertificateOverrides extends HttpOverrides {
  _ServerCertificateOverrides(this.preferences);

  final SharedPreferences preferences;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..badCertificateCallback = (_, host, port) =>
            acceptsServerCertificate(_activeProfile(), host, port);

  ServerProfile? _activeProfile() {
    try {
      final raw = preferences.getString('server_profiles');
      if (raw == null) return null;
      final profiles = (jsonDecode(raw) as List<dynamic>)
          .map((value) => ServerProfile.fromJson(value as Map<String, dynamic>))
          .toList();
      if (profiles.isEmpty) return null;
      final activeId = preferences.getString('active_server_profile_id');
      for (final profile in profiles) {
        if (profile.id == activeId) return profile;
      }
      return profiles.first;
    } catch (_) {
      return null;
    }
  }
}

void installServerCertificatePolicy(SharedPreferences preferences) {
  HttpOverrides.global = _ServerCertificateOverrides(preferences);
}
