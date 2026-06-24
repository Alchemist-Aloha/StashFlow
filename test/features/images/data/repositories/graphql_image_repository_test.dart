import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';
import 'package:stash_app_flutter/core/data/graphql/schema.graphql.dart';
import 'package:stash_app_flutter/features/images/data/repositories/graphql_image_repository.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image_filter.dart';
import 'package:stash_app_flutter/features/images/data/graphql/images.graphql.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery_filter.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

import 'graphql_image_repository_test.mocks.dart';

@GenerateMocks([GraphQLClient])
void main() {
  late GraphQLImageRepository repository;
  late MockGraphQLClient mockClient;

  setUp(() {
    mockClient = MockGraphQLClient();
    repository = GraphQLImageRepository(mockClient);
    when(mockClient.link).thenReturn(HttpLink('http://localhost:9999/graphql'));
  });

  group('GraphQLImageRepository', () {
    test('findImages returns a list of images on success', () async {
      final data = {
        'findImages': {
          'count': 1,
          'images': [
            {
              'id': '1',
              'title': 'Test Image',
              'rating100': 80,
              'date': '2023-01-01',
              'urls': ['http://test.com/img.jpg'],
              'visual_files': [
                {
                  'width': 100,
                  'height': 100,
                  'path': '/path/to/img.jpg',
                  '__typename': 'ImageFile',
                },
              ],
              'paths': {
                'thumbnail': 'thumb.jpg',
                'preview': 'prev.jpg',
                'image': 'full.jpg',
                '__typename': 'ImagePathsType',
              },
              '__typename': 'Image',
            },
          ],
          '__typename': 'ImageQueryResult',
        },
        '__typename': 'Query',
      };

      final options = Options$Query$FindImages(
        variables: Variables$Query$FindImages(
          filter: Input$FindFilterType(
            page: 1,
            per_page: 20,
            sort: null,
            direction: Enum$SortDirectionEnum.ASC,
          ),
          image_filter: Input$ImageFilterType(),
        ),
      );

      final mockQueryResult = QueryResult<Query$FindImages>(
        source: QueryResultSource.network,
        data: data,
        options: options,
      );

      when(
        mockClient.query<Query$FindImages>(any),
      ).thenAnswer((_) async => mockQueryResult);

      final result = await repository.findImages(page: 1, perPage: 20);

      expect(result, isA<List<Image>>());
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.title, 'Test Image');
      expect(result.first.paths.thumbnail, 'http://localhost:9999/thumb.jpg');
    });

    test('findImages sends related gallery criteria', () async {
      final options = Options$Query$FindImages(
        variables: Variables$Query$FindImages(
          filter: Input$FindFilterType(),
          image_filter: Input$ImageFilterType(),
        ),
      );
      final mockQueryResult = QueryResult<Query$FindImages>(
        source: QueryResultSource.network,
        data: const {
          'findImages': {
            'count': 0,
            'images': [],
            '__typename': 'ImageQueryResult',
          },
          '__typename': 'Query',
        },
        options: options,
      );
      when(
        mockClient.query<Query$FindImages>(any),
      ).thenAnswer((_) async => mockQueryResult);

      await repository.findImages(
        imageFilter: const ImageFilter(
          galleriesFilter: GalleryFilter(
            performers: MultiCriterion(value: ['performer-1']),
            studios: HierarchicalMultiCriterion(value: ['studio-1']),
            tags: HierarchicalMultiCriterion(value: ['tag-1']),
          ),
        ),
      );

      final request =
          verify(mockClient.query<Query$FindImages>(captureAny)).captured.single
              as Options$Query$FindImages;
      expect(
        request.variables['image_filter'],
        containsPair('galleries_filter', {
          'performers': {
            'value': ['performer-1'],
            'modifier': 'INCLUDES',
          },
          'studios': {
            'value': ['studio-1'],
            'modifier': 'INCLUDES',
          },
          'tags': {
            'value': ['tag-1'],
            'modifier': 'INCLUDES',
          },
        }),
      );
    });

    test('getImageById returns an image on success', () async {
      final data = {
        'findImage': {
          'id': '1',
          'title': 'Test Image',
          'rating100': 80,
          'date': '2023-01-01',
          'urls': ['http://test.com/img.jpg'],
          'visual_files': [
            {
              'width': 100,
              'height': 100,
              'path': '/path/to/img.jpg',
              '__typename': 'ImageFile',
            },
          ],
          'paths': {
            'thumbnail': 'thumb.jpg',
            'preview': 'prev.jpg',
            'image': 'full.jpg',
            '__typename': 'ImagePathsType',
          },
          '__typename': 'Image',
        },
        '__typename': 'Query',
      };

      final options = Options$Query$FindImage(
        variables: Variables$Query$FindImage(id: '1'),
      );

      final mockQueryResult = QueryResult<Query$FindImage>(
        source: QueryResultSource.network,
        data: data,
        options: options,
      );

      when(
        mockClient.query<Query$FindImage>(any),
      ).thenAnswer((_) async => mockQueryResult);

      final result = await repository.getImageById('1');

      expect(result, isA<Image>());
      expect(result.id, '1');
      expect(result.title, 'Test Image');
      expect(result.paths.thumbnail, 'http://localhost:9999/thumb.jpg');
    });

    test('findImages throws exception on GraphQL error', () async {
      final options = Options$Query$FindImages(
        variables: Variables$Query$FindImages(
          filter: Input$FindFilterType(),
          image_filter: Input$ImageFilterType(),
        ),
      );

      final mockQueryResult = QueryResult<Query$FindImages>(
        source: QueryResultSource.network,
        options: options,
        exception: OperationException(
          graphqlErrors: [const GraphQLError(message: 'Error')],
        ),
      );

      when(
        mockClient.query<Query$FindImages>(any),
      ).thenAnswer((_) async => mockQueryResult);

      expect(
        () => repository.findImages(),
        throwsA(
          isA<AppGraphQLException>().having(
            (e) => e.kind,
            'kind',
            GraphQLFailureKind.schema,
          ),
        ),
      );
    });
  });
}
