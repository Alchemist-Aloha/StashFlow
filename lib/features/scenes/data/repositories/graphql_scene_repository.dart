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
                    fingerprints: f.fingerprints
                        .map((fp) => Fingerprint(
                              type: fp.type,
                              value: fp.value,
                            ))
                        .toList(),
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
              caption: resolveGraphqlMediaUrl(
                rawUrl: s.paths.caption,
                graphqlEndpoint: _graphqlEndpoint,
              ),
              vtt: resolveGraphqlMediaUrl(
                rawUrl: s.paths.vtt,
                graphqlEndpoint: _graphqlEndpoint,
              ),
            ),
            captions:
                s.captions
                    ?.map(
                      (c) => VideoCaption(
                        languageCode: c.language_code,
                        captionType: c.caption_type,
                      ),
                    )
                    .toList() ??
                [],
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
              fingerprints: f.fingerprints
                  .map((fp) => Fingerprint(
                        type: fp.type,
                        value: fp.value,
                      ))
                  .toList(),
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
        caption: resolveGraphqlMediaUrl(
          rawUrl: s.paths.caption,
          graphqlEndpoint: _graphqlEndpoint,
        ),
        vtt: resolveGraphqlMediaUrl(
          rawUrl: s.paths.vtt,
          graphqlEndpoint: _graphqlEndpoint,
        ),
      ),
      captions:
          s.captions
              ?.map(
                (c) => VideoCaption(
                  languageCode: c.language_code,
                  captionType: c.caption_type,
                ),
              )
              .toList() ??
          [],
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
    final result = await client.mutate$SceneAddO(
      Options$Mutation$SceneAddO(
        variables: Variables$Mutation$SceneAddO(id: id),
      ),
    );

    if (result.hasException) throw result.exception!;
  }

  @override
  Future<void> incrementScenePlayCount(String id) async {
    final result = await client.mutate$SceneAddPlay(
      Options$Mutation$SceneAddPlay(
        variables: Variables$Mutation$SceneAddPlay(id: id),
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
    final result = await client.query$ListScrapers(
      Options$Query$ListScrapers(
        variables: Variables$Query$ListScrapers(
          types: types.map((t) => fromJson$Enum$ScrapeContentType(t)).toList(),
        ),
      ),
    );

    if (result.hasException) throw result.exception!;

    final List<Query$ListScrapers$listScrapers> raw =
        result.parsedData?.listScrapers ?? [];

    return raw.map((e) => Scraper.fromJson(e.toJson())).toList();
  }

  @override
  Future<List<ScrapedScene>> scrapeSingleScene({
    String? scraperId,
    String? stashBoxEndpoint,
    String? sceneId,
    String? query,
  }) async {
    final result = await client.query$ScrapeSingleScene(
      Options$Query$ScrapeSingleScene(
        variables: Variables$Query$ScrapeSingleScene(
          source: Input$ScraperSourceInput(
            scraper_id: scraperId,
            stash_box_endpoint: stashBoxEndpoint,
          ),
          input: Input$ScrapeSingleSceneInput(
            scene_id: sceneId,
            query: query,
          ),
        ),
      ),
    );

    if (result.hasException) throw result.exception!;

    final List<Query$ScrapeSingleScene$scrapeSingleScene> raw =
        result.parsedData?.scrapeSingleScene ?? [];

    return raw.map((e) => ScrapedScene.fromJson(e.toJson())).toList();
  }

  @override
  Future<void> generatePhash(String sceneId) async {
    final result = await client.mutate$MetadataGenerate(
      Options$Mutation$MetadataGenerate(
        variables: Variables$Mutation$MetadataGenerate(
          input: Input$GenerateMetadataInput(
            phashes: true,
            sceneIDs: [sceneId],
          ),
        ),
      ),
    );

    if (result.hasException) throw result.exception!;
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
    final resolvedPerformerIds =
        performerIds ?? await _reconcilePerformers(scraped.performers);
    final resolvedTagIds = tagIds ?? await _reconcileTags(scraped.tags);
    final resolvedStudioId = studioId ?? scraped.studioId;

    var normalized = buildSceneUpdateInputFromScraped(scraped);

    if (resolvedPerformerIds.isNotEmpty) {
      normalized['performer_ids'] = resolvedPerformerIds;
    }
    if (resolvedTagIds.isNotEmpty) normalized['tag_ids'] = resolvedTagIds;
    if (resolvedStudioId != null) normalized['studio_id'] = resolvedStudioId;

    validateSceneUpdateInput(normalized);

    if (mergeValues) {
      final result = await client.mutate$SceneMerge(
        Options$Mutation$SceneMerge(
          variables: Variables$Mutation$SceneMerge(
            input: Input$SceneMergeInput(
              source: [sceneId],
              destination: sceneId,
              values: Input$SceneUpdateInput.fromJson(normalized),
            ),
          ),
        ),
      );

      if (result.hasException) throw result.exception!;
    } else {
      final inputMap = {'id': sceneId, ...normalized};
      final result = await client.mutate$SceneUpdate(
        Options$Mutation$SceneUpdate(
          variables: Variables$Mutation$SceneUpdate(
            input: Input$SceneUpdateInput.fromJson(inputMap),
          ),
        ),
      );
      if (result.hasException) throw result.exception!;
    }
  }

  Future<List<String>> _reconcilePerformers(
    List<ScrapedPerformer> performers,
  ) async {
    final ids = <String>[];
    if (performers.isEmpty) return ids;

    for (final p in performers) {
      if (p.storedId != null && p.storedId!.isNotEmpty) {
        ids.add(p.storedId!);
        continue;
      }

      final nameQuery = p.name ?? (p.urls.isNotEmpty ? p.urls.first : '');
      if (nameQuery.isEmpty) continue;

      final result = await client.query$FindPerformers(
        Options$Query$FindPerformers(
          variables: Variables$Query$FindPerformers(
            filter: Input$FindFilterType(q: nameQuery),
          ),
        ),
      );
      if (result.hasException) throw result.exception!;

      final found = result.parsedData?.findPerformers.performers ?? [];

      String? chosenId;
      final pNameLower = p.name?.toLowerCase();
      final pUrlsSet = p.urls.toSet();

      for (final f in found) {
        if (pNameLower != null && f.name.toLowerCase() == pNameLower) {
          chosenId = f.id;
          break;
        }

        final fUrls = f.urls;
        if (fUrls != null && fUrls.any((u) => pUrlsSet.contains(u))) {
          chosenId = f.id;
          break;
        }
      }

      if (chosenId != null) {
        ids.add(chosenId);
        continue;
      }

      final createResult = await client.mutate$CreatePerformer(
        Options$Mutation$CreatePerformer(
          variables: Variables$Mutation$CreatePerformer(
            input: Input$PerformerCreateInput(
              name: p.name ?? nameQuery,
              urls: p.urls.isNotEmpty ? p.urls : null,
              image: p.images.isNotEmpty ? p.images.first : null,
            ),
          ),
        ),
      );
      if (createResult.hasException) throw createResult.exception!;
      final createdId = createResult.parsedData?.performerCreate?.id;
      if (createdId != null) {
        ids.add(createdId);
      }
    }

    return ids;
  }

  Future<List<String>> _reconcileTags(List<ScrapedTag> tags) async {
    final ids = <String>[];
    if (tags.isEmpty) return ids;

    for (final t in tags) {
      if (t.storedId != null && t.storedId!.isNotEmpty) {
        ids.add(t.storedId!);
        continue;
      }

      final q = t.name.trim();
      if (q.isEmpty) continue;

      final result = await client.query$FindTags(
        Options$Query$FindTags(
          variables: Variables$Query$FindTags(
            filter: Input$FindFilterType(q: q),
          ),
        ),
      );
      if (result.hasException) throw result.exception!;

      final found = result.parsedData?.findTags.tags ?? [];

      String? chosenId;
      for (final f in found) {
        final name = f.name;
        if (name.toLowerCase() == q.toLowerCase()) {
          chosenId = f.id;
          break;
        }
      }

      if (chosenId != null) {
        ids.add(chosenId);
        continue;
      }

      final createResult = await client.mutate$CreateTag(
        Options$Mutation$CreateTag(
          variables: Variables$Mutation$CreateTag(
            input: Input$TagCreateInput(name: q),
          ),
        ),
      );
      if (createResult.hasException) throw createResult.exception!;
      final createdId = createResult.parsedData?.tagCreate?.id;
      if (createdId != null) {
        ids.add(createdId);
      }
    }

    return ids;
  }
}
