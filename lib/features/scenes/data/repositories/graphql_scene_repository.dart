import 'dart:convert';
import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../graphql/scenes.graphql.dart';
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
  Future<Scene> getSceneById(String id) async {
    final result = await client.query$FindScene(
      Options$Query$FindScene(
        fetchPolicy: FetchPolicy.cacheFirst,
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
  Future<List<Scraper>> listScrapers({required List<String> types}) async {
    final doc = gql(r'''
      query ListScrapers($types: [ScrapeContentType!]!) {
        listScrapers(types: $types) {
          id
          name
          description
          types
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
        .map((e) => Scraper.fromJson((e as Map).map((k, v) => MapEntry(k as String, v))))
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
          id
          title
          details
          date
          url
          tags
          image_url
          performers {
            id
            name
            url
            image_url
          }
        }
      }
    ''');

    final variables = {
      'source': {'scraper_id': scraperId},
      'input': {'scene_id': sceneId},
    };

    final result = await client.query(QueryOptions(document: doc, variables: variables));

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
  }) async {
    // If caller supplied explicit performer/tag ids (user-selected), use them.
    // Otherwise reconcile automatically.
    final resolvedPerformerIds = performerIds ?? await _reconcilePerformers(scraped.performers);
    final resolvedTagIds = tagIds ?? await _reconcileTags(scraped.tags);

    var normalized = buildSceneUpdateInputFromScraped(scraped);

    // If the scraper provided an image URL, attempt to download, validate and
    // encode as a base64 data URL so the server can accept it as `cover_image`.
    try {
      final cover = normalized['cover_image'] as String?;
      if (cover != null && (cover.startsWith('http://') || cover.startsWith('https://'))) {
        final dataUrl = await _downloadAndEncodeImage(cover);
        if (dataUrl != null) normalized['cover_image'] = dataUrl;
      }
    } catch (_) {
      // If image pipeline fails, continue using the original cover value.
    }

    // Inject resolved ids
    if (resolvedPerformerIds.isNotEmpty) normalized['performer_ids'] = resolvedPerformerIds;
    if (resolvedTagIds.isNotEmpty) normalized['tag_ids'] = resolvedTagIds;

    validateSceneUpdateInput(normalized);

    // Ensure the id is present in the mutation input
    final input = {'id': sceneId, ...normalized};

    if (mergeValues) {
      final doc = gql(r'''
        mutation SceneMerge($source: [ID!]!, $destination: ID!, $values: SceneUpdateInput) {
          sceneMerge(input: {source: $source, destination: $destination, values: $values}) { id }
        }
      ''');

      final result = await client.mutate(MutationOptions(document: doc, variables: {
        'source': [sceneId],
        'destination': sceneId,
        'values': normalized,
      }));

      if (result.hasException) throw result.exception!;
    } else {
      final doc = gql(r'''
        mutation SceneUpdate($input: SceneUpdateInput!) {
          sceneUpdate(input: $input) { id }
        }
      ''');

      final result = await client.mutate(MutationOptions(document: doc, variables: {'input': input}));
      if (result.hasException) throw result.exception!;
    }
  }

  // Maximum bytes to download for cover images (5 MB)
  static const int _maxImageBytes = 5 * 1024 * 1024;

  Future<String?> _downloadAndEncodeImage(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final resp = await http.get(uri, headers: {'Accept': 'image/*'});
    if (resp.statusCode != 200) return null;

    final contentType = resp.headers['content-type'] ?? '';
    if (!contentType.startsWith('image/')) return null;

    final contentLengthHeader = resp.headers['content-length'];
    if (contentLengthHeader != null) {
      final len = int.tryParse(contentLengthHeader);
      if (len != null && len > _maxImageBytes) return null;
    }

    final bytes = resp.bodyBytes;
    if (bytes.isEmpty || bytes.length > _maxImageBytes) return null;

    final b64 = base64Encode(bytes);
    return 'data:$contentType;base64,$b64';
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findPerformerCandidates(List<String> queries) async {
    final map = <String, List<Map<String, dynamic>>>{};
    if (queries.isEmpty) return map;

    final findDoc = gql(r'''
      query FindPerformers($filter: FindFilterType) {
        findPerformers(filter: $filter) { performers { id name urls image_path } }
      }
    ''');

    for (final q in queries) {
      final trimmed = q.trim();
      if (trimmed.isEmpty) continue;
      final result = await client.query(QueryOptions(document: findDoc, variables: {'filter': {'q': trimmed}}));
      if (result.hasException) throw result.exception!;
      final raw = result.data?['findPerformers'] as Map<String, dynamic>?;
      final found = (raw?['performers'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      map[q] = found;
    }

    return map;
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findTagCandidates(List<String> tags) async {
    final map = <String, List<Map<String, dynamic>>>{};
    if (tags.isEmpty) return map;

    final findDoc = gql(r'''
      query FindTags($filter: FindFilterType) {
        findTags(filter: $filter) { tags { id name } }
      }
    ''');

    for (final t in tags) {
      final trimmed = t.trim();
      if (trimmed.isEmpty) continue;
      final result = await client.query(QueryOptions(document: findDoc, variables: {'filter': {'q': trimmed}}));
      if (result.hasException) throw result.exception!;
      final raw = result.data?['findTags'] as Map<String, dynamic>?;
      final found = (raw?['tags'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      map[t] = found;
    }

    return map;
  }

  Future<List<String>> _reconcilePerformers(List<ScrapedPerformer> performers) async {
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
      if ((p.id ?? '').isNotEmpty) {
        ids.add(p.id!);
        continue;
      }

      // Try to find by name first
      final q = p.name ?? p.url ?? '';
      if (q.isEmpty) continue;

      final result = await client.query(QueryOptions(document: findDoc, variables: {'filter': {'q': q}}));
      if (result.hasException) throw result.exception!;

      final raw = result.data?['findPerformers'] as Map<String, dynamic>?;
      final found = (raw?['performers'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

      String? chosenId;
      for (final f in found) {
        final name = f['name'] as String?;
        final urls = (f['urls'] as List<dynamic>?)?.cast<String>() ?? [];
        if (name != null && p.name != null && name.toLowerCase() == p.name!.toLowerCase()) {
          chosenId = f['id'] as String?;
          break;
        }
        if (p.url != null && urls.contains(p.url)) {
          chosenId = f['id'] as String?;
          break;
        }
      }

      if (chosenId != null) {
        ids.add(chosenId);
        continue;
      }

      // Create performer when no candidate found
      final input = <String, dynamic>{'name': p.name ?? q};
      if (p.url != null) input['urls'] = [p.url];

      final createResult = await client.mutate(MutationOptions(document: createDoc, variables: {'input': input}));
      if (createResult.hasException) throw createResult.exception!;
      final created = (createResult.data?['performerCreate'] as Map<String, dynamic>?);
      if (created != null && created['id'] != null) ids.add(created['id'] as String);
    }

    return ids;
  }

  Future<List<String>> _reconcileTags(List<String> tags) async {
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
      final q = t.trim();
      if (q.isEmpty) continue;

      final result = await client.query(QueryOptions(document: findDoc, variables: {'filter': {'q': q}}));
      if (result.hasException) throw result.exception!;

      final raw = result.data?['findTags'] as Map<String, dynamic>?;
      final found = (raw?['tags'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

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

      final createResult = await client.mutate(MutationOptions(document: createDoc, variables: {'input': {'name': q}}));
      if (createResult.hasException) throw createResult.exception!;
      final created = (createResult.data?['tagCreate'] as Map<String, dynamic>?);
      if (created != null && created['id'] != null) ids.add(created['id'] as String);
    }

    return ids;
  }
}
