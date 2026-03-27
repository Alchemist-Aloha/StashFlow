import 'package:graphql/client.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../graphql/scenes.graphql.dart';
import '../../../performers/data/graphql/performers.graphql.dart';
import '../../../tags/data/graphql/tags.graphql.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../domain/models/scraper.dart';
import '../../domain/models/scraped_scene.dart';
import '../utils/scrape_normalizer.dart';

class GraphQLSceneRepository implements SceneRepository {
  final GraphQLClient client;
  GraphQLSceneRepository(this.client);

  Uri get _graphqlEndpoint => client.link is HttpLink
      ? (client.link as HttpLink).uri
      : Uri.parse('https://localhost/graphql');

  @override
  Future<List<Scene>> findScenes({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    bool? organized,
    bool? performerFavorite,
    String? performerId,
    String? studioId,
    String? tagId,
    SceneFilter? sceneFilter,
  }) async {
    String? effectiveSort = sort == 'rating100' ? 'rating' : sort;
    var result = await _runFindScenes(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: effectiveSort,
      descending: descending,
      organized: organized,
      performerFavorite: performerFavorite,
      performerId: performerId,
      studioId: studioId,
      tagId: tagId,
      sceneFilter: sceneFilter,
    );

    if (result.hasException &&
        effectiveSort == 'rating' &&
        _isInvalidSort(result.exception!, 'rating')) {
      effectiveSort = 'rating100';
      result = await _runFindScenes(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: effectiveSort,
        descending: descending,
        organized: organized,
        performerFavorite: performerFavorite,
        performerId: performerId,
        studioId: studioId,
        tagId: tagId,
        sceneFilter: sceneFilter,
      );
    }

    if (result.hasException) throw result.exception!;

    return result.parsedData!.findScenes.scenes
        .map(
          (s) => Scene(
            id: s.id,
            title: s.title ?? '',
            details: null,
            path: s.files.isNotEmpty ? s.files.first.path : null,
            date: DateTime.tryParse(s.date ?? '') ?? DateTime.now(),
            rating100: s.rating100,
            oCounter: s.o_counter ?? 0,
            organized: s.organized,
            interactive: s.interactive,
            resumeTime: s.resume_time,
            playCount: s.play_count ?? 0,
            files: s.files
                .map(
                  (f) => SceneFile(
                    format: null,
                    width: null,
                    height: null,
                    videoCodec: null,
                    audioCodec: null,
                    bitRate: null,
                    duration: f.duration,
                    frameRate: null,
                  ),
                )
                .toList(),
            paths: ScenePaths(
              screenshot: resolveGraphqlMediaUrl(
                rawUrl: s.paths.screenshot,
                graphqlEndpoint: _graphqlEndpoint,
              ),
              preview: resolveGraphqlMediaUrl(
                rawUrl: s.paths.preview,
                graphqlEndpoint: _graphqlEndpoint,
              ),
              stream: resolveGraphqlMediaUrl(
                rawUrl: s.paths.stream,
                graphqlEndpoint: _graphqlEndpoint,
              ),
            ),
            urls: const [],
            studioId: s.studio?.id,
            studioName: s.studio?.name,
            studioImagePath: resolveGraphqlMediaUrl(
              rawUrl: s.studio?.image_path,
              graphqlEndpoint: _graphqlEndpoint,
            ),
            performerIds: s.performers.map((p) => p.id).toList(),
            performerNames: s.performers.map((p) => p.name).toList(),
            performerImagePaths: s.performers
                .map(
                  (p) => resolveGraphqlMediaUrl(
                    rawUrl: p.image_path,
                    graphqlEndpoint: _graphqlEndpoint,
                  ),
                )
                .toList(),
            tagIds: [],
            tagNames: [],
          ),
        )
        .toList();
  }

  Future<QueryResult<Query$FindScenes>> _runFindScenes({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    required bool descending,
    bool? organized,
    bool? performerFavorite,
    String? performerId,
    String? studioId,
    String? tagId,
    SceneFilter? sceneFilter,
  }) {
    return client.query$FindScenes(
      Options$Query$FindScenes(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        variables: Variables$Query$FindScenes(
          filter: Input$FindFilterType(
            q: filter ?? sceneFilter?.searchQuery,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          scene_filter: Input$SceneFilterType(
            organized: organized,
            performer_favorite: performerFavorite,
            performers:
                (performerId != null ||
                    (sceneFilter?.performerIds?.isNotEmpty ?? false))
                ? Input$MultiCriterionInput(
                    value: performerId != null
                        ? [performerId]
                        : sceneFilter!.performerIds,
                    modifier: Enum$CriterionModifier.INCLUDES,
                  )
                : null,
            studios: (studioId != null || sceneFilter?.studioId != null)
                ? Input$HierarchicalMultiCriterionInput(
                    value: studioId != null
                        ? [studioId]
                        : [sceneFilter!.studioId!],
                    modifier: Enum$CriterionModifier.INCLUDES,
                  )
                : null,
            tags:
                (tagId != null ||
                    (sceneFilter?.includeTags?.isNotEmpty ?? false))
                ? Input$HierarchicalMultiCriterionInput(
                    value: tagId != null ? [tagId] : sceneFilter!.includeTags,
                    modifier: Enum$CriterionModifier.INCLUDES,
                  )
                : null,
            rating100: sceneFilter?.minRating != null
                ? Input$IntCriterionInput(
                    value: sceneFilter!.minRating!,
                    modifier: Enum$CriterionModifier.GREATER_THAN,
                  )
                : null,
            play_count: sceneFilter?.isWatched == true
                ? Input$IntCriterionInput(
                    value: 0,
                    modifier: Enum$CriterionModifier.GREATER_THAN,
                  )
                : sceneFilter?.isWatched == false
                ? Input$IntCriterionInput(
                    value: 0,
                    modifier: Enum$CriterionModifier.EQUALS,
                  )
                : null,
            date:
                (sceneFilter?.startDate != null || sceneFilter?.endDate != null)
                ? Input$DateCriterionInput(
                    value:
                        sceneFilter?.startDate?.toIso8601String().split(
                          'T',
                        )[0] ??
                        '',
                    value2: sceneFilter?.endDate?.toIso8601String().split(
                      'T',
                    )[0],
                    modifier: sceneFilter?.endDate != null
                        ? Enum$CriterionModifier.BETWEEN
                        : Enum$CriterionModifier.GREATER_THAN,
                  )
                : null,
            resolution: (sceneFilter?.resolutions?.isNotEmpty ?? false)
                ? Input$ResolutionCriterionInput(
                    value: fromJson$Enum$ResolutionEnum(
                      sceneFilter!.resolutions!.first,
                    ),
                    modifier: Enum$CriterionModifier.EQUALS,
                  )
                : null,
            orientation: (sceneFilter?.orientations?.isNotEmpty ?? false)
                ? Input$OrientationCriterionInput(
                    value: sceneFilter!.orientations!
                        .map((o) => fromJson$Enum$OrientationEnum(o))
                        .toList(),
                  )
                : null,
            duration:
                (sceneFilter?.minDuration != null ||
                    sceneFilter?.maxDuration != null)
                ? Input$IntCriterionInput(
                    value: sceneFilter?.minDuration ?? 0,
                    value2: sceneFilter?.maxDuration,
                    modifier: sceneFilter?.maxDuration != null
                        ? Enum$CriterionModifier.BETWEEN
                        : Enum$CriterionModifier.GREATER_THAN,
                  )
                : null,
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

  @override
  Future<Scene> getSceneById(String id, {bool refresh = false}) async {
    final result = await client.query$FindScene(
      Options$Query$FindScene(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindScene(id: id),
      ),
    );

    if (result.hasException) throw result.exception!;
    final s = result.parsedData!.findScene;
    if (s == null) throw StateError('Scene not found');

    return Scene(
      id: s.id,
      title: s.title ?? '',
      details: s.details,
      path: s.files.isNotEmpty ? s.files.first.path : null,
      date: DateTime.tryParse(s.date ?? '') ?? DateTime.now(),
      rating100: s.rating100,
      oCounter: s.o_counter ?? 0,
      organized: s.organized,
      interactive: s.interactive,
      resumeTime: s.resume_time,
      playCount: s.play_count ?? 0,
      files: s.files
          .map(
            (f) => SceneFile(
              format: f.format,
              width: f.width,
              height: f.height,
              videoCodec: f.video_codec,
              audioCodec: f.audio_codec,
              bitRate: f.bit_rate,
              duration: f.duration,
              frameRate: f.frame_rate,
            ),
          )
          .toList(),
      paths: ScenePaths(
        screenshot: resolveGraphqlMediaUrl(
          rawUrl: s.paths.screenshot,
          graphqlEndpoint: _graphqlEndpoint,
        ),
        preview: resolveGraphqlMediaUrl(
          rawUrl: s.paths.preview,
          graphqlEndpoint: _graphqlEndpoint,
        ),
        stream: resolveGraphqlMediaUrl(
          rawUrl: s.paths.stream,
          graphqlEndpoint: _graphqlEndpoint,
        ),
      ),
      urls: s.urls,
      studioId: s.studio?.id,
      studioName: s.studio?.name,
      studioImagePath: resolveGraphqlMediaUrl(
        rawUrl: s.studio?.image_path,
        graphqlEndpoint: _graphqlEndpoint,
      ),
      performerIds: s.performers.map((p) => p.id).toList(),
      performerNames: s.performers.map((p) => p.name).toList(),
      performerImagePaths: s.performers
          .map(
            (p) => resolveGraphqlMediaUrl(
              rawUrl: p.image_path,
              graphqlEndpoint: _graphqlEndpoint,
            ),
          )
          .toList(),
      tagIds: s.tags.map((t) => t.id).toList(),
      tagNames: s.tags.map((t) => t.name).toList(),
    );
  }

  @override
  Future<void> updateSceneRating(String id, int rating100) async {
    final result = await client.mutate$UpdateSceneRating(
      Options$Mutation$UpdateSceneRating(
        variables: Variables$Mutation$UpdateSceneRating(
          id: id,
          rating: rating100,
        ),
      ),
    );

    if (result.hasException) throw result.exception!;
  }

  @override
  Future<void> incrementSceneOCounter(String id) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation SceneAddO($id: ID!) {
            sceneAddO(id: $id) {
              count
            }
          }
        '''),
        variables: <String, dynamic>{'id': id},
      ),
    );

    if (result.hasException) throw result.exception!;
  }

  @override
  Future<void> incrementScenePlayCount(String id) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation SceneAddPlay($id: ID!) {
            sceneAddPlay(id: $id) {
              count
            }
          }
        '''),
        variables: <String, dynamic>{'id': id},
      ),
    );

    if (result.hasException) throw result.exception!;
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findPerformerCandidates(
    List<String> queries,
  ) async {
    final results = <String, List<Map<String, dynamic>>>{};
    for (final q in queries) {
      if (q.trim().isEmpty) continue;
      final result = await client.query$FindPerformers(
        Options$Query$FindPerformers(
          variables: Variables$Query$FindPerformers(
            filter: Input$FindFilterType(q: q),
          ),
        ),
      );
      if (result.hasException) continue;
      results[q] =
          (result.data?['findPerformers']?['performers'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    }
    return results;
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findTagCandidates(
    List<String> tags,
  ) async {
    final results = <String, List<Map<String, dynamic>>>{};
    for (final t in tags) {
      if (t.trim().isEmpty) continue;
      final result = await client.query$FindTags(
        Options$Query$FindTags(
          variables: Variables$Query$FindTags(
            filter: Input$FindFilterType(q: t),
          ),
        ),
      );
      if (result.hasException) continue;
      results[t] =
          (result.data?['findTags']?['tags'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    }
    return results;
  }

  @override
  Future<List<Scraper>> listScrapers({required List<String> types}) async {
    final doc = gql(r'''
      query ListScrapers($types: [ScrapeContentType!]!) {
        listScrapers(types: $types) {
          id
          name
        }
      }
    ''');

    final result = await client.query(
      QueryOptions(document: doc, variables: {'types': types}),
    );

    if (result.hasException) throw result.exception!;

    final raw = result.data?['listScrapers'] as List<dynamic>?;
    if (raw == null) return [];

    return raw
        .map((e) => Scraper.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<List<ScrapedScene>> scrapeSingleScene({
    required String scraperId,
    required String sceneId,
  }) async {
    final doc = gql(r'''
      query ScrapeSingleScene($source: ScraperSourceInput!, $input: ScrapeSingleSceneInput!) {
        scrapeSingleScene(source: $source, input: $input) {
          title
          code
          details
          director
          urls
          date
          image
          remote_site_id
          studio {
            name
            stored_id
          }
          tags {
            name
            stored_id
          }
          performers {
            name
            remote_site_id
            urls
            images
            stored_id
          }
        }
      }
    ''');

    final variables = {
      'source': {'scraper_id': scraperId},
      'input': {'scene_id': sceneId},
    };

    final result = await client.query(
      QueryOptions(document: doc, variables: variables),
    );

    if (result.hasException) throw result.exception!;

    final raw = result.data?['scrapeSingleScene'] as List<dynamic>?;
    if (raw == null) return [];

    return raw
        .map((e) => ScrapedScene.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> saveScrapedScene({
    required String sceneId,
    required ScrapedScene scraped,
    bool mergeValues = false,
    List<String>? performerIds,
    List<String>? tagIds,
    String? studioId,
  }) async {
    // If caller supplied explicit performer/tag/studio ids (user-selected), use them.
    // Otherwise reconcile automatically.
    final resolvedPerformerIds =
        performerIds ?? await _reconcilePerformers(scraped.performers);
    final resolvedTagIds = tagIds ?? await _reconcileTags(scraped.tags);
    final resolvedStudioId = studioId ?? scraped.studioId;

    var normalized = buildSceneUpdateInputFromScraped(scraped);

    // Inject resolved ids
    if (resolvedPerformerIds.isNotEmpty) {
      normalized['performer_ids'] = resolvedPerformerIds;
    }
    if (resolvedTagIds.isNotEmpty) normalized['tag_ids'] = resolvedTagIds;
    if (resolvedStudioId != null) normalized['studio_id'] = resolvedStudioId;

    validateSceneUpdateInput(normalized);

    // Ensure the id is present in the mutation input
    final input = {'id': sceneId, ...normalized};

    if (mergeValues) {
      final doc = gql(r'''
        mutation SceneMerge($source: [ID!]!, $destination: ID!, $values: SceneUpdateInput) {
          sceneMerge(input: {source: $source, destination: $destination, values: $values}) { id }
        }
      ''');

      final result = await client.mutate(
        MutationOptions(
          document: doc,
          variables: {
            'source': [sceneId],
            'destination': sceneId,
            'values': normalized,
          },
        ),
      );

      if (result.hasException) throw result.exception!;
    } else {
      final doc = gql(r'''
        mutation SceneUpdate($input: SceneUpdateInput!) {
          sceneUpdate(input: $input) { id }
        }
      ''');

      final result = await client.mutate(
        MutationOptions(document: doc, variables: {'input': input}),
      );
      if (result.hasException) throw result.exception!;
    }
  }

  Future<List<String>> _reconcilePerformers(
    List<ScrapedPerformer> performers,
  ) async {
    final ids = <String>[];
    if (performers.isEmpty) return ids;

    final findDoc = gql(r'''
      query FindPerformers($filter: FindFilterType, $performer_filter: PerformerFilterType) {
        findPerformers(filter: $filter, performer_filter: $performer_filter) {
          count
          performers { id name urls image_path }
        }
      }
    ''');

    final createDoc = gql(r'''
      mutation CreatePerformer($input: PerformerCreateInput!) { performerCreate(input: $input) { id } }
    ''');

    for (final p in performers) {
      if (p.storedId != null && p.storedId!.isNotEmpty) {
        ids.add(p.storedId!);
        continue;
      }

      // Try to find by name first
      final nameQuery = p.name ?? (p.urls.isNotEmpty ? p.urls.first : '');
      if (nameQuery.isEmpty) continue;

      final result = await client.query(
        QueryOptions(
          document: findDoc,
          variables: {
            'filter': {'q': nameQuery},
          },
        ),
      );
      if (result.hasException) throw result.exception!;

      final raw = result.data?['findPerformers'] as Map<String, dynamic>?;
      final found =
          (raw?['performers'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      String? chosenId;
      for (final f in found) {
        final name = f['name'] as String?;
        final urls = (f['urls'] as List<dynamic>?)?.cast<String>() ?? [];
        if (name != null &&
            p.name != null &&
            name.toLowerCase() == p.name!.toLowerCase()) {
          chosenId = f['id'] as String?;
          break;
        }
        for (final pUrl in p.urls) {
          if (urls.contains(pUrl)) {
            chosenId = f['id'] as String?;
            break;
          }
        }
        if (chosenId != null) break;
      }

      if (chosenId != null) {
        ids.add(chosenId);
        continue;
      }

      // Create performer when no candidate found
      final input = <String, dynamic>{'name': p.name ?? nameQuery};
      if (p.urls.isNotEmpty) input['urls'] = p.urls;
      if (p.images.isNotEmpty) input['image'] = p.images.first;

      final createResult = await client.mutate(
        MutationOptions(document: createDoc, variables: {'input': input}),
      );
      if (createResult.hasException) throw createResult.exception!;
      final created =
          (createResult.data?['performerCreate'] as Map<String, dynamic>?);
      if (created != null && created['id'] != null) {
        ids.add(created['id'] as String);
      }
    }

    return ids;
  }

  Future<List<String>> _reconcileTags(List<ScrapedTag> tags) async {
    final ids = <String>[];
    if (tags.isEmpty) return ids;

    final findDoc = gql(r'''
      query FindTags($filter: FindFilterType, $tag_filter: TagFilterType) {
        findTags(filter: $filter, tag_filter: $tag_filter) { count tags { id name } }
      }
    ''');

    final createDoc = gql(r'''
      mutation CreateTag($input: TagCreateInput!) { tagCreate(input: $input) { id } }
    ''');

    for (final t in tags) {
      if (t.storedId != null && t.storedId!.isNotEmpty) {
        ids.add(t.storedId!);
        continue;
      }

      final q = t.name.trim();
      if (q.isEmpty) continue;

      final result = await client.query(
        QueryOptions(
          document: findDoc,
          variables: {
            'filter': {'q': q},
          },
        ),
      );
      if (result.hasException) throw result.exception!;

      final raw = result.data?['findTags'] as Map<String, dynamic>?;
      final found =
          (raw?['tags'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

      String? chosenId;
      for (final f in found) {
        final name = f['name'] as String?;
        if (name != null && name.toLowerCase() == q.toLowerCase()) {
          chosenId = f['id'] as String?;
          break;
        }
      }

      if (chosenId != null) {
        ids.add(chosenId);
        continue;
      }

      final createResult = await client.mutate(
        MutationOptions(
          document: createDoc,
          variables: {
            'input': {'name': q},
          },
        ),
      );
      if (createResult.hasException) throw createResult.exception!;
      final created =
          (createResult.data?['tagCreate'] as Map<String, dynamic>?);
      if (created != null && created['id'] != null) {
        ids.add(created['id'] as String);
      }
    }

    return ids;
  }
}
