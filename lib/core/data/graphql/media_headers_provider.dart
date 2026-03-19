import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences/shared_preferences_provider.dart';

final mediaHeadersProvider = Provider<Map<String, String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final apiKey = prefs.getString('server_api_key')?.trim() ?? '';

  if (apiKey.isEmpty) {
    return const <String, String>{};
  }

  return <String, String>{'ApiKey': apiKey};
});
