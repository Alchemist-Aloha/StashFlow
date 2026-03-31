import 'package:graphql/client.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/repositories/gallery_repository.dart';

import '../../domain/entities/gallery_filter.dart';

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
    GalleryFilter? galleryFilter,
    String? performerId,
  }) async {
    const query = r'''
      query FindGalleries($filter: FindFilterType, $gallery_filter: GalleryFilterType) {
        findGalleries(filter: $filter, gallery_filter: $gallery_filter) {
          galleries {
            id
            title
            date
            rating100
            image_count
            details
            files {
              path
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
          'gallery_filter': {
            if (performerId != null)
              'performers': {
                'value': [performerId],
                'modifier': 'INCLUDES',
              },
            if (galleryFilter?.minRating != null)
              'rating100': {
                'value': galleryFilter!.minRating,
                'modifier': 'GREATER_THAN',
              },
            if (galleryFilter?.organized != null)
              'organized': galleryFilter!.organized,
            if (galleryFilter?.minImageCount != null ||
                galleryFilter?.maxImageCount != null)
              'image_count': {
                if (galleryFilter?.minImageCount != null)
                  'value': galleryFilter!.minImageCount,
                if (galleryFilter?.maxImageCount != null)
                  'value2': galleryFilter!.maxImageCount,
                'modifier': galleryFilter?.minImageCount != null &&
                        galleryFilter?.maxImageCount != null
                    ? 'BETWEEN'
                    : (galleryFilter?.minImageCount != null
                        ? 'GREATER_THAN'
                        : 'LESS_THAN'),
              },
          },
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

  @override
  Future<Gallery> getGalleryById(String id, {bool refresh = false}) async {
    const query = r'''
      query FindGallery($id: ID!) {
        findGallery(id: $id) {
          id
          title
          date
          rating
          image_count
          details
          files {
            path
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
    final data = result.data?['findGallery'];
    if (data == null) throw Exception('Gallery not found');

    return Gallery.fromJson(data as Map<String, dynamic>);
  }
}
