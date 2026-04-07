import 'package:graphql/client.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../domain/entities/image.dart';
import '../../domain/repositories/image_repository.dart';
import '../graphql/images.graphql.dart';

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
    final result = await client.query$FindImages(
      Options$Query$FindImages(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.cacheAndNetwork,
        variables: Variables$Query$FindImages(
          filter: Input$FindFilterType(
            q: filter,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          image_filter: Input$ImageFilterType(
            galleries: galleryId != null
                ? Input$MultiCriterionInput(
                    value: [galleryId],
                    modifier: Enum$CriterionModifier.INCLUDES,
                  )
                : null,
            rating100: imageFilter?.minRating != null
                ? Input$IntCriterionInput(
                    value: imageFilter!.minRating!,
                    modifier: Enum$CriterionModifier.GREATER_THAN,
                  )
                : null,
            organized: imageFilter?.organized,
            resolution: (imageFilter?.resolutions?.isNotEmpty ?? false)
                ? Input$ResolutionCriterionInput(
                    value: fromJson$Enum$ResolutionEnum(
                      imageFilter!.resolutions!.first,
                    ),
                    modifier: Enum$CriterionModifier.EQUALS,
                  )
                : null,
            orientation: (imageFilter?.orientations?.isNotEmpty ?? false)
                ? Input$OrientationCriterionInput(
                    value: imageFilter!.orientations!
                        .map((o) => fromJson$Enum$OrientationEnum(o))
                        .toList(),
                  )
                : null,
          ),
        ),
      ),
    );

    if (result.hasException) throw result.exception!;

    return result.parsedData!.findImages.images.map((i) {
      final map = i.toJson();
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
    final result = await client.query$FindImage(
      Options$Query$FindImage(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindImage(id: id),
      ),
    );

    if (result.hasException) throw result.exception!;
    final data = result.parsedData!.findImage;
    if (data == null) throw Exception('Image not found');

    final map = data.toJson();
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

  @override
  /// Sends a direct `imageUpdate` GraphQL mutation for `rating100`.
  ///
  /// This method intentionally uses a lightweight inline mutation because only
  /// the rating field needs to be updated from the fullscreen viewer flow.
  /// Callers should update local list/detail state separately after success.
  Future<void> updateImageRating(String id, int rating100) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation UpdateImageRating($id: ID!, $rating: Int!) {
            imageUpdate(input: { id: $id, rating100: $rating }) {
              id
              rating100
            }
          }
        '''),
        variables: {'id': id, 'rating': rating100},
      ),
    );

    if (result.hasException) throw result.exception!;
  }
}
