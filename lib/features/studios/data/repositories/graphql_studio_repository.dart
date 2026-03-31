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
    bool favoritesOnly = false,
  }) async {
    QueryResult<Query$FindStudios> result;
    String? effectiveSort = sort == 'scene_count' ? 'scenes_count' : sort;

    result = await _runFindStudios(
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
      result = await _runFindStudios(
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
      result = await _runFindStudios(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: null,
        descending: descending,
        favoritesOnly: favoritesOnly,
      );
    }

    if (result.hasException) throw result.exception!;

    final studios = result.parsedData!.findStudios.studios
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

    if (shouldLocalSortBySceneCount) {
      studios.sort(
        (a, b) => (descending == true)
            ? b.sceneCount.compareTo(a.sceneCount)
            : a.sceneCount.compareTo(b.sceneCount),
      );
    }

    return studios;
  }

  Future<QueryResult<Query$FindStudios>> _runFindStudios({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    required bool favoritesOnly,
  }) {
    return client.query$FindStudios(
      Options$Query$FindStudios(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.cacheAndNetwork,
        variables: Variables$Query$FindStudios(
          filter: Input$FindFilterType(
            q: filter,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          studio_filter: favoritesOnly
              ? Input$StudioFilterType(favorite: true)
              : null,
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
  Future<Studio> getStudioById(String id, {bool refresh = false}) async {
    final result = await client.query$FindStudio(
      Options$Query$FindStudio(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindStudio(id: id),
      ),
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

  @override
  Future<void> setStudioFavorite(String id, bool favorite) async {
    final result = await client.mutate$UpdateStudioFavorite(
      Options$Mutation$UpdateStudioFavorite(
        variables: Variables$Mutation$UpdateStudioFavorite(
          id: id,
          favorite: favorite,
        ),
      ),
    );

    if (result.hasException) throw result.exception!;
  }
}
