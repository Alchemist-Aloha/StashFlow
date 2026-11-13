import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../graphql/tags.graphql.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/tag_filter.dart';

class GraphQLTagRepository {
  final GraphQLClient _client;
  GraphQLTagRepository(this._client);

  Uri get _graphqlEndpoint => _client.link is HttpLink
      ? (_client.link as HttpLink).uri
      : Uri.parse('http://localhost:9999/graphql');
  Future<List<Tag>> findTags({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    bool favoritesOnly = false,
    TagFilter? tagFilter,
  }) async {
    QueryResult<Query$FindTags> result;
    String? effectiveSort = sort == 'scene_count' ? 'scenes_count' : sort;

    result = await _runFindTags(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: effectiveSort,
      descending: descending,
      favoritesOnly: favoritesOnly,
      tagFilter: tagFilter,
    );

    // Some servers may still use scene_count; retry if scenes_count is rejected.
    if (result.hasException &&
        effectiveSort == 'scenes_count' &&
        _isInvalidSort(result.exception!, 'scenes_count')) {
      effectiveSort = 'scene_count';
      result = await _runFindTags(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: effectiveSort,
        descending: descending,
        favoritesOnly: favoritesOnly,
        tagFilter: tagFilter,
      );
    }

    final shouldLocalSortBySceneCount =
        (sort == 'scene_count' || sort == 'scenes_count') &&
        result.hasException &&
        (_isInvalidSort(result.exception!, 'scenes_count') ||
            _isInvalidSort(result.exception!, 'scene_count'));

    if (shouldLocalSortBySceneCount) {
      result = await _runFindTags(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: null,
        descending: descending,
        favoritesOnly: favoritesOnly,
        tagFilter: tagFilter,
      );
    }

    validateGraphQLResult(result);

    final tags = result.parsedData!.findTags.tags
        .map(
          (t) => Tag(
            id: t.id,
            name: t.name,
            description: t.description,
            imagePath: resolveGraphqlMediaUrl(
              rawUrl: t.image_path,
              graphqlEndpoint: _graphqlEndpoint,
            ),
            sceneCount: t.scene_count,
            imageCount: t.image_count,
            galleryCount: t.gallery_count,
            performerCount: t.performer_count,
            favorite: t.favorite,
          ),
        )
        .toList();

    if (shouldLocalSortBySceneCount) {
      tags.sort(
        (a, b) => (descending == true)
            ? b.sceneCount.compareTo(a.sceneCount)
            : a.sceneCount.compareTo(b.sceneCount),
      );
    }

    return tags;
  }

  Future<QueryResult<Query$FindTags>> _runFindTags({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    required bool favoritesOnly,
    TagFilter? tagFilter,
  }) {
    return _client.query$FindTags(
      Options$Query$FindTags(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.networkOnly,
        variables: Variables$Query$FindTags(
          filter: Input$FindFilterType(
            q: filter,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          tag_filter: Input$TagFilterType(
            name: mapStringCriterion(tagFilter?.name),
            sort_name: mapStringCriterion(tagFilter?.sortName),
            aliases: mapStringCriterion(tagFilter?.aliases),
            favorite: favoritesOnly ? true : tagFilter?.favorite,
            description: mapStringCriterion(tagFilter?.description),
            is_missing: tagFilter?.isMissingField,
            scene_count: mapIntCriterion(tagFilter?.sceneCount),
            image_count: mapIntCriterion(tagFilter?.imageCount),
            gallery_count: mapIntCriterion(tagFilter?.galleryCount),
            performer_count: mapIntCriterion(tagFilter?.performerCount),
            studio_count: mapIntCriterion(tagFilter?.studioCount),
            group_count: mapIntCriterion(tagFilter?.groupCount),
            marker_count: mapIntCriterion(tagFilter?.markerCount),
            parents: mapHierarchicalMultiCriterion(tagFilter?.parents),
            children: mapHierarchicalMultiCriterion(tagFilter?.children),
            parent_count: mapIntCriterion(tagFilter?.parentCount),
            child_count: mapIntCriterion(tagFilter?.childCount),
            ignore_auto_tag: tagFilter?.ignoreAutoTag,
            stash_id_endpoint: mapStashIdCriterion(tagFilter?.stashIdEndpoint),
            created_at: mapTimestampCriterion(tagFilter?.createdAt),
            updated_at: mapTimestampCriterion(tagFilter?.updatedAt),
            custom_fields: mapCustomFieldCriteria(
              tagFilter?.customFields ?? const [],
            ),
          ),
        ),
      ),
    );
  }

  bool _isInvalidSort(OperationException exception, String attemptedSort) {
    return exception.graphqlErrors.any(
      (e) =>
          e.message.contains('invalid sort') &&
          e.message.contains(attemptedSort),
    );
  }

  Future<Tag> getTagById(String id, {bool refresh = false}) async {
    final result = await _client.query$FindTag(
      Options$Query$FindTag(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindTag(id: id),
      ),
    );

    validateGraphQLResult(result);
    final t = result.parsedData!.findTag;
    if (t == null) throw StateError('Tag not found');

    return Tag(
      id: t.id,
      name: t.name,
      description: t.description,
      imagePath: resolveGraphqlMediaUrl(
        rawUrl: t.image_path,
        graphqlEndpoint: _graphqlEndpoint,
      ),
      sceneCount: t.scene_count,
      imageCount: t.image_count,
      galleryCount: t.gallery_count,
      performerCount: t.performer_count,
      favorite: t.favorite,
    );
  }

  Future<void> setTagFavorite(String id, bool favorite) async {
    final result = await _client.mutate$UpdateTagFavorite(
      Options$Mutation$UpdateTagFavorite(
        variables: Variables$Mutation$UpdateTagFavorite(
          id: id,
          favorite: favorite,
        ),
      ),
    );

    validateGraphQLResult(result);
  }
}
