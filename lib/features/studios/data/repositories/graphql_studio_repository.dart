import 'package:graphql/client.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../graphql/studios.graphql.dart';
import '../../domain/entities/studio.dart';
import '../../domain/repositories/studio_repository.dart';

class GraphQLStudioRepository implements StudioRepository {
  final GraphQLClient client;
  GraphQLStudioRepository(this.client);

  @override
  Future<List<Studio>> findStudios({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
  }) async {
    final result = await client.query$FindStudios(
      Options$Query$FindStudios(
        variables: Variables$Query$FindStudios(
          filter: Input$FindFilterType(
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          studio_filter: filter != null
              ? Input$StudioFilterType(
                  name: Input$StringCriterionInput(
                    value: filter,
                    modifier: Enum$CriterionModifier.EQUALS,
                  ),
                )
              : null,
        ),
      ),
    );

    if (result.hasException) throw result.exception!;

    return result.parsedData!.findStudios.studios
        .map(
          (s) => Studio(
            id: s.id,
            name: s.name,
            url: s.url,
            imagePath: s.image_path,
            details: s.details,
            rating100: s.rating100,
            sceneCount: s.scene_count,
            imageCount: s.image_count,
            galleryCount: s.gallery_count,
            performerCount: s.performer_count,
            favorite: s.favorite,
          ),
        )
        .toList();
  }

  @override
  Future<Studio> getStudioById(String id) async {
    final result = await client.query$FindStudio(
      Options$Query$FindStudio(variables: Variables$Query$FindStudio(id: id)),
    );

    if (result.hasException) throw result.exception!;
    final s = result.parsedData!.findStudio;
    if (s == null) throw StateError('Studio not found');

    return Studio(
      id: s.id,
      name: s.name,
      url: s.url,
      imagePath: s.image_path,
      details: s.details,
      rating100: s.rating100,
      sceneCount: s.scene_count,
      imageCount: s.image_count,
      galleryCount: s.gallery_count,
      performerCount: s.performer_count,
      favorite: s.favorite,
    );
  }
}
