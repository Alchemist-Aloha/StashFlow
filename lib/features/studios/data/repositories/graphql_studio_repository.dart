import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';
import '../../../../core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart'
    as domain;
import '../../domain/entities/studio.dart';
import '../../domain/entities/studio_filter.dart';
import '../graphql/studios.graphql.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_studio.dart';

class GraphQLStudioRepository {
  final GraphQLClient _client;
  GraphQLStudioRepository(this._client);

  Uri get _graphqlEndpoint => _client.link is HttpLink
      ? (_client.link as HttpLink).uri
      : Uri.parse('http://localhost:9999/graphql');

  Studio _mapStudio(Map<String, dynamic> json) {
    Map<String, dynamic>? resolveRelationship(Object? value) {
      if (value is! Map<String, dynamic>) return null;
      return {
        ...value,
        'image_path': resolveGraphqlMediaUrl(
          rawUrl: value['image_path']?.toString(),
          graphqlEndpoint: _graphqlEndpoint,
        ),
      };
    }

    return Studio.fromJson({
      ...json,
      'image_path': resolveGraphqlMediaUrl(
        rawUrl: json['image_path']?.toString(),
        graphqlEndpoint: _graphqlEndpoint,
      ),
      'parent_studio': resolveRelationship(json['parent_studio']),
      'child_studios': (json['child_studios'] as List<dynamic>? ?? const [])
          .map(resolveRelationship)
          .whereType<Map<String, dynamic>>()
          .toList(),
    });
  }

  Future<List<Studio>> findStudios({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    StudioFilter? studioFilter,
  }) async {
    QueryResult<Query$FindStudios> result;
    String? effectiveSort = sort == 'scene_count' ? 'scenes_count' : sort;

    result = await _runFindStudios(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: effectiveSort,
      descending: descending,
      studioFilter: studioFilter,
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
        studioFilter: studioFilter,
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
        studioFilter: studioFilter,
      );
    }

    validateGraphQLResult(result);

    final studios = result.parsedData!.findStudios.studios
        .map((studio) => _mapStudio(studio.toJson()))
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
    StudioFilter? studioFilter,
  }) {
    final inputFilter = Input$StudioFilterType(
      favorite: studioFilter?.favorite == true ? true : null,
      name: mapStringCriterion(studioFilter?.name),
      details: mapStringCriterion(studioFilter?.details),
      is_missing: studioFilter?.isMissing,
      stash_id_endpoint: mapStashIdCriterion(studioFilter?.stashIdEndpoint),
      parents: mapMultiCriterion(
        studioFilter?.parentStudios != null
            ? domain.MultiCriterion(
                value: studioFilter!.parentStudios!.value,
                modifier: studioFilter.parentStudios!.modifier,
              )
            : null,
      ),
      tags: mapHierarchicalMultiCriterion(studioFilter?.tags),
      rating100: mapIntCriterion(studioFilter?.rating100),
      ignore_auto_tag: studioFilter?.ignoreAutoTag,
      organized: studioFilter?.organized,
      tag_count: mapIntCriterion(studioFilter?.tagCount),
      scene_count: mapIntCriterion(studioFilter?.sceneCount),
      image_count: mapIntCriterion(studioFilter?.imageCount),
      gallery_count: mapIntCriterion(studioFilter?.galleryCount),
      url: mapStringCriterion(studioFilter?.url),
      aliases: mapStringCriterion(studioFilter?.aliases),
      child_count: mapIntCriterion(studioFilter?.childCount),
      created_at: mapTimestampCriterion(studioFilter?.createdAt),
      updated_at: mapTimestampCriterion(studioFilter?.updatedAt),
      custom_fields: mapCustomFieldCriteria(
        studioFilter?.customFields ?? const [],
      ),
    );

    return _client.query$FindStudios(
      Options$Query$FindStudios(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.networkOnly,
        variables: Variables$Query$FindStudios(
          filter: Input$FindFilterType(
            q: filter ?? studioFilter?.searchQuery,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending == true
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          studio_filter: inputFilter,
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

  Future<Studio> getStudioById(String id, {bool refresh = false}) async {
    final result = await _client.query$FindStudio(
      Options$Query$FindStudio(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindStudio(id: id),
      ),
    );

    validateGraphQLResult(result);
    final s = result.parsedData!.findStudio;
    if (s == null) throw StateError('Studio not found');

    return _mapStudio(s.toJson());
  }

  Future<void> setStudioFavorite(String id, bool favorite) async {
    final result = await _client.mutate$UpdateStudioFavorite(
      Options$Mutation$UpdateStudioFavorite(
        variables: Variables$Mutation$UpdateStudioFavorite(
          id: id,
          favorite: favorite,
        ),
      ),
    );

    validateGraphQLResult(result);
  }

  Future<List<ScrapedStudio>> scrapeStudio({
    String? scraperId,
    String? stashBoxEndpoint,
    String? studioId,
    String? query,
  }) async {
    final result = await _client.query$ScrapeSingleStudio(
      Options$Query$ScrapeSingleStudio(
        variables: Variables$Query$ScrapeSingleStudio(
          source: Input$ScraperSourceInput(
            scraper_id: scraperId,
            stash_box_endpoint: stashBoxEndpoint,
          ),
          input: Input$ScrapeSingleStudioInput(query: query),
        ),
      ),
    );

    validateGraphQLResult(result);

    final List<Query$ScrapeSingleStudio$scrapeSingleStudio> raw =
        result.parsedData?.scrapeSingleStudio ?? [];

    return raw.map((e) => ScrapedStudio.fromJson(e.toJson())).toList();
  }

  Future<ScrapedStudio?> scrapeStudioURL(String url) async {
    final results = await scrapeStudio(query: url);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateStudio({
    required String id,
    required Map<String, dynamic> input,
  }) async {
    final result = await _client.mutate$StudioUpdate(
      Options$Mutation$StudioUpdate(
        variables: Variables$Mutation$StudioUpdate(
          input: Input$StudioUpdateInput.fromJson({...input, 'id': id}),
        ),
      ),
    );

    validateGraphQLResult(result);
  }
}
