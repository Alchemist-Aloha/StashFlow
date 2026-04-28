import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/core/data/graphql/schema.graphql.dart';
import 'package:stash_app_flutter/features/studios/data/repositories/graphql_studio_repository.dart';
import 'package:stash_app_flutter/features/studios/domain/entities/studio.dart';
import 'package:stash_app_flutter/features/studios/data/graphql/studios.graphql.dart';

import 'graphql_studio_repository_test.mocks.dart';

@GenerateMocks([GraphQLClient])
void main() {
  late GraphQLStudioRepository repository;
  late MockGraphQLClient mockClient;

  setUp(() {
    mockClient = MockGraphQLClient();
    repository = GraphQLStudioRepository(mockClient);
    when(mockClient.link).thenReturn(HttpLink('http://localhost:9999/graphql'));
  });

  group('GraphQLStudioRepository', () {
    test('findStudios returns a list of studios on success', () async {
      final data = {
        'findStudios': {
          'count': 1,
          'studios': [
            {
              'id': '1',
              'name': 'Test Studio',
              'url': 'http://test.com',
              'image_path': 'http://localhost:9999/studio.jpg',
              'details': 'Studio details',
              'rating100': 80,
              'scene_count': 5,
              'image_count': 0,
              'gallery_count': 0,
              'performer_count': 0,
              'favorite': true,
              '__typename': 'Studio',
            },
          ],
          '__typename': 'StudioQueryResult',
        },
        '__typename': 'Query',
      };

      final mockQueryResult = QueryResult<Query$FindStudios>(
        source: QueryResultSource.network,
        data: data,
        options: Options$Query$FindStudios(
          variables: Variables$Query$FindStudios(
            filter: Input$FindFilterType(
              page: 1,
              per_page: 20,
              sort: null,
              direction: Enum$SortDirectionEnum.ASC,
            ),
            studio_filter: Input$StudioFilterType(),
          ),
        ),
      );

      when(
        mockClient.query<Query$FindStudios>(any),
      ).thenAnswer((_) async => mockQueryResult);

      final result = await repository.findStudios(page: 1, perPage: 20);

      expect(result, isA<List<Studio>>());
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.name, 'Test Studio');
      expect(result.first.sceneCount, 5);
      expect(result.first.favorite, true);
    });

    test('getStudioById returns a studio on success', () async {
      final data = {
        'findStudio': {
          'id': '1',
          'name': 'Test Studio',
          'url': 'http://test.com',
          'image_path': 'http://localhost:9999/studio.jpg',
          'details': 'Studio details',
          'rating100': 80,
          'scene_count': 5,
          'image_count': 0,
          'gallery_count': 0,
          'performer_count': 0,
          'favorite': false,
          '__typename': 'Studio',
        },
        '__typename': 'Query',
      };

      final mockQueryResult = QueryResult<Query$FindStudio>(
        source: QueryResultSource.network,
        data: data,
        options: Options$Query$FindStudio(
          variables: Variables$Query$FindStudio(id: '1'),
        ),
      );

      when(
        mockClient.query<Query$FindStudio>(any),
      ).thenAnswer((_) async => mockQueryResult);

      final result = await repository.getStudioById('1');

      expect(result, isA<Studio>());
      expect(result.id, '1');
      expect(result.name, 'Test Studio');
    });
  });
}
