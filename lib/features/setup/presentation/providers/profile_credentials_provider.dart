import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/preferences/secure_storage_provider.dart';

part 'profile_credentials_provider.g.dart';

@riverpod
Future<String> profileApiKey(Ref ref, String profileId) async {
  final secureStorage = ref.read(secureStorageProvider);
  return await secureStorage.read(key: 'profile_${profileId}_api_key') ?? '';
}

@riverpod
Future<String> profileUsername(Ref ref, String profileId) async {
  final secureStorage = ref.read(secureStorageProvider);
  return await secureStorage.read(key: 'profile_${profileId}_username') ?? '';
}

@riverpod
Future<String> profilePassword(Ref ref, String profileId) async {
  final secureStorage = ref.read(secureStorageProvider);
  return await secureStorage.read(key: 'profile_${profileId}_password') ?? '';
}

@riverpod
Future<String> profileCookieHeader(Ref ref, String profileId) async {
  final secureStorage = ref.read(secureStorageProvider);
  return await secureStorage.read(key: 'profile_${profileId}_cookie_header') ?? '';
}
