import 'package:graphql/client.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../graphql/tags.graphql.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';

class GraphQLTagRepository implements TagRepository {
  final GraphQLClient client;
  GraphQLTagRepository(this.client);

  @override
  Future<List<Tag>> findTags({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
  }) async {
    final result = await client.query$FindTags(
      Options$Query$FindTags(
        variables: Variables$Query$FindTags(
          filter: Input$FindFilterType(
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          tag_filter: filter != null
              ? Input$TagFilterType(
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

    return result.parsedData!.findTags.tags
        .map(
          (t) => Tag(
            id: t.id,
            name: t.name,
            description: t.description,
            imagePath: t.image_path,
            sceneCount: t.scene_count,
            imageCount: t.image_count,
            galleryCount: t.gallery_count,
            performerCount: t.performer_count,
            favorite: t.favorite,
          ),
        )
        .toList();
  }

  @override
  Future<Tag> getTagById(String id) async {
    final result = await client.query$FindTag(
      Options$Query$FindTag(variables: Variables$Query$FindTag(id: id)),
    );

    if (result.hasException) throw result.exception!;
    final t = result.parsedData!.findTag;
    if (t == null) throw StateError('Tag not found');

    return Tag(
      id: t.id,
      name: t.name,
      description: t.description,
      imagePath: t.image_path,
      sceneCount: t.scene_count,
      imageCount: t.image_count,
      galleryCount: t.gallery_count,
      performerCount: t.performer_count,
      favorite: t.favorite,
    );
  }
}
