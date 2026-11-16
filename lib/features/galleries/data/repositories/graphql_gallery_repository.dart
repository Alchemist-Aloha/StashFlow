import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';

import '../../../../core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';

import 'package:stash_app_flutter/core/domain/entities/criterion.dart'
    as domain;

import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_filter.dart';
import '../graphql/galleries.graphql.dart';

class GraphQLGalleryRepository {
  final GraphQLClient _client;

  GraphQLGalleryRepository(this._client);

  Uri get _graphqlEndpoint => _client.link is HttpLink
      ? (_client.link as HttpLink).uri
      : Uri.parse('http://localhost:9999/graphql');

  Gallery _mapGallery(Map<String, dynamic> json) {
    final performers = (json['performers'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (performer) => <String, dynamic>{
            ...performer,
            'image_path': resolveGraphqlMediaUrl(
              rawUrl: performer['image_path']?.toString(),
              graphqlEndpoint: _graphqlEndpoint,
            ),
          },
        )
        .toList();
    return Gallery.fromJson({...json, 'performers': performers});
  }

  Future<List<Gallery>> findGalleries({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    GalleryFilter? galleryFilter,
    String? performerId,
    String? studioId,
    String? tagId,
  }) async {
    final inputFilter = Input$GalleryFilterType(
      id: mapIntCriterion(galleryFilter?.id),
      title: mapStringCriterion(galleryFilter?.title),
      code: mapStringCriterion(galleryFilter?.code),
      details: mapStringCriterion(galleryFilter?.details),
      photographer: mapStringCriterion(galleryFilter?.photographer),
      checksum: mapStringCriterion(galleryFilter?.checksum),
      path: mapStringCriterion(galleryFilter?.path),
      parent_folder: mapHierarchicalMultiCriterion(galleryFilter?.parentFolder),
      file_count: mapIntCriterion(galleryFilter?.fileCount),
      is_missing: galleryFilter?.isMissing,
      is_zip: galleryFilter?.isZip,
      rating100: mapIntCriterion(galleryFilter?.rating100),
      organized: galleryFilter?.organized,
      average_resolution: mapResolutionCriterion(
        galleryFilter?.averageResolution,
      ),
      has_chapters: galleryFilter?.hasChapters?.toString(),
      scenes: galleryFilter?.scenes != null
          ? mapMultiCriterion(galleryFilter?.scenes)
          : null,
      studios: (studioId != null || galleryFilter?.studios != null)
          ? mapHierarchicalMultiCriterion(
              studioId != null
                  ? domain.HierarchicalMultiCriterion(value: [studioId])
                  : galleryFilter?.studios,
            )
          : null,
      tags: (tagId != null || galleryFilter?.tags != null)
          ? mapHierarchicalMultiCriterion(
              tagId != null
                  ? domain.HierarchicalMultiCriterion(value: [tagId])
                  : galleryFilter?.tags,
            )
          : null,
      tag_count: mapIntCriterion(galleryFilter?.tagCount),
      performer_tags: mapHierarchicalMultiCriterion(
        galleryFilter?.performerTags,
      ),
      performers: (performerId != null || galleryFilter?.performers != null)
          ? mapMultiCriterion(
              performerId != null
                  ? domain.MultiCriterion(value: [performerId])
                  : galleryFilter?.performers,
            )
          : null,
      performer_count: mapIntCriterion(galleryFilter?.performerCount),
      performer_favorite: galleryFilter?.performerFavorite,
      performer_age: mapIntCriterion(galleryFilter?.performerAge),
      image_count: mapIntCriterion(galleryFilter?.imageCount),
      url: mapStringCriterion(galleryFilter?.url),
      date: mapDateCriterion(galleryFilter?.date),
      created_at: mapTimestampCriterion(galleryFilter?.createdAt),
      updated_at: mapTimestampCriterion(galleryFilter?.updatedAt),
      custom_fields: mapCustomFieldCriteria(
        galleryFilter?.customFields ?? const [],
      ),
    );

    final result = await _client.query$FindGalleries(
      Options$Query$FindGalleries(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.networkOnly,
        variables: Variables$Query$FindGalleries(
          filter: Input$FindFilterType(
            q: filter ?? galleryFilter?.searchQuery,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          gallery_filter: inputFilter,
        ),
      ),
    );

    validateGraphQLResult(result);

    return result.parsedData!.findGalleries.galleries
        .map((g) => _mapGallery(g.toJson()))
        .toList();
  }

  Future<Gallery> getGalleryById(String id, {bool refresh = false}) async {
    final result = await _client.query$FindGallery(
      Options$Query$FindGallery(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindGallery(id: id),
      ),
    );

    validateGraphQLResult(result);
    final data = result.parsedData?.findGallery;
    if (data == null) throw Exception('Gallery not found');

    return _mapGallery(data.toJson());
  }

  Future<void> updateGalleryRating(String id, int rating100) async {
    final result = await _client.mutate$UpdateGalleryRating(
      Options$Mutation$UpdateGalleryRating(
        variables: Variables$Mutation$UpdateGalleryRating(
          id: id,
          rating: rating100,
        ),
      ),
    );

    validateGraphQLResult(result);
  }
}
