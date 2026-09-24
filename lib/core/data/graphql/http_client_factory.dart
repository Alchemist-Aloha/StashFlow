import 'package:http/http.dart' as http;
import '../../../features/setup/domain/models/server_profile.dart';

import 'http_client_factory_io.dart'
    if (dart.library.js_interop) 'http_client_factory_web.dart'
    as impl;

http.Client createGraphqlHttpClient({
  required bool withCredentials,
  ServerProfile? profile,
}) {
  return impl.createGraphqlHttpClient(
    withCredentials: withCredentials,
    profile: profile,
  );
}
