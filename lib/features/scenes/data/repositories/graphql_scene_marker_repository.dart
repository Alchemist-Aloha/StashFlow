import 'package:graphql/client.dart';

import '../../../../core/data/graphql/graphql_exception.dart';
import '../../../../core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../domain/entities/scene_marker.dart';

class GraphQLSceneMarkerRepository {
  GraphQLSceneMarkerRepository(this._client);

  final GraphQLClient _client;

  Uri get _graphqlEndpoint => _client.link is HttpLink
      ? (_client.link as HttpLink).uri
      : Uri.parse('https://localhost/graphql');
  Future<List<SceneMarkerSummary>> findSceneMarkers({
    int? page,
    int? perPage,
    String? searchQuery,
    String? sort,
    bool descending = true,
    SceneMarkerFilter filter = const SceneMarkerFilter(),
  }) async {
    final result = await _client.query<Map<String, dynamic>>(
      QueryOptions<Map<String, dynamic>>(
        document: gql(r'''
          query FindSceneMarkers(
            $filter: FindFilterType
            $scene_marker_filter: SceneMarkerFilterType
          ) {
            findSceneMarkers(
              filter: $filter
              scene_marker_filter: $scene_marker_filter
            ) {
              count
              scene_markers {
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
                scene {
                  id
                  title
                  files {
                    path
                  }
                  performers {
                    id
                    name
                  }
                }
              }
            }
          }
        '''),
        variables: {
          'filter': Input$FindFilterType(
            q: searchQuery?.isEmpty == true ? null : searchQuery,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ).toJson(),
          'scene_marker_filter': _markerFilterInput(filter)?.toJson(),
        },
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.cacheAndNetwork,
      ),
    );
    validateGraphQLResult(result);

    final rawMarkers =
        (result.data?['findSceneMarkers']
            as Map<String, dynamic>?)?['scene_markers'];
    if (rawMarkers is! List) return const [];

    return rawMarkers
        .whereType<Map<String, dynamic>>()
        .map(_mapMarker)
        .toList(growable: false);
  }

  Input$SceneMarkerFilterType? _markerFilterInput(SceneMarkerFilter filter) {
    if (filter.isEmpty) return null;

    return Input$SceneMarkerFilterType(
      tags: mapHierarchicalMultiCriterion(filter.tags),
      scene_tags: mapHierarchicalMultiCriterion(filter.sceneTags),
      performers: mapMultiCriterion(filter.performers),
      scenes: mapMultiCriterion(filter.scenes),
      duration: mapFloatCriterion(filter.duration),
      created_at: mapTimestampCriterion(filter.createdAt),
      updated_at: mapTimestampCriterion(filter.updatedAt),
      scene_date: mapDateCriterion(filter.sceneDate),
      scene_created_at: mapTimestampCriterion(filter.sceneCreatedAt),
      scene_updated_at: mapTimestampCriterion(filter.sceneUpdatedAt),
    );
  }

  SceneMarkerSummary _mapMarker(Map<String, dynamic> marker) {
    final scene = marker['scene'] as Map<String, dynamic>?;
    final primaryTag = marker['primary_tag'] as Map<String, dynamic>?;
    final rawTags = marker['tags'];
    final tags = rawTags is List
        ? rawTags.whereType<Map<String, dynamic>>().toList(growable: false)
        : const <Map<String, dynamic>>[];
    final rawPerformers = scene?['performers'];
    final performers = rawPerformers is List
        ? rawPerformers.whereType<Map<String, dynamic>>().toList(
            growable: false,
          )
        : const <Map<String, dynamic>>[];

    return SceneMarkerSummary(
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
      primaryTagName: primaryTag?['name'] as String?,
      tagNames: tags
          .map((tag) => tag['name'] as String?)
          .whereType<String>()
          .toList(growable: false),
      sceneId: scene?['id'] as String? ?? '',
      sceneTitle: scene?['title'] as String? ?? '',
      performerNames: performers
          .map((performer) => performer['name'] as String?)
          .whereType<String>()
          .toList(growable: false),
    );
  }
}
