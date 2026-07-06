import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';
import '../../../../core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart'
    as domain;
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_deduplication.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/models/scraper.dart';
import '../graphql/scenes.graphql.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';
import '../utils/scrape_normalizer.dart';

class GraphQLSceneRepository {
  final GraphQLClient _client;
  GraphQLSceneRepository(this._client);

  Uri get _graphqlEndpoint => _client.link is HttpLink
      ? (_client.link as HttpLink).uri
      : Uri.parse('https://localhost/graphql');
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

    validateGraphQLResult(result);

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
            playDuration: s.play_duration,
            files: s.files
                .map(
                  (f) => SceneFile(
                    format: null,
                    width: f.width,
                    height: f.height,
                    videoCodec: null,
                    audioCodec: null,
                    bitRate: null,
                    duration: f.duration,
                    frameRate: null,
                    fingerprints: f.fingerprints
                        .map(
                          (fp) => Fingerprint(type: fp.type, value: fp.value),
                        )
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
              sprite: resolveGraphqlMediaUrl(
                rawUrl: s.paths.sprite,
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
            markers: const [],
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
    return _client.query$FindScenes(
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
            id: mapIntCriterion(sceneFilter?.id),
            code: mapStringCriterion(sceneFilter?.code),
            details: mapStringCriterion(sceneFilter?.details),
            director: mapStringCriterion(sceneFilter?.director),
            path: mapStringCriterion(sceneFilter?.path),
            url: mapStringCriterion(sceneFilter?.url),
            captions: mapStringCriterion(sceneFilter?.captions),
            organized: organized ?? sceneFilter?.organized,
            performer_favorite: performerFavorite,
            galleries: mapMultiCriterion(sceneFilter?.galleries),
            performer_tags: mapHierarchicalMultiCriterion(
              sceneFilter?.performerTags,
            ),
            groups: mapHierarchicalMultiCriterion(sceneFilter?.groups),
            duplicated: sceneFilter?.duplicated != null
                ? Input$DuplicationCriterionInput(
                    phash: sceneFilter!.duplicated!.value.contains('phash'),
                    // oshash: not supported in Input$DuplicationCriterionInput yet?
                  )
                : null,
            performers: (performerId != null || sceneFilter?.performers != null)
                ? mapMultiCriterion(
                    performerId != null
                        ? domain.MultiCriterion(value: [performerId])
                        : sceneFilter?.performers,
                  )
                : null,
            studios: (studioId != null || sceneFilter?.studios != null)
                ? mapHierarchicalMultiCriterion(
                    studioId != null
                        ? domain.HierarchicalMultiCriterion(value: [studioId])
                        : sceneFilter?.studios,
                  )
                : null,
            tags: (tagId != null || sceneFilter?.tags != null)
                ? mapHierarchicalMultiCriterion(
                    tagId != null
                        ? domain.HierarchicalMultiCriterion(value: [tagId])
                        : sceneFilter?.tags,
                  )
                : null,
            rating100: mapIntCriterion(sceneFilter?.rating100),
            date: mapDateCriterion(sceneFilter?.date),
            resolution: (sceneFilter?.resolutions != null)
                ? Input$ResolutionCriterionInput(
                    value: fromJson$Enum$ResolutionEnum(
                      sceneFilter!.resolutions!.value.first,
                    ),
                    modifier: mapModifier(sceneFilter.resolutions!.modifier),
                  )
                : null,
            orientation: (sceneFilter?.orientations != null)
                ? Input$OrientationCriterionInput(
                    value: sceneFilter!.orientations!.value
                        .map((o) => fromJson$Enum$OrientationEnum(o))
                        .toList(),
                  )
                : null,
            duration: mapIntCriterion(sceneFilter?.duration),
            play_duration: mapIntCriterion(sceneFilter?.playDuration),
            resume_time: mapIntCriterion(sceneFilter?.resumeTime),
            o_counter: mapIntCriterion(sceneFilter?.oCounter),
            last_played_at: mapTimestampCriterion(sceneFilter?.lastPlayedAt),
            interactive: sceneFilter?.interactive,
            interactive_speed: mapIntCriterion(sceneFilter?.interactiveSpeed),
            performer_age: mapIntCriterion(sceneFilter?.performerAge),
            performer_count: mapIntCriterion(sceneFilter?.performerCount),
            tag_count: mapIntCriterion(sceneFilter?.tagCount),
            stash_id_count: mapIntCriterion(sceneFilter?.stashIdCount),
            bitrate: mapIntCriterion(sceneFilter?.bitrate),
            framerate: mapIntCriterion(sceneFilter?.framerate),
            video_codec: mapStringCriterion(sceneFilter?.videoCodec),
            audio_codec: mapStringCriterion(sceneFilter?.audioCodec),
            oshash: mapStringCriterion(sceneFilter?.oshash),
            checksum: mapStringCriterion(sceneFilter?.checksum),
            phash: mapStringCriterion(sceneFilter?.phash),
            has_markers: sceneFilter?.hasMarkers?.toString(),
            is_missing: sceneFilter?.isMissing?.toString(),
            file_count: mapIntCriterion(sceneFilter?.fileCount),
            play_count: mapIntCriterion(sceneFilter?.playCount),
            created_at: mapTimestampCriterion(sceneFilter?.createdAt),
            updated_at: mapTimestampCriterion(sceneFilter?.updatedAt),
          ),
        ),
      ),
    );
  }

  bool _isInvalidSort(OperationException exception, String sort) {
    for (final error in exception.graphqlErrors) {
      if (error.message.contains('Invalid sort field: $sort')) {
        return true;
      }
    }
    return false;
  }

  Future<Scene> getSceneById(String id, {bool refresh = false}) async {
    final result = await _client.query$FindScene(
      Options$Query$FindScene(
        fetchPolicy: refresh
            ? FetchPolicy.networkOnly
            : FetchPolicy.cacheAndNetwork,
        variables: Variables$Query$FindScene(id: id),
      ),
    );

    validateGraphQLResult(result);
    final s = result.parsedData?.findScene;
    if (s == null) throw Exception('Scene not found');
    final rawScene = result.data?['findScene'] as Map<String, dynamic>?;

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
      playDuration: s.play_duration,
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
                  .map((fp) => Fingerprint(type: fp.type, value: fp.value))
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
        sprite: resolveGraphqlMediaUrl(
          rawUrl: s.paths.sprite,
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
      markers: _mapSceneMarkers(rawScene?['scene_markers']),
    );
  }

  Future<SceneMarker> createSceneMarker({
    required String sceneId,
    required String title,
    double seconds = 0,
    double? endSeconds,
    String? primaryTagId,
    List<String> tagIds = const [],
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Marker title cannot be empty');
    }

    final resolvedPrimaryTagId = await _resolveMarkerPrimaryTagId(
      explicitPrimaryTagId: primaryTagId,
      fallbackName: trimmedTitle,
    );
    final resolvedTagIds = {
      resolvedPrimaryTagId,
      ...tagIds.where((id) => id.trim().isNotEmpty),
    }.toList(growable: false);
    final input = <String, dynamic>{
      'scene_id': sceneId,
      'title': trimmedTitle,
      'seconds': seconds,
      'primary_tag_id': resolvedPrimaryTagId,
      'tag_ids': resolvedTagIds,
    };
    if (endSeconds != null) {
      input['end_seconds'] = endSeconds;
    }

    final result = await _client.mutate<Map<String, dynamic>>(
      MutationOptions<Map<String, dynamic>>(
        document: gql(r'''
          mutation CreateSceneMarker($input: SceneMarkerCreateInput!) {
            sceneMarkerCreate(input: $input) {
              id
              title
              seconds
              end_seconds
              screenshot
              preview
              stream
              primary_tag {
                id
                name
              }
              tags {
                id
                name
              }
            }
          }
        '''),
        variables: {'input': input},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    validateGraphQLResult(result);

    final rawMarker = result.data?['sceneMarkerCreate'];
    if (rawMarker is! Map<String, dynamic>) {
      throw StateError('Scene marker was not created');
    }
    return _mapSceneMarker(rawMarker);
  }

  Future<void> deleteSceneMarker(String markerId) async {
    final result = await _client.mutate<Map<String, dynamic>>(
      MutationOptions<Map<String, dynamic>>(
        document: gql(r'''
          mutation DeleteSceneMarker($id: ID!) {
            sceneMarkerDestroy(id: $id)
          }
        '''),
        variables: {'id': markerId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    validateGraphQLResult(result);

    if (result.data?['sceneMarkerDestroy'] != true) {
      throw StateError('Scene marker was not deleted');
    }
  }

  Future<String> _resolveMarkerPrimaryTagId({
    required String? explicitPrimaryTagId,
    required String fallbackName,
  }) async {
    final explicit = explicitPrimaryTagId?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final findResult = await _client.query<Map<String, dynamic>>(
      QueryOptions<Map<String, dynamic>>(
        document: gql(r'''
          query FindMarkerPrimaryTag($filter: FindFilterType) {
            findTags(filter: $filter) {
              tags {
                id
                name
              }
            }
          }
        '''),
        variables: {
          'filter': {'q': fallbackName, 'per_page': 20},
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    validateGraphQLResult(findResult);

    final rawTags =
        (findResult.data?['findTags'] as Map<String, dynamic>?)?['tags'];
    if (rawTags is List) {
      for (final rawTag in rawTags) {
        if (rawTag is Map<String, dynamic> &&
            (rawTag['name'] as String?)?.toLowerCase() ==
                fallbackName.toLowerCase()) {
          final id = rawTag['id'] as String?;
          if (id != null && id.isNotEmpty) return id;
        }
      }
    }

    final createResult = await _client.mutate<Map<String, dynamic>>(
      MutationOptions<Map<String, dynamic>>(
        document: gql(r'''
          mutation CreateMarkerPrimaryTag($input: TagCreateInput!) {
            tagCreate(input: $input) {
              id
            }
          }
        '''),
        variables: {
          'input': {'name': fallbackName},
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    validateGraphQLResult(createResult);

    final id =
        (createResult.data?['tagCreate'] as Map<String, dynamic>?)?['id']
            as String?;
    if (id == null || id.isEmpty) {
      throw StateError('Primary marker tag was not created');
    }
    return id;
  }

  List<SceneMarker> _mapSceneMarkers(Object? rawMarkers) {
    if (rawMarkers is! List) return const [];
    return rawMarkers
        .whereType<Map<String, dynamic>>()
        .map(_mapSceneMarker)
        .toList(growable: false);
  }

  SceneMarker _mapSceneMarker(Map<String, dynamic> marker) {
    final primaryTag = marker['primary_tag'] as Map<String, dynamic>?;
    final rawTags = marker['tags'];
    final tags = rawTags is List
        ? rawTags.whereType<Map<String, dynamic>>().toList(growable: false)
        : const <Map<String, dynamic>>[];
    final primaryTagId = primaryTag?['id'] as String?;

    return SceneMarker(
      id: marker['id'] as String,
      title: marker['title'] as String? ?? '',
      seconds: (marker['seconds'] as num?)?.toDouble() ?? 0,
      endSeconds: (marker['end_seconds'] as num?)?.toDouble(),
      screenshot: resolveGraphqlMediaUrl(
        rawUrl: marker['screenshot'] as String?,
        graphqlEndpoint: _graphqlEndpoint,
      ),
      preview: resolveGraphqlMediaUrl(
        rawUrl: marker['preview'] as String?,
        graphqlEndpoint: _graphqlEndpoint,
      ),
      stream: resolveGraphqlMediaUrl(
        rawUrl: marker['stream'] as String?,
        graphqlEndpoint: _graphqlEndpoint,
      ),
      primaryTagId: primaryTagId,
      primaryTagName: primaryTag?['name'] as String?,
      tagIds: tags
          .map((tag) => tag['id'] as String?)
          .whereType<String>()
          .toList(growable: false),
      tagNames: tags
          .map((tag) => tag['name'] as String?)
          .whereType<String>()
          .toList(growable: false),
    );
  }

  Future<List<Scraper>> listScrapers({required List<String> types}) async {
    final result = await _client.query$ListScrapers(
      Options$Query$ListScrapers(
        variables: Variables$Query$ListScrapers(
          types: types.map((t) => fromJson$Enum$ScrapeContentType(t)).toList(),
        ),
      ),
    );

    validateGraphQLResult(result);

    final List<Query$ListScrapers$listScrapers> raw =
        result.parsedData?.listScrapers ?? [];

    return raw.map((e) => Scraper.fromJson(e.toJson())).toList();
  }

  Future<List<ScrapedScene>> scrapeSingleScene({
    String? scraperId,
    String? stashBoxEndpoint,
    String? sceneId,
    String? query,
  }) async {
    final result = await _client.query$ScrapeSingleScene(
      Options$Query$ScrapeSingleScene(
        fetchPolicy: FetchPolicy.noCache,
        variables: Variables$Query$ScrapeSingleScene(
          source: Input$ScraperSourceInput(
            scraper_id: scraperId,
            stash_box_endpoint: stashBoxEndpoint,
          ),
          input: Input$ScrapeSingleSceneInput(scene_id: sceneId, query: query),
        ),
      ),
    );

    validateGraphQLResult(result);

    final List<Query$ScrapeSingleScene$scrapeSingleScene> raw =
        result.parsedData?.scrapeSingleScene ?? [];

    return raw
        .map((e) => ScrapedScene.fromJson(e.toJson()))
        .map(_stripScrapedImages)
        .toList();
  }

  Future<ScrapedScene?> scrapeSceneURL(String url) async {
    final result = await _client.query$ScrapeSceneURL(
      Options$Query$ScrapeSceneURL(
        fetchPolicy: FetchPolicy.noCache,
        variables: Variables$Query$ScrapeSceneURL(url: url),
      ),
    );

    validateGraphQLResult(result);

    final raw = result.parsedData?.scrapeSceneURL;
    if (raw == null) return null;
    return _stripScrapedImages(ScrapedScene.fromJson(raw.toJson()));
  }

  Future<void> generatePhash(String sceneId) async {
    final result = await _client.mutate$MetadataGenerate(
      Options$Mutation$MetadataGenerate(
        variables: Variables$Mutation$MetadataGenerate(
          input: Input$GenerateMetadataInput(
            phashes: true,
            sceneIDs: [sceneId],
          ),
        ),
      ),
    );

    validateGraphQLResult(result);
  }

  Future<void> saveScrapedScene({
    required String sceneId,
    required ScrapedScene scraped,
    bool mergeValues = false,
    List<String>? performerIds,
    List<String>? tagIds,
    String? studioId,
  }) async {
    final inputJson = buildSceneUpdateInputFromScraped(scraped)
      ..['id'] = sceneId
      ..['organized'] = true;
    final resolvedStudioId =
        studioId ?? scraped.studioId ?? scraped.studio?.storedId;
    if (resolvedStudioId != null) inputJson['studio_id'] = resolvedStudioId;
    if (performerIds != null) inputJson['performer_ids'] = performerIds;
    if (tagIds != null) inputJson['tag_ids'] = tagIds;
    final input = Input$SceneUpdateInput.fromJson(inputJson);

    final result = await _client.mutate$SceneUpdate(
      Options$Mutation$SceneUpdate(
        variables: Variables$Mutation$SceneUpdate(input: input),
      ),
    );

    validateGraphQLResult(result);
  }

  Future<Map<String, List<Map<String, dynamic>>>> findPerformerCandidates(
    List<String> performers,
  ) async {
    return {};
  }

  Future<Map<String, List<Map<String, dynamic>>>> findTagCandidates(
    List<String> tags,
  ) async {
    return {};
  }

  Future<void> updateSceneRating(String id, int rating100) async {
    final result = await _client.mutate$SceneUpdate(
      Options$Mutation$SceneUpdate(
        variables: Variables$Mutation$SceneUpdate(
          input: Input$SceneUpdateInput(id: id, rating100: rating100),
        ),
      ),
    );
    validateGraphQLResult(result);
  }

  Future<void> incrementSceneOCounter(String id) async {
    final result = await _client.mutate$SceneAddO(
      Options$Mutation$SceneAddO(
        variables: Variables$Mutation$SceneAddO(id: id),
      ),
    );
    validateGraphQLResult(result);
  }

  Future<void> incrementScenePlayCount(String id) async {
    final result = await _client.mutate$SceneIncrementPlayCount(
      Options$Mutation$SceneIncrementPlayCount(
        variables: Variables$Mutation$SceneIncrementPlayCount(id: id),
      ),
    );
    validateGraphQLResult(result);
  }

  Future<void> saveSceneActivity(
    String id, {
    double? resumeTime,
    double? playDuration,
  }) async {
    final result = await _client.mutate$SceneSaveActivity(
      Options$Mutation$SceneSaveActivity(
        variables: Variables$Mutation$SceneSaveActivity(
          id: id,
          resume_time: resumeTime,
          play_duration: playDuration,
        ),
      ),
    );
    validateGraphQLResult(result);
  }

  Future<void> deleteScene(
    String id, {
    required bool deleteFile,
    bool deleteGenerated = true,
  }) async {
    final result = await _client.mutate$SceneDestroy(
      Options$Mutation$SceneDestroy(
        variables: Variables$Mutation$SceneDestroy(
          id: id,
          delete_file: deleteFile,
          delete_generated: deleteGenerated,
        ),
      ),
    );
    validateGraphQLResult(result);
  }

  Future<List<SceneDuplicateGroup>> findDuplicateScenes({
    int distance = 0,
    double durationDiff = 1,
  }) async {
    final result = await _client.query$FindDuplicateScenes(
      Options$Query$FindDuplicateScenes(
        fetchPolicy: FetchPolicy.noCache,
        variables: Variables$Query$FindDuplicateScenes(
          distance: distance,
          duration_diff: durationDiff,
        ),
      ),
    );
    validateGraphQLResult(result);

    final groups = result.parsedData?.findDuplicateScenes ?? [];
    return sortDuplicateGroupsBySize(
      groups
          .map(
            (group) => SceneDuplicateGroup(
              scenes: group.map(_mapDuplicateScene).toList(growable: false),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<int> countScenesMissingPhash() async {
    final result = await _client.query$CountScenesMissingPhash(
      Options$Query$CountScenesMissingPhash(fetchPolicy: FetchPolicy.noCache),
    );
    validateGraphQLResult(result);
    return result.parsedData?.findScenes.count ?? 0;
  }

  SceneDuplicateScene _mapDuplicateScene(
    Query$FindDuplicateScenes$findDuplicateScenes scene,
  ) {
    final files = scene.files.map(_mapDuplicateFile).toList(growable: false);
    return SceneDuplicateScene(
      id: scene.id,
      title: (scene.title ?? '').trim().isNotEmpty
          ? scene.title!.trim()
          : _fileNameFromPath(files.firstOrNull?.path ?? ''),
      path: files.firstOrNull?.path,
      spritePath: resolveGraphqlMediaUrl(
        rawUrl: scene.paths.sprite,
        graphqlEndpoint: _graphqlEndpoint,
      ),
      organized: scene.organized,
      oCounter: scene.o_counter ?? 0,
      tagCount: scene.tags.length,
      performerCount: scene.performers.length,
      groupCount: scene.groups.length,
      markerCount: scene.scene_markers.length,
      galleryCount: scene.galleries.length,
      fileCount: files.length,
      files: files,
    );
  }

  SceneDuplicateFile _mapDuplicateFile(
    Query$FindDuplicateScenes$findDuplicateScenes$files file,
  ) {
    return SceneDuplicateFile(
      id: file.id,
      path: file.path,
      size: file.size,
      width: file.width,
      height: file.height,
      bitRate: file.bit_rate,
      duration: file.duration,
      videoCodec: file.video_codec,
      modTime: DateTime.tryParse(file.mod_time),
    );
  }

  /// Strip only embedded image payloads from scraped entities to avoid
  /// caching large binary payloads in the Hive GraphQL cache.
  /// The scene cover is preserved because scrape queries use noCache and the
  /// tagger needs that image for the current review result.
  ScrapedScene _stripScrapedImages(ScrapedScene scene) {
    return scene.copyWith(
      image: scene.image,
      studio: scene.studio?.copyWith(
        image: isScrapedImageEmbeddedData(scene.studio?.image)
            ? null
            : scene.studio?.image,
      ),
      performers: scene.performers
          .map(
            (p) => p.copyWith(
              image: isScrapedImageEmbeddedData(p.image) ? null : p.image,
              images: p.images
                  .where((image) => !isScrapedImageEmbeddedData(image))
                  .toList(growable: false),
            ),
          )
          .toList(),
    );
  }

  String _fileNameFromPath(String path) {
    if (path.isEmpty) return '';
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }
}
