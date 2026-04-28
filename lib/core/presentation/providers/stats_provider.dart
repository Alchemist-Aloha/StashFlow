import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/graphql/graphql_client.dart';
import '../../data/graphql/stats_repository.dart';

part 'stats_provider.g.dart';

@riverpod
StatsRepository statsRepository(Ref ref) {
  final client = ref.watch(graphqlClientProvider);
  return StatsRepository(client);
}

@riverpod
Future<StatsResult> serverStats(Ref ref) {
  return ref.watch(statsRepositoryProvider).getStats();
}
