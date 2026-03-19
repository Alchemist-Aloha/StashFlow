import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../data/graphql/version.graphql.dart';

final connectionStatusProvider = FutureProvider.autoDispose<String>((ref) async {
  final client = ref.watch(graphqlClientProvider);
  
  try {
    final result = await client.query$GetVersion(
      Options$Query$GetVersion(
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    
    if (result.hasException) {
      throw result.exception!;
    }
    
    return result.parsedData?.version.version ?? 'Unknown';
  } catch (e) {
    throw Exception('Connection failed: $e');
  }
});
