import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';
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

  validateGraphQLResult(result);

  final stashBoxes = result.parsedData?.configuration.general.stashBoxes ?? [];
  return stashBoxes
      .map((s) => StashBoxEndpoint(name: s.name, endpoint: s.endpoint))
      .toList();
}
