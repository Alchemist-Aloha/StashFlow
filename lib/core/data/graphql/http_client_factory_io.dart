import 'package:http/http.dart' as http;

http.Client createGraphqlHttpClient({required bool withCredentials}) {
  return http.Client();
}
