import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../data/graphql/config.graphql.dart';

part 'stashbox_provider.g.dart';

class StashBoxEndpoint {
  final String name;
  final String endpoint;

  StashBoxEndpoint({required this.name, required this.endpoint});
}

@riverpod
Future<List<StashBoxEndpoint>> stashBoxEndpoints(Ref ref) async {
  final client = ref.watch(graphqlClientProvider);
  final result = await client.query$GetStashBoxes();

  if (result.hasException) throw result.exception!;

  final stashBoxes = result.parsedData?.configuration.general.stashBoxes ?? [];
  return stashBoxes
      .map((s) => StashBoxEndpoint(name: s.name, endpoint: s.endpoint))
      .toList();
}
