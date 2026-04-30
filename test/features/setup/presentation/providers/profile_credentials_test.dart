import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/secure_storage_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/profile_credentials_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/server_profiles_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<FlutterSecureStorage>()])
import 'profile_credentials_test.mocks.dart';

void main() {
  late SharedPreferences prefs;
  late MockFlutterSecureStorage secureStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    secureStorage = MockFlutterSecureStorage();
  });

  ProviderContainer createContainer({
    List<dynamic> overrides = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStorageProvider.overrideWithValue(secureStorage),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('profileApiKeyProvider should refresh when updateProfileCredentials is called', () async {
    const profileId = 'test-profile';
    const initialApiKey = 'initial-key';
    const updatedApiKey = 'updated-key';

    // Set up initial storage state
    when(secureStorage.read(key: 'profile_${profileId}_api_key'))
        .thenAnswer((_) async => initialApiKey);

    final container = createContainer();

    // Initial read
    var apiKey = await container.read(profileApiKeyProvider(profileId).future);
    expect(apiKey, initialApiKey);

    // Update credentials
    when(secureStorage.write(key: 'profile_${profileId}_api_key', value: updatedApiKey))
        .thenAnswer((_) async {});
    when(secureStorage.read(key: 'profile_${profileId}_api_key'))
        .thenAnswer((_) async => updatedApiKey);

    await container.read(serverProfilesProvider.notifier).updateProfileCredentials(
          profileId: profileId,
          apiKey: updatedApiKey,
        );

    // Read again - should be updated
    apiKey = await container.read(profileApiKeyProvider(profileId).future);
    expect(apiKey, updatedApiKey);
    
    // Verify secure storage was called
    verify(secureStorage.write(key: 'profile_${profileId}_api_key', value: updatedApiKey)).called(1);
  });

  test('profileUsername and password should refresh when updateProfileCredentials is called', () async {
    const profileId = 'test-profile';
    const initialUser = 'user1';
    const updatedUser = 'user2';
    const initialPass = 'pass1';
    const updatedPass = 'pass2';

    when(secureStorage.read(key: 'profile_${profileId}_username'))
        .thenAnswer((_) async => initialUser);
    when(secureStorage.read(key: 'profile_${profileId}_password'))
        .thenAnswer((_) async => initialPass);

    final container = createContainer();

    expect(await container.read(profileUsernameProvider(profileId).future), initialUser);
    expect(await container.read(profilePasswordProvider(profileId).future), initialPass);

    // Update
    when(secureStorage.write(key: 'profile_${profileId}_username', value: updatedUser))
        .thenAnswer((_) async {});
    when(secureStorage.write(key: 'profile_${profileId}_password', value: updatedPass))
        .thenAnswer((_) async {});
    when(secureStorage.read(key: 'profile_${profileId}_username'))
        .thenAnswer((_) async => updatedUser);
    when(secureStorage.read(key: 'profile_${profileId}_password'))
        .thenAnswer((_) async => updatedPass);

    await container.read(serverProfilesProvider.notifier).updateProfileCredentials(
          profileId: profileId,
          username: updatedUser,
          password: updatedPass,
        );

    expect(await container.read(profileUsernameProvider(profileId).future), updatedUser);
    expect(await container.read(profilePasswordProvider(profileId).future), updatedPass);
  });
}
