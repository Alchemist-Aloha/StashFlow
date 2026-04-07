import 'package:graphql/client.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../graphql/galleries.graphql.dart';

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
    String? studioId,
    String? tagId,
  }) async {
    final result = await client.query$FindGalleries(
      Options$Query$FindGalleries(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.cacheAndNetwork,
        variables: Variables$Query$FindGalleries(
          filter: Input$FindFilterType(
            q: filter,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          gallery_filter: Input$GalleryFilterType(
            performers: performerId != null
                ? Input$MultiCriterionInput(
                    value: [performerId],
                    modifier: Enum$CriterionModifier.INCLUDES,
                  )
                : null,
            studios: studioId != null
                ? Input$HierarchicalMultiCriterionInput(
                    value: [studioId],
                    modifier: Enum$CriterionModifier.INCLUDES,
                  )
                : null,
            tags: tagId != null
                ? Input$HierarchicalMultiCriterionInput(
                    value: [tagId],
                    modifier: Enum$CriterionModifier.INCLUDES,
                  )
                : null,
            rating100: galleryFilter?.minRating != null
                ? Input$IntCriterionInput(
                    value: galleryFilter!.minRating!,
                    modifier: Enum$CriterionModifier.GREATER_THAN,
                  )
                : null,
            organized: galleryFilter?.organized,
            image_count:
                (galleryFilter?.minImageCount != null ||
                    galleryFilter?.maxImageCount != null)
                ? Input$IntCriterionInput(
                    value: galleryFilter?.minImageCount ?? 0,
                    value2: galleryFilter?.maxImageCount,
                    modifier:
                        galleryFilter?.minImageCount != null &&
                            galleryFilter?.maxImageCount != null
                        ? Enum$CriterionModifier.BETWEEN
                        : (galleryFilter?.minImageCount != null
                              ? Enum$CriterionModifier.GREATER_THAN
                              : Enum$CriterionModifier.LESS_THAN),
                  )
                : null,
          ),
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
