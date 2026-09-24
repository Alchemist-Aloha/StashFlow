import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import '../../../features/setup/domain/models/server_profile.dart';

http.Client createGraphqlHttpClient({
  required bool withCredentials,
  ServerProfile? profile,
}) {
  final client = BrowserClient();
  client.withCredentials = withCredentials;
  return client;
}
