import 'package:graphql/client.dart';
import '../../../../core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart' as domain;
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../domain/models/scraper.dart';
import '../../domain/models/scraped_scene.dart';
import '../graphql/scenes.graphql.dart';

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
            performer_tags: mapHierarchicalMultiCriterion(sceneFilter?.performerTags),
            groups: mapHierarchicalMultiCriterion(sceneFilter?.groups),
            duplicated: sceneFilter?.duplicated != null
                ? Input$DuplicationCriterionInput(
                    phash: sceneFilter!.duplicated!.value.contains('phash'),
                    // oshash: not supported in Input$DuplicationCriterionInput yet?
                  )
                : null,
            performers:
                (performerId != null || sceneFilter?.performers != null)
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

  @override
  Future<Scene> getSceneById(String id, {bool refresh = false}) async {
    final result = await client.query$FindScene(
      Options$Query$FindScene(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
        variables: Variables$Query$FindScene(id: id),
      ),
    );

    if (result.hasException) throw result.exception!;
    final s = result.parsedData?.findScene;
    if (s == null) throw Exception('Scene not found');

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
  Future<ScrapedScene?> scrapeSceneURL(String url) async {
    final result = await client.query$ScrapeSceneURL(
      Options$Query$ScrapeSceneURL(
        variables: Variables$Query$ScrapeSceneURL(url: url),
      ),
    );

    if (result.hasException) throw result.exception!;

    final raw = result.parsedData?.scrapeSceneURL;
    return raw != null ? ScrapedScene.fromJson(raw.toJson()) : null;
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
    final input = Input$SceneUpdateInput(
      id: sceneId,
      title: scraped.title,
      details: scraped.details,
      date: scraped.date?.toIso8601String().split('T').first,
      urls: scraped.urls,
      studio_id: studioId ?? scraped.studioId ?? scraped.studio?.storedId,
      performer_ids: performerIds,
      tag_ids: tagIds,
    );

    final result = await client.mutate$SceneUpdate(
      Options$Mutation$SceneUpdate(
        variables: Variables$Mutation$SceneUpdate(input: input),
      ),
    );

    if (result.hasException) throw result.exception!;
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findPerformerCandidates(
    List<String> performers,
  ) async {
    return {};
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findTagCandidates(
    List<String> tags,
  ) async {
    return {};
  }

  @override
  Future<void> updateSceneRating(String id, int rating100) async {
    final result = await client.mutate$SceneUpdate(
      Options$Mutation$SceneUpdate(
        variables: Variables$Mutation$SceneUpdate(
          input: Input$SceneUpdateInput(id: id, rating100: rating100),
        ),
      ),
    );
    if (result.hasException) throw result.exception!;
  }

  @override
  Future<void> incrementSceneOCounter(String id) async {
    final scene = await getSceneById(id);
    final result = await client.mutate$SceneUpdate(
      Options$Mutation$SceneUpdate(
        variables: Variables$Mutation$SceneUpdate(
          input: Input$SceneUpdateInput(id: id, o_counter: scene.oCounter + 1),
        ),
      ),
    );
    if (result.hasException) throw result.exception!;
  }

  @override
  Future<void> incrementScenePlayCount(String id) async {
    final scene = await getSceneById(id);
    final result = await client.mutate$SceneUpdate(
      Options$Mutation$SceneUpdate(
        variables: Variables$Mutation$SceneUpdate(
          input: Input$SceneUpdateInput(id: id, play_count: scene.playCount + 1),
        ),
      ),
    );
    if (result.hasException) throw result.exception!;
  }
}
