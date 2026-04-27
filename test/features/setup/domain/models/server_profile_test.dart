import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/setup/domain/models/server_profile.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';

void main() {
  group('ServerProfile', () {
    test('should correctly serialize to and from JSON', () {
      final profile = ServerProfile(
        id: 'test-id',
        name: 'Test Server',
        baseUrl: 'http://localhost:9999',
        authMode: AuthMode.apiKey,
        allowWebPasswordLogin: true,
      );

      final json = profile.toJson();
      expect(json['id'], 'test-id');
      expect(json['name'], 'Test Server');
      expect(json['baseUrl'], 'http://localhost:9999');
      expect(json['authMode'], 'apiKey');
      expect(json['allowWebPasswordLogin'], true);

      final fromJson = ServerProfile.fromJson(json);
      expect(fromJson.id, profile.id);
      expect(fromJson.name, profile.name);
      expect(fromJson.baseUrl, profile.baseUrl);
      expect(fromJson.authMode, profile.authMode);
      expect(fromJson.allowWebPasswordLogin, profile.allowWebPasswordLogin);
    });

    test('should correctly use copyWith', () {
      final profile = ServerProfile(
        id: 'test-id',
        name: 'Test Server',
        baseUrl: 'http://localhost:9999',
        authMode: AuthMode.apiKey,
        allowWebPasswordLogin: false,
      );

      final updatedProfile = profile.copyWith(
        name: 'Updated Server',
        allowWebPasswordLogin: true,
      );

      expect(updatedProfile.id, 'test-id');
      expect(updatedProfile.name, 'Updated Server');
      expect(updatedProfile.baseUrl, 'http://localhost:9999');
      expect(updatedProfile.authMode, AuthMode.apiKey);
      expect(updatedProfile.allowWebPasswordLogin, true);
    });
  });
}
