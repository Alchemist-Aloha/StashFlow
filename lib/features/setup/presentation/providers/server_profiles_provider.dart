import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/data/preferences/secure_storage_provider.dart';
import '../../../../core/data/auth/auth_mode.dart';
import '../../domain/models/server_profile.dart';
import 'profile_credentials_provider.dart';

part 'server_profiles_provider.g.dart';

@riverpod
class ServerProfiles extends _$ServerProfiles {
  @override
  List<ServerProfile> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final profilesJson = prefs.getString('server_profiles');
    
    if (profilesJson == null) {
      final legacyUrl = prefs.getString('server_base_url');
      if (legacyUrl != null && legacyUrl.isNotEmpty) {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final profile = ServerProfile(
          id: id,
          name: 'Default',
          baseUrl: legacyUrl,
          authMode: _getLegacyAuthMode(),
          allowWebPasswordLogin: prefs.getBool('allow_web_password_login') ?? false,
        );
        
        Future.microtask(() => _migrateCredentials(profile));
        return [profile];
      }
      return [];
    }

    final List<dynamic> list = jsonDecode(profilesJson);
    return list.map((e) => ServerProfile.fromJson(e)).toList();
  }

  AuthMode _getLegacyAuthMode() {
    final prefs = ref.read(sharedPreferencesProvider);
    final modeRaw = prefs.getString('auth_mode');
    return AuthMode.values.firstWhere(
      (e) => e.name == modeRaw,
      orElse: () => AuthMode.apiKey,
    );
  }

  Future<void> _migrateCredentials(ServerProfile profile) async {
    final secureStorage = ref.read(secureStorageProvider);
    final apiKey = await secureStorage.read(key: 'server_api_key');
    final username = await secureStorage.read(key: 'server_username');
    final password = await secureStorage.read(key: 'server_password');

    if (apiKey != null) await secureStorage.write(key: 'profile_${profile.id}_api_key', value: apiKey);
    if (username != null) await secureStorage.write(key: 'profile_${profile.id}_username', value: username);
    if (password != null) await secureStorage.write(key: 'profile_${profile.id}_password', value: password);
    
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('active_server_profile_id', profile.id);
    await saveProfiles(state);
  }

  Future<void> saveProfiles(List<ServerProfile> profiles) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('server_profiles', jsonEncode(profiles.map((e) => e.toJson()).toList()));
    state = profiles;
  }

  Future<void> addProfile(ServerProfile profile) async {
    final newList = [...state, profile];
    await saveProfiles(newList);
  }

  Future<void> updateProfile(ServerProfile profile) async {
    final newList = state.map((e) => e.id == profile.id ? profile : e).toList();
    await saveProfiles(newList);
  }

  Future<void> updateProfileCredentials({
    required String profileId,
    String? apiKey,
    String? username,
    String? password,
  }) async {
    final secureStorage = ref.read(secureStorageProvider);
    if (apiKey != null) {
      await secureStorage.write(key: 'profile_${profileId}_api_key', value: apiKey);
    }
    if (username != null) {
      await secureStorage.write(key: 'profile_${profileId}_username', value: username);
    }
    if (password != null) {
      await secureStorage.write(key: 'profile_${profileId}_password', value: password);
    }

    // Invalidate the credential providers to ensure they pick up the new values
    ref.invalidate(profileApiKeyProvider(profileId));
    ref.invalidate(profileUsernameProvider(profileId));
    ref.invalidate(profilePasswordProvider(profileId));
    ref.invalidate(profileCookieHeaderProvider(profileId));
  }

  Future<void> removeProfile(String id) async {
    final newList = state.where((e) => e.id != id).toList();
    await saveProfiles(newList);
    
    // Cleanup secure storage
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.delete(key: 'profile_${id}_api_key');
    await secureStorage.delete(key: 'profile_${id}_username');
    await secureStorage.delete(key: 'profile_${id}_password');
    await secureStorage.delete(key: 'profile_${id}_cookie_header');
    
    // If active profile was removed, reset active profile id
    final activeId = ref.read(activeServerProfileIdProvider);
    if (activeId == id) {
      await ref.read(activeServerProfileIdProvider.notifier).set(newList.isNotEmpty ? newList.first.id : '');
    }
  }
}

@riverpod
class ActiveServerProfileId extends _$ActiveServerProfileId {
  @override
  String? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString('active_server_profile_id');
  }

  Future<void> set(String id) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('active_server_profile_id', id);
    state = id;
  }
}

@riverpod
ServerProfile? activeProfile(Ref ref) {
  final profiles = ref.watch(serverProfilesProvider);
  final activeId = ref.watch(activeServerProfileIdProvider);
  if (activeId == null || profiles.isEmpty) {
    return profiles.isNotEmpty ? profiles.first : null;
  }
  return profiles.firstWhere((e) => e.id == activeId, orElse: () => profiles.first);
}
