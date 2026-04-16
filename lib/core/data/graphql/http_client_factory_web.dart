import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

http.Client createGraphqlHttpClient({required bool withCredentials}) {
  final client = BrowserClient();
  client.withCredentials = withCredentials;
  return client;
}
