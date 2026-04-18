import 'package:graphql/client.dart';
import '../../../../core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart' as domain;
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_filter.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../graphql/galleries.graphql.dart';

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
    String? studioId,
    String? tagId,
  }) async {
    final inputFilter = Input$GalleryFilterType(
      title: mapStringCriterion(galleryFilter?.title),
      details: mapStringCriterion(galleryFilter?.details),
      url: mapStringCriterion(galleryFilter?.url),
      date: mapDateCriterion(galleryFilter?.date),
      rating100: mapIntCriterion(galleryFilter?.rating100) ??
          (galleryFilter?.minRating != null
              ? Input$IntCriterionInput(
                  value: galleryFilter!.minRating!,
                  modifier: Enum$CriterionModifier.GREATER_THAN,
                )
              : null),
      organized: galleryFilter?.organized,
      image_count: mapIntCriterion(galleryFilter?.imageCount) ??
          ((galleryFilter?.minImageCount != null ||
                  galleryFilter?.maxImageCount != null)
              ? Input$IntCriterionInput(
                  value: galleryFilter?.minImageCount ?? 0,
                  value2: galleryFilter?.maxImageCount,
                  modifier: galleryFilter?.minImageCount != null &&
                          galleryFilter?.maxImageCount != null
                      ? Enum$CriterionModifier.BETWEEN
                      : (galleryFilter?.minImageCount != null
                          ? Enum$CriterionModifier.GREATER_THAN
                          : Enum$CriterionModifier.LESS_THAN),
                )
              : null),
      studios: (studioId != null || galleryFilter?.studios != null)
          ? mapHierarchicalMultiCriterion(
              studioId != null
                  ? domain.HierarchicalMultiCriterion(value: [studioId])
                  : galleryFilter?.studios,
            )
          : null,
      performers: (performerId != null || galleryFilter?.performers != null)
          ? mapMultiCriterion(
              performerId != null
                  ? domain.MultiCriterion(value: [performerId])
                  : galleryFilter?.performers,
            )
          : null,
      tags: (tagId != null || galleryFilter?.tags != null)
          ? mapHierarchicalMultiCriterion(
              tagId != null
                  ? domain.HierarchicalMultiCriterion(value: [tagId])
                  : galleryFilter?.tags,
            )
          : null,
      is_missing: galleryFilter?.isMissing?.toString(),
      file_count: mapIntCriterion(galleryFilter?.fileCount),
      created_at: mapTimestampCriterion(galleryFilter?.createdAt),
      updated_at: mapTimestampCriterion(galleryFilter?.updatedAt),
    );

    final result = await client.query$FindGalleries(
      Options$Query$FindGalleries(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.cacheAndNetwork,
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

    if (result.hasException) throw result.exception!;

    return result.parsedData!.findGalleries.galleries
        .map((g) => Gallery.fromJson(g.toJson()))
        .toList();
  }

  @override
  Future<Gallery> getGalleryById(String id, {bool refresh = false}) async {
    final result = await client.query$FindGallery(
      Options$Query$FindGallery(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindGallery(id: id),
      ),
    );

    if (result.hasException) throw result.exception!;
    final data = result.parsedData?.findGallery;
    if (data == null) throw Exception('Gallery not found');

    return Gallery.fromJson(data.toJson());
  }

  @override
  Future<void> updateGalleryRating(String id, int rating100) async {
    final result = await client.mutate$UpdateGalleryRating(
      Options$Mutation$UpdateGalleryRating(
        variables: Variables$Mutation$UpdateGalleryRating(
          id: id,
          rating: rating100,
        ),
      ),
    );

    if (result.hasException) throw result.exception!;
  }
}
