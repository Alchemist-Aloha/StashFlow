import 'package:graphql/client.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../domain/entities/image.dart';
import '../../domain/repositories/image_repository.dart';

import '../../domain/entities/image_filter.dart';

class GraphQLImageRepository implements ImageRepository {
  final GraphQLClient client;

  GraphQLImageRepository(this.client);

  Uri get _graphqlEndpoint => client.link is HttpLink
      ? (client.link as HttpLink).uri
      : Uri.parse('http://localhost:9999/graphql');

  @override
  Future<List<Image>> findImages({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    String? galleryId,
    ImageFilter? imageFilter,
  }) async {
    const query = r'''
      query FindImages($filter: FindFilterType, $image_filter: ImageFilterType) {
        findImages(filter: $filter, image_filter: $image_filter) {
          images {
            id
            title
            rating100
            date
            urls
            visual_files {
              ... on ImageFile {
                width
                height
              }
              ... on VideoFile {
                width
                height
              }
            }
            paths {
              thumbnail
              preview
              image
            }
          }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        fetchPolicy: sort == 'random' ? FetchPolicy.noCache : FetchPolicy.cacheAndNetwork,
        document: gql(query),
        variables: {
          'filter': {
            'q': filter,
            'page': page,
            'per_page': perPage,
            'sort': sort,
            'direction': descending == true ? 'DESC' : 'ASC',
          },
          'image_filter': {
            if (galleryId != null)
              'galleries': {
                'value': [galleryId],
                'modifier': 'INCLUDES',
              },
            if (imageFilter?.minRating != null)
              'rating100': {
                'value': imageFilter!.minRating,
                'modifier': 'GREATER_THAN',
              },
            if (imageFilter?.organized != null)
              'organized': imageFilter!.organized,
            if (imageFilter?.resolutions != null &&
                imageFilter!.resolutions!.isNotEmpty)
              'resolution': {
                'value': imageFilter.resolutions!.first,
                'modifier': 'EQUALS',
              },
            if (imageFilter?.orientations != null &&
                imageFilter!.orientations!.isNotEmpty)
              'orientation': {
                'value': imageFilter.orientations!,
                'modifier': 'INCLUDES',
              },
          },
        },
      ),
    );

    if (result.hasException) throw result.exception!;

    final imagesJson =
        result.data?['findImages']?['images'] as List<dynamic>? ?? [];
    return imagesJson.map((i) {
      final map = Map<String, dynamic>.from(i as Map<String, dynamic>);
      map['files'] = map['visual_files'];

      final paths = map['paths'] as Map<String, dynamic>;
      map['paths'] = {
        'thumbnail': resolveGraphqlMediaUrl(
          rawUrl: paths['thumbnail'] as String?,
          graphqlEndpoint: _graphqlEndpoint,
        ),
        'preview': resolveGraphqlMediaUrl(
          rawUrl: paths['preview'] as String?,
          graphqlEndpoint: _graphqlEndpoint,
        ),
        'image': resolveGraphqlMediaUrl(
          rawUrl: paths['image'] as String?,
          graphqlEndpoint: _graphqlEndpoint,
        ),
      };

      return Image.fromJson(map);
    }).toList();
  }

  @override
  Future<Image> getImageById(String id, {bool refresh = false}) async {
    const query = r'''
      query FindImage($id: ID!) {
        findImage(id: $id) {
          id
          title
          rating100
          date
          urls
          visual_files {
            ... on ImageFile {
              width
              height
            }
            ... on VideoFile {
              width
              height
            }
          }
          paths {
            thumbnail
            preview
            image
          }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        document: gql(query),
        variables: {'id': id},
      ),
    );

    if (result.hasException) throw result.exception!;
    final data = result.data?['findImage'];
    if (data == null) throw Exception('Image not found');

    final map = Map<String, dynamic>.from(data as Map<String, dynamic>);
    map['files'] = map['visual_files'];

    final paths = map['paths'] as Map<String, dynamic>;
    map['paths'] = {
      'thumbnail': resolveGraphqlMediaUrl(
        rawUrl: paths['thumbnail'] as String?,
        graphqlEndpoint: _graphqlEndpoint,
      ),
      'preview': resolveGraphqlMediaUrl(
        rawUrl: paths['preview'] as String?,
        graphqlEndpoint: _graphqlEndpoint,
      ),
      'image': resolveGraphqlMediaUrl(
        rawUrl: paths['image'] as String?,
        graphqlEndpoint: _graphqlEndpoint,
      ),
    };

    return Image.fromJson(map);
  }
}
