import 'package:graphql/client.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../graphql/tags.graphql.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';

class GraphQLTagRepository implements TagRepository {
  final GraphQLClient client;
  GraphQLTagRepository(this.client);

  Uri get _graphqlEndpoint => client.link is HttpLink
      ? (client.link as HttpLink).uri
      : Uri.parse('http://localhost:9999/graphql');

  @override
  Future<List<Tag>> findTags({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    bool favoritesOnly = false,
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
      );
    }

    if (result.hasException) throw result.exception!;

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
  }) {
    return client.query$FindTags(
      Options$Query$FindTags(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.cacheAndNetwork,
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
          tag_filter: favoritesOnly ? Input$TagFilterType(favorite: true) : null,
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

  @override
  Future<Tag> getTagById(String id, {bool refresh = false}) async {
    final result = await client.query$FindTag(
      Options$Query$FindTag(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindTag(id: id),
      ),
    );

    if (result.hasException) throw result.exception!;
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

  @override
  Future<void> setTagFavorite(String id, bool favorite) async {
    final result = await client.mutate$UpdateTagFavorite(
      Options$Mutation$UpdateTagFavorite(
        variables: Variables$Mutation$UpdateTagFavorite(
          id: id,
          favorite: favorite,
        ),
      ),
    );

    if (result.hasException) throw result.exception!;
  }
}
