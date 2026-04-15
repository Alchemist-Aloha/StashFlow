import 'package:http/http.dart' as http;

import 'http_client_factory_io.dart'
    if (dart.library.js_interop) 'http_client_factory_web.dart'
    as impl;

http.Client createGraphqlHttpClient({required bool withCredentials}) {
  return impl.createGraphqlHttpClient(withCredentials: withCredentials);
}
