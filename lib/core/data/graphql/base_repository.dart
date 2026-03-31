import 'package:graphql/client.dart';

/// A base class for all GraphQL repositories.
///
/// Provides shared utilities for validating [QueryResult] objects
/// and mapping GraphQL errors to domain-specific exceptions.
abstract class BaseRepository {
  /// Validates that the [result] does not have any exceptions.
  ///
  /// Throws the [OperationException] if one is present in the [result].
  static void validateResult(QueryResult result) {
    if (result.hasException) {
      throw result.exception!;
    }
  }
}
