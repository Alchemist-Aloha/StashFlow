import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expectedDefaultUrl = 'https://stash.cai.co.im/graphql';
  const expectedDefaultApiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJxbWtreGNsayIsInN1YiI6IkFQSUtleSIsImlhdCI6MTc3Mzc5MjkyNX0.611H2b2FvizfvU7ooAPW7H6b-u7SU0lI2hvZ34u78t0';

  test(
    'uses default server url and api key when preferences are empty',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final client = container.read(graphqlClientProvider);

      expect(client.link, isA<HttpLink>());
      final httpLink = client.link as HttpLink;

      expect(httpLink.uri.toString(), expectedDefaultUrl);
      expect(httpLink.defaultHeaders['ApiKey'], expectedDefaultApiKey);
    },
  );
}
