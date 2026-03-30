import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/features/images/data/repositories/graphql_image_repository.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart';

import 'graphql_image_repository_test.mocks.dart';

@GenerateMocks([GraphQLClient])
void main() {
  late GraphQLImageRepository repository;
  late MockGraphQLClient mockClient;

  setUp(() {
    mockClient = MockGraphQLClient();
    repository = GraphQLImageRepository(mockClient);
  });

  group('GraphQLImageRepository', () {
    test('findImages returns a list of images on success', () async {
      final mockQueryResult = QueryResult(
        source: QueryResultSource.network,
        data: {
          'findImages': {
            'images': [
              {
                'id': '1',
                'title': 'Test Image',
                'rating100': 80,
                'date': '2023-01-01',
                'urls': ['http://test.com/img.jpg'],
                'visual_files': [
                  {'width': 100, 'height': 100},
                ],
                'paths': {
                  'thumbnail': 'thumb.jpg',
                  'preview': 'prev.jpg',
                  'image': 'full.jpg',
                },
              },
            ],
          },
        },
        options: QueryOptions(document: gql('')),
      );

      when(mockClient.query(any)).thenAnswer((_) async => mockQueryResult);

      final result = await repository.findImages(page: 1, perPage: 20);

      expect(result, isA<List<Image>>());
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.title, 'Test Image');
    });

    test('getImageById returns an image on success', () async {
      final mockQueryResult = QueryResult(
        source: QueryResultSource.network,
        data: {
          'findImage': {
            'id': '1',
            'title': 'Test Image',
            'rating100': 80,
            'date': '2023-01-01',
            'urls': ['http://test.com/img.jpg'],
            'visual_files': [
              {'width': 100, 'height': 100},
            ],
            'paths': {
              'thumbnail': 'thumb.jpg',
              'preview': 'prev.jpg',
              'image': 'full.jpg',
            },
          },
        },
        options: QueryOptions(document: gql('')),
      );

      when(mockClient.query(any)).thenAnswer((_) async => mockQueryResult);

      final result = await repository.getImageById('1');

      expect(result, isA<Image>());
      expect(result.id, '1');
      expect(result.title, 'Test Image');
    });

    test('findImages throws exception on GraphQL error', () async {
      final mockQueryResult = QueryResult(
        source: QueryResultSource.network,
        options: QueryOptions(document: gql('')),
        exception: OperationException(
          graphqlErrors: [const GraphQLError(message: 'Error')],
        ),
      );

      when(mockClient.query(any)).thenAnswer((_) async => mockQueryResult);

      expect(() => repository.findImages(), throwsA(isA<OperationException>()));
    });
  });
}
