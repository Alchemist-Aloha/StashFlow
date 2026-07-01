import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';

void main() {
  test('validateGraphQLResult does not throw when no exception', () {
    final result = QueryResult.unexecuted;

    expect(() => validateGraphQLResult(result), returnsNormally);
  });

  test('validateGraphQLResult normalizes GraphQL auth errors', () {
    final result = QueryResult.unexecuted.copyWith(
      exception: OperationException(
        graphqlErrors: [
          const GraphQLError(
            message: 'not authenticated',
            extensions: {'code': 'UNAUTHENTICATED'},
          ),
        ],
      ),
    );

    expect(
      () => validateGraphQLResult(result),
      throwsA(
        isA<AppGraphQLException>()
            .having((e) => e.kind, 'kind', GraphQLFailureKind.unauthorized)
            .having((e) => e.message, 'message', contains('not authenticated')),
      ),
    );
  });

  test('validateGraphQLResult normalizes network failures', () {
    final result = QueryResult.unexecuted.copyWith(
      exception: OperationException(
        linkException: NetworkException(
          originalException: Exception('host lookup failed'),
          uri: Uri.parse('http://server.lan/graphql'),
        ),
      ),
    );

    expect(
      () => validateGraphQLResult(result),
      throwsA(
        isA<AppGraphQLException>()
            .having((e) => e.kind, 'kind', GraphQLFailureKind.network)
            .having((e) => e.message, 'message', contains('connect')),
      ),
    );
  });

  test('validateGraphQLResult normalizes response format failures', () {
    final result = QueryResult.unexecuted.copyWith(
      exception: OperationException(
        linkException: const ResponseFormatException(
          originalException: FormatException('Unexpected end of input'),
        ),
      ),
    );

    expect(
      () => validateGraphQLResult(result),
      throwsA(
        isA<AppGraphQLException>()
            .having((e) => e.kind, 'kind', GraphQLFailureKind.schema)
            .having((e) => e.message, 'message', contains('response')),
      ),
    );
  });

  test('validateGraphQLResult normalizes HTTP auth failures', () {
    final result = QueryResult.unexecuted.copyWith(
      exception: OperationException(
        linkException: const ServerException(statusCode: 401),
      ),
    );

    expect(
      () => validateGraphQLResult(result),
      throwsA(
        isA<AppGraphQLException>().having(
          (e) => e.kind,
          'kind',
          GraphQLFailureKind.unauthorized,
        ),
      ),
    );
  });
}
