import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
import 'package:stash_app_flutter/core/data/auth/server_certificate_policy_io.dart';
import 'package:stash_app_flutter/features/setup/domain/models/server_profile.dart';

void main() {
  test('accepts only the opted-in HTTPS profile origin', () {
    const profile = ServerProfile(
      id: 'stash',
      baseUrl: 'https://stash.example:9443/graphql',
      authMode: AuthMode.apiKey,
      allowSelfSignedCertificates: true,
    );

    expect(acceptsServerCertificate(profile, 'stash.example', 9443), true);
    expect(acceptsServerCertificate(profile, 'other.example', 9443), false);
    expect(acceptsServerCertificate(profile, 'stash.example', 443), false);
    expect(
      acceptsServerCertificate(
        profile.copyWith(baseUrl: 'stash.example:9443'),
        'stash.example',
        9443,
      ),
      true,
    );
    expect(
      acceptsServerCertificate(
        profile.copyWith(allowSelfSignedCertificates: false),
        'stash.example',
        9443,
      ),
      false,
    );
    expect(
      acceptsServerCertificate(
        profile.copyWith(baseUrl: 'http://stash.example:9443'),
        'stash.example',
        9443,
      ),
      false,
    );
  });
}
