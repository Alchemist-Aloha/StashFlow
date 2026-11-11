import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';
import '../../../../core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart'
    as domain;
import '../../domain/entities/image.dart';
import '../../domain/entities/image_filter.dart';
import '../graphql/images.graphql.dart';

class GraphQLImageRepository {
  final GraphQLClient _client;

  GraphQLImageRepository(this._client);

  Uri get _graphqlEndpoint => _client.link is HttpLink
      ? (_client.link as HttpLink).uri
      : Uri.parse('http://localhost:9999/graphql');

  Image _mapImage(Map<String, dynamic> map) {
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

    final studio = map['studio'] as Map<String, dynamic>?;
    map['studio_id'] = studio?['id']?.toString();
    map['studio_name'] = studio?['name']?.toString();
    final performers = (map['performers'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    map['performer_ids'] = performers
        .map((performer) => performer['id']?.toString() ?? '')
        .toList();
    map['performer_names'] = performers
        .map((performer) => performer['name']?.toString() ?? '')
        .toList();
    map['performer_image_paths'] = performers
        .map(
          (performer) => resolveGraphqlMediaUrl(
            rawUrl: performer['image_path']?.toString(),
            graphqlEndpoint: _graphqlEndpoint,
          ),
        )
        .toList();

    return Image.fromJson(map);
  }

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
      code: mapStringCriterion(imageFilter?.code),
      details: mapStringCriterion(imageFilter?.details),
      photographer: mapStringCriterion(imageFilter?.photographer),
      id: mapIntCriterion(imageFilter?.id),
      checksum: mapStringCriterion(imageFilter?.checksum),
      path: mapStringCriterion(imageFilter?.path),
      phash_distance: mapPhashCriterion(imageFilter?.phashDistance),
      files_filter: imageFilter?.folder == null
          ? null
          : Input$FileFilterType(
              parent_folder: mapHierarchicalMultiCriterion(imageFilter?.folder),
            ),
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
                  .map(fromJson$Enum$OrientationEnum)
                  .toList(),
            )
          : null,
      is_missing: imageFilter?.isMissing,
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
      galleries_filter: imageFilter?.galleriesFilter == null
          ? null
          : Input$GalleryFilterType(
              performers: mapMultiCriterion(
                imageFilter!.galleriesFilter!.performers,
              ),
              studios: mapHierarchicalMultiCriterion(
                imageFilter.galleriesFilter!.studios,
              ),
              tags: mapHierarchicalMultiCriterion(
                imageFilter.galleriesFilter!.tags,
              ),
            ),
      created_at: mapTimestampCriterion(imageFilter?.createdAt),
      updated_at: mapTimestampCriterion(imageFilter?.updatedAt),
      custom_fields: mapCustomFieldCriteria(
        imageFilter?.customFields ?? const [],
      ),
    );

    final result = await _client.query$FindImages(
      Options$Query$FindImages(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.networkOnly,
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

    validateGraphQLResult(result);

    return result.parsedData!.findImages.images
        .map((image) => _mapImage(image.toJson()))
        .toList();
  }

  Future<Image> getImageById(String id, {bool refresh = false}) async {
    final result = await _client.query$FindImage(
      Options$Query$FindImage(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindImage(id: id),
      ),
    );

    validateGraphQLResult(result);
    final data = result.parsedData!.findImage;
    if (data == null) throw Exception('Image not found');

    return _mapImage(data.toJson());
  }

  /// Sends a direct `imageUpdate` GraphQL mutation for `rating100`.
  ///
  /// This method intentionally uses a lightweight inline mutation because only
  /// the rating field needs to be updated from the fullscreen viewer flow.
  /// Callers should update local list/detail state separately after success.
  Future<void> updateImageRating(String id, int rating100) async {
    final result = await _client.mutate(
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

    validateGraphQLResult(result);
  }
}
