import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/core/data/graphql/schema.graphql.dart';
import 'package:stash_app_flutter/features/tags/data/repositories/graphql_tag_repository.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/tags/data/graphql/tags.graphql.dart';

import 'graphql_tag_repository_test.mocks.dart';

@GenerateMocks([GraphQLClient])
void main() {
  late GraphQLTagRepository repository;
  late MockGraphQLClient mockClient;

  setUp(() {
    mockClient = MockGraphQLClient();
    repository = GraphQLTagRepository(mockClient);
    when(mockClient.link).thenReturn(HttpLink('http://localhost:9999/graphql'));
  });

  group('GraphQLTagRepository', () {
    test('findTags returns a list of tags on success', () async {
      final data = {
        'findTags': {
          'count': 1,
          'tags': [
            {
              'id': '1',
              'name': 'Test Tag',
              'description': 'Tag description',
              'image_path': 'http://localhost:9999/tag.jpg',
              'scene_count': 10,
              'image_count': 0,
              'gallery_count': 0,
              'performer_count': 0,
              'favorite': false,
              '__typename': 'Tag',
            },
          ],
          '__typename': 'TagQueryResult',
        },
        '__typename': 'Query',
      };

      final mockQueryResult = QueryResult<Query$FindTags>(
        source: QueryResultSource.network,
        data: data,
        options: Options$Query$FindTags(
          variables: Variables$Query$FindTags(
            filter: Input$FindFilterType(
              page: 1,
              per_page: 20,
              sort: null,
              direction: Enum$SortDirectionEnum.ASC,
            ),
          ),
        ),
      );

      when(
        mockClient.query<Query$FindTags>(any),
      ).thenAnswer((_) async => mockQueryResult);

      final result = await repository.findTags(page: 1, perPage: 20);

      expect(result, isA<List<Tag>>());
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.name, 'Test Tag');
      expect(result.first.sceneCount, 10);
    });

    test('getTagById returns a tag on success', () async {
      final data = {
        'findTag': {
          'id': '1',
          'name': 'Test Tag',
          'description': 'Tag description',
          'image_path': 'http://localhost:9999/tag.jpg',
          'scene_count': 10,
          'image_count': 0,
          'gallery_count': 0,
          'performer_count': 0,
          'favorite': true,
          '__typename': 'Tag',
        },
        '__typename': 'Query',
      };

      final mockQueryResult = QueryResult<Query$FindTag>(
        source: QueryResultSource.network,
        data: data,
        options: Options$Query$FindTag(
          variables: Variables$Query$FindTag(id: '1'),
        ),
      );

      when(
        mockClient.query<Query$FindTag>(any),
      ).thenAnswer((_) async => mockQueryResult);

      final result = await repository.getTagById('1');

      expect(result, isA<Tag>());
      expect(result.id, '1');
      expect(result.name, 'Test Tag');
      expect(result.favorite, true);
    });
  });
}
