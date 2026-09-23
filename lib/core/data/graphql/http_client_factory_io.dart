import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../../../features/setup/domain/models/server_profile.dart';
import '../auth/server_certificate_policy_io.dart';

http.Client createGraphqlHttpClient({
  required bool withCredentials,
  ServerProfile? profile,
}) {
  return profile?.allowSelfSignedCertificates == true
      ? IOClient(serverHttpClient(profile))
      : http.Client();
}
