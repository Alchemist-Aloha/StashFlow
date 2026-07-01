import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../data/graphql/version.graphql.dart';
import '../../domain/models/server_profile.dart';

final connectionStatusProvider = FutureProvider.family
    .autoDispose<String, ServerProfile>((ref, profile) async {
      if (profile.baseUrl.isEmpty) {
        return 'Not Configured';
      }

      final client = await ref.watch(
        profileGraphqlClientProvider(profile).future,
      );

      try {
        final result = await client.query$GetVersion(
          Options$Query$GetVersion(fetchPolicy: FetchPolicy.networkOnly),
        );

        validateGraphQLResult(result);

        final version = result.parsedData?.version.version;
        return version ?? 'Unknown Version';
      } on AppGraphQLException {
        rethrow;
      } catch (e) {
        throw Exception('Connection failed: $e');
      }
    });
