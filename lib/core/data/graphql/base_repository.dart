import 'package:graphql/client.dart';
import 'graphql_exception.dart';

/// A base class for all GraphQL repositories.
///
/// Provides shared utilities for validating [QueryResult] objects
/// and mapping GraphQL errors to domain-specific exceptions.
abstract class BaseRepository {
  /// Validates that the [result] does not have any exceptions.
  ///
  /// Throws a normalized [AppGraphQLException] if one is present in the result.
  static void validateResult(QueryResult result) {
    if (result.hasException) {
      throw normalizeGraphQLException(result.exception!);
    }
  }

  static Never throwNormalized(OperationException exception) {
    throw normalizeGraphQLException(exception);
  }
}
