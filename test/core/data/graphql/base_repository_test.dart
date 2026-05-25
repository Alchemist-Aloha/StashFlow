import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/base_repository.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';

void main() {
  test('BaseRepository.validateResult does not throw when no exception', () {
    final result = QueryResult.unexecuted;

    expect(() => BaseRepository.validateResult(result), returnsNormally);
  });

  test('BaseRepository.validateResult normalizes GraphQL auth errors', () {
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
      () => BaseRepository.validateResult(result),
      throwsA(
        isA<AppGraphQLException>()
            .having((e) => e.kind, 'kind', GraphQLFailureKind.unauthorized)
            .having((e) => e.message, 'message', contains('not authenticated')),
      ),
    );
  });

  test('BaseRepository.validateResult normalizes network failures', () {
    final result = QueryResult.unexecuted.copyWith(
      exception: OperationException(
        linkException: NetworkException(
          originalException: Exception('host lookup failed'),
          uri: Uri.parse('http://server.lan/graphql'),
        ),
      ),
    );

    expect(
      () => BaseRepository.validateResult(result),
      throwsA(
        isA<AppGraphQLException>()
            .having((e) => e.kind, 'kind', GraphQLFailureKind.network)
            .having((e) => e.message, 'message', contains('connect')),
      ),
    );
  });

  test('BaseRepository.validateResult normalizes response format failures', () {
    final result = QueryResult.unexecuted.copyWith(
      exception: OperationException(
        linkException: const ResponseFormatException(
          originalException: FormatException('Unexpected end of input'),
        ),
      ),
    );

    expect(
      () => BaseRepository.validateResult(result),
      throwsA(
        isA<AppGraphQLException>()
            .having((e) => e.kind, 'kind', GraphQLFailureKind.schema)
            .having((e) => e.message, 'message', contains('response')),
      ),
    );
  });

  test('BaseRepository.validateResult normalizes HTTP auth failures', () {
    final result = QueryResult.unexecuted.copyWith(
      exception: OperationException(
        linkException: const ServerException(statusCode: 401),
      ),
    );

    expect(
      () => BaseRepository.validateResult(result),
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
