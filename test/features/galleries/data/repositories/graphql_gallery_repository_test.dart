import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/core/data/graphql/schema.graphql.dart';
import 'package:stash_app_flutter/features/galleries/data/repositories/graphql_gallery_repository.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/data/graphql/galleries.graphql.dart';

import 'graphql_gallery_repository_test.mocks.dart';

@GenerateMocks([GraphQLClient])
void main() {
  late GraphQLGalleryRepository repository;
  late MockGraphQLClient mockClient;

  setUp(() {
    mockClient = MockGraphQLClient();
    repository = GraphQLGalleryRepository(mockClient);
    when(mockClient.link).thenReturn(HttpLink('http://localhost:9999/graphql'));
  });

  group('GraphQLGalleryRepository', () {
    test('findGalleries returns a list of galleries on success', () async {
      final data = {
        'findGalleries': {
          'count': 1,
          'galleries': [
            {
              'id': '1',
              'title': 'Test Gallery',
              'date': '2023-01-01',
              'urls': ['http://test.com/gallery'],
              'details': 'Gallery details',
              'rating100': 100,
              'organized': true,
              'image_count': 10,
              'tags': [],
              'performers': [],
              'studios': [],
              'files': [],
              'paths': {
                'cover': 'http://cover.path',
                '__typename': 'GalleryPathsType',
              },
              'cover': null,
              '__typename': 'Gallery',
            },
          ],
          '__typename': 'GalleryQueryResult',
        },
        '__typename': 'Query',
      };

      final options = Options$Query$FindGalleries(
        variables: Variables$Query$FindGalleries(
          filter: Input$FindFilterType(
            page: 1,
            per_page: 20,
            sort: null,
            direction: Enum$SortDirectionEnum.ASC,
          ),
          gallery_filter: Input$GalleryFilterType(),
        ),
      );

      final mockQueryResult = QueryResult<Query$FindGalleries>(
        source: QueryResultSource.network,
        data: data,
        options: options,
      );

      when(
        mockClient.query<Query$FindGalleries>(any),
      ).thenAnswer((_) async => mockQueryResult);

      final result = await repository.findGalleries(page: 1, perPage: 20);

      expect(result, isA<List<Gallery>>());
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.title, 'Test Gallery');
      expect(result.first.imageCount, 10);
    });

    test('getGalleryById returns a gallery on success', () async {
      final data = {
        'findGallery': {
          'id': '1',
          'title': 'Test Gallery',
          'date': '2023-01-01',
          'urls': ['http://test.com/gallery'],
          'details': 'Gallery details',
          'rating100': 100,
          'organized': true,
          'image_count': 10,
          'tags': [],
          'performers': [],
          'studios': [],
          'files': [],
          'paths': {
            'cover': 'http://cover.path',
            '__typename': 'GalleryPathsType',
          },
          'cover': null,
          '__typename': 'Gallery',
        },
        '__typename': 'Query',
      };

      final options = Options$Query$FindGallery(
        variables: Variables$Query$FindGallery(id: '1'),
      );

      final mockQueryResult = QueryResult<Query$FindGallery>(
        source: QueryResultSource.network,
        data: data,
        options: options,
      );

      when(
        mockClient.query<Query$FindGallery>(any),
      ).thenAnswer((_) async => mockQueryResult);

      final result = await repository.getGalleryById('1');

      expect(result, isA<Gallery>());
      expect(result.id, '1');
      expect(result.title, 'Test Gallery');
    });

    test('findGalleries throws exception on GraphQL error', () async {
      final options = Options$Query$FindGalleries(
        variables: Variables$Query$FindGalleries(
          filter: Input$FindFilterType(),
          gallery_filter: Input$GalleryFilterType(),
        ),
      );

      final mockQueryResult = QueryResult<Query$FindGalleries>(
        source: QueryResultSource.network,
        options: options,
        exception: OperationException(
          graphqlErrors: [const GraphQLError(message: 'Error')],
        ),
      );

      when(
        mockClient.query<Query$FindGalleries>(any),
      ).thenAnswer((_) async => mockQueryResult);

      expect(() => repository.findGalleries(), throwsA(isA<OperationException>()));
    });
  });
}
