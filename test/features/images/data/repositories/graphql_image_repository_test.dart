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
              'studio': {
                'id': 'studio-1',
                'name': 'Studio One',
                '__typename': 'Studio',
              },
              'performers': [
                {
                  'id': 'performer-1',
                  'name': 'Performer One',
                  'image_path': '/performer/1/image',
                  '__typename': 'Performer',
                },
              ],
              'visual_files': [
                {
                  'width': 100,
                  'height': 100,
                  'path': '/path/to/img.jpg',
                  'size': 1572864,
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
      expect(result.first.files.single.size, 1572864);
      expect(result.first.paths.thumbnail, 'http://localhost:9999/thumb.jpg');
      expect(result.first.studioName, 'Studio One');
      expect(result.first.performerNames, ['Performer One']);
      expect(result.first.performerImagePaths, [
        'http://localhost:9999/performer/1/image',
      ]);
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
            'images': <dynamic>[],
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
          code: StringCriterion(value: 'IMG-1'),
          photographer: StringCriterion(value: 'Alice'),
          phashDistance: PhashCriterion(value: 'abc', distance: 3),
          folder: HierarchicalMultiCriterion(value: ['folder-1']),
          isMissing: 'rating',
          customFields: [
            CustomFieldCriterion(field: 'source', value: ['archive']),
          ],
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
      final filter = request.variables['image_filter'] as Map<String, dynamic>;
      expect((filter['code'] as Map<String, dynamic>)['value'], 'IMG-1');
      expect(
        (filter['photographer'] as Map<String, dynamic>)['value'],
        'Alice',
      );
      expect((filter['phash_distance'] as Map<String, dynamic>)['distance'], 3);
      expect(
        ((filter['files_filter'] as Map<String, dynamic>)['parent_folder']
            as Map<String, dynamic>)['value'],
        ['folder-1'],
      );
      expect(filter['is_missing'], 'rating');
      expect(
        (filter['custom_fields'] as List)
            .cast<Map<String, dynamic>>()
            .single['field'],
        'source',
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
          'studio': null,
          'performers': <dynamic>[],
          'visual_files': [
            {
              'width': 100,
              'height': 100,
              'path': '/path/to/img.jpg',
              'size': 3221225472,
              '__typename': 'VideoFile',
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
      expect(result.files.single.size, 3221225472);
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
