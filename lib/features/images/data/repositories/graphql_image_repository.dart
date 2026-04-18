import 'package:graphql/client.dart';
import '../../../../core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart' as domain;
import '../../domain/entities/image.dart';
import '../../domain/entities/image_filter.dart';
import '../../domain/repositories/image_repository.dart';
import '../graphql/images.graphql.dart';

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
    final inputFilter = Input$ImageFilterType(
      title: mapStringCriterion(imageFilter?.title),
      details: mapStringCriterion(imageFilter?.details),
      id: mapIntCriterion(imageFilter?.id),
      checksum: mapStringCriterion(imageFilter?.checksum),
      path: mapStringCriterion(imageFilter?.path),
      file_count: mapIntCriterion(imageFilter?.fileCount),
      rating100: mapIntCriterion(imageFilter?.rating100),
      date: mapDateCriterion(imageFilter?.date),
      url: mapStringCriterion(imageFilter?.url),
      organized: imageFilter?.organized,
      o_counter: mapIntCriterion(imageFilter?.oCounter),
      resolution: mapResolutionCriterion(imageFilter?.resolution),
      orientation: (imageFilter?.orientation != null)
          ? Input$OrientationCriterionInput(
              value: imageFilter!.orientation!.value
                  .map((o) => fromJson$Enum$OrientationEnum(o))
                  .toList(),
            )
          : null,
      is_missing: imageFilter?.isMissing?.toString(),
      studios: mapHierarchicalMultiCriterion(imageFilter?.studios),
      tags: mapHierarchicalMultiCriterion(imageFilter?.tags),
      tag_count: mapIntCriterion(imageFilter?.tagCount),
      performer_tags: mapHierarchicalMultiCriterion(imageFilter?.performerTags),
      performers: mapMultiCriterion(imageFilter?.performers),
      performer_count: mapIntCriterion(imageFilter?.performerCount),
      performer_favorite: imageFilter?.performerFavorite,
      performer_age: mapIntCriterion(imageFilter?.performerAge),
      galleries: (galleryId != null || imageFilter?.galleries != null)
          ? mapMultiCriterion(
              galleryId != null
                  ? domain.MultiCriterion(value: [galleryId])
                  : imageFilter?.galleries,
            )
          : null,
      created_at: mapTimestampCriterion(imageFilter?.createdAt),
      updated_at: mapTimestampCriterion(imageFilter?.updatedAt),
    );

    final result = await client.query$FindImages(
      Options$Query$FindImages(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.cacheAndNetwork,
        variables: Variables$Query$FindImages(
          filter: Input$FindFilterType(
            q: filter ?? imageFilter?.searchQuery,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          image_filter: inputFilter,
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
