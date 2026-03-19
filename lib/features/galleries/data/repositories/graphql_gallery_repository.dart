import 'package:graphql/client.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/repositories/gallery_repository.dart';

class GraphQLGalleryRepository implements GalleryRepository {
  final GraphQLClient client;

  GraphQLGalleryRepository(this.client);

  @override
  Future<List<Gallery>> findGalleries({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
  }) async {
    const query = r'''
      query FindGalleries($filter: FindFilterType, $gallery_filter: GalleryFilterType) {
        findGalleries(filter: $filter, gallery_filter: $gallery_filter) {
          galleries {
            id
            title
          }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {
          'filter': {
            'page': page,
            'per_page': perPage,
            'sort': sort,
            'direction': descending == true ? 'DESC' : 'ASC',
          },
          'gallery_filter': filter != null
              ? {
                  'title': {
                    'value': filter,
                    'modifier': 'EQUALS',
                  },
                }
              : null,
        },
      ),
    );

    if (result.hasException) throw result.exception!;

    final galleriesJson =
        result.data?['findGalleries']?['galleries'] as List<dynamic>? ?? [];
    return galleriesJson
        .map((g) => Gallery.fromJson(g as Map<String, dynamic>))
        .toList();
  }
}
