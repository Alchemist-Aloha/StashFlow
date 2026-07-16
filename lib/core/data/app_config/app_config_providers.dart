import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../preferences/secure_storage_provider.dart';
import '../preferences/shared_preferences_provider.dart';
import 'app_config_document_service.dart';
import 'app_config_service.dart';

final appConfigDocumentServiceProvider = Provider(
  (ref) => const AppConfigDocumentService(),
);

final appConfigServiceProvider = FutureProvider<AppConfigService>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return AppConfigService(
    preferences: ref.watch(sharedPreferencesProvider),
    secureStorage: ref.watch(secureStorageProvider),
    appVersion: '${info.version}+${info.buildNumber}',
    now: DateTime.now,
  );
});
