import 'package:graphql/client.dart';
import '../../domain/entities/image.dart';
import '../../domain/repositories/image_repository.dart';

class GraphQLImageRepository implements ImageRepository {
  final GraphQLClient client;

  GraphQLImageRepository(this.client);

  @override
  Future<List<Image>> findImages({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    String? galleryId,
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
              width
              height
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
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        document: gql(query),
        variables: {
          'filter': {
            'page': page,
            'per_page': perPage,
            'sort': sort,
            'direction': descending == true ? 'DESC' : 'ASC',
          },
          'image_filter': {
            if (filter != null)
              'title': {'value': filter, 'modifier': 'INCLUDES'},
            if (galleryId != null)
              'galleries': {
                'value': [galleryId],
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
            width
            height
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
    return Image.fromJson(map);
  }
}
