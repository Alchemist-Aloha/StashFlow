import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/base_repository.dart';

void main() {
  test('BaseRepository.validateResult throws on exception', () {
    final result = QueryResult.unexecuted.copyWith(
      exception: OperationException(graphqlErrors: [const GraphQLError(message: 'Error')]),
    );

    expect(() => BaseRepository.validateResult(result), throwsException);
  });

  test('BaseRepository.validateResult does not throw when no exception', () {
    final result = QueryResult.unexecuted;

    expect(() => BaseRepository.validateResult(result), returnsNormally);
  });
}
