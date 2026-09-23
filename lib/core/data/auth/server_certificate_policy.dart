import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/setup/domain/models/server_profile.dart';

import 'server_certificate_policy_io.dart'
    if (dart.library.js_interop) 'server_certificate_policy_web.dart'
    as platform;

void configureServerCertificates(Dio dio, ServerProfile? profile) =>
    platform.configureServerCertificates(dio, profile);

void installServerCertificatePolicy(SharedPreferences preferences) =>
    platform.installServerCertificatePolicy(preferences);
