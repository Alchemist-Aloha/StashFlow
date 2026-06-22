import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_marker_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_marker.dart';

void main() {
  test(
    'findSceneMarkers sends official marker filter and maps markers',
    () async {
      final client = _FakeGraphQLClient(
        queryData: {
          '__typename': 'Query',
          'findSceneMarkers': {
            '__typename': 'FindSceneMarkersResultType',
            'count': 1,
            'scene_markers': [
              {
                '__typename': 'SceneMarker',
                'id': 'm1',
                'title': 'Opening beat',
                'seconds': 65.0,
                'end_seconds': 95.0,
                'screenshot': '/marker.jpg',
                'preview': '/marker-preview.jpg',
                'stream': '/marker.mp4',
                'primary_tag': {
                  '__typename': 'Tag',
                  'id': 't1',
                  'name': 'Beat',
                },
                'tags': [
                  {'__typename': 'Tag', 'id': 't2', 'name': 'Extra'},
                ],
                'scene': {
                  '__typename': 'Scene',
                  'id': 's1',
                  'title': 'Test Scene',
                  'files': const [],
                  'performers': [
                    {'__typename': 'Performer', 'id': 'p1', 'name': 'Alice'},
                  ],
                },
              },
            ],
          },
        },
      );
      final repository = GraphQLSceneMarkerRepository(client);

      final markers = await repository.findSceneMarkers(
        page: 2,
        perPage: 30,
        searchQuery: 'beat',
        sort: 'seconds',
        descending: false,
        filter: SceneMarkerFilter(
          tags: const HierarchicalMultiCriterion(value: ['t1']),
          sceneTags: const HierarchicalMultiCriterion(value: ['scene-tag-1']),
          performers: const MultiCriterion(value: ['p1']),
          scenes: const MultiCriterion(value: ['s1']),
          duration: const IntCriterion(
            value: 30,
            value2: 90,
            modifier: CriterionModifier.between,
          ),
          createdAt: const DateCriterion(
            value: '2024-01-01',
            modifier: CriterionModifier.greaterThan,
          ),
          updatedAt: const DateCriterion(
            value: '2024-02-01',
            modifier: CriterionModifier.lessThan,
          ),
          sceneDate: const DateCriterion(value: '2023-01-01'),
          sceneCreatedAt: const DateCriterion(value: '2023-02-01'),
          sceneUpdatedAt: const DateCriterion(value: '2023-03-01'),
        ),
      );

      final findFilter = client.lastQueryVariables?['filter'];
      expect(findFilter['q'], 'beat');
      expect(findFilter['page'], 2);
      expect(findFilter['per_page'], 30);
      expect(findFilter['sort'], 'seconds');
      expect(findFilter['direction'], 'ASC');

      final markerFilter = client.lastQueryVariables?['scene_marker_filter'];
      expect(markerFilter['tags']['value'], ['t1']);
      expect(markerFilter['scene_tags']['value'], ['scene-tag-1']);
      expect(markerFilter['performers']['value'], ['p1']);
      expect(markerFilter['scenes']['value'], ['s1']);
      expect(markerFilter['duration']['value'], 30.0);
      expect(markerFilter['duration']['value2'], 90.0);
      expect(markerFilter['duration']['modifier'], 'BETWEEN');
      expect(markerFilter['created_at']['value'], '2024-01-01');
      expect(markerFilter['created_at']['modifier'], 'GREATER_THAN');
      expect(markerFilter['updated_at']['value'], '2024-02-01');
      expect(markerFilter['updated_at']['modifier'], 'LESS_THAN');
      expect(markerFilter['scene_date']['value'], '2023-01-01');
      expect(markerFilter['scene_created_at']['value'], '2023-02-01');
      expect(markerFilter['scene_updated_at']['value'], '2023-03-01');

      expect(markers, hasLength(1));
      expect(markers.single.id, 'm1');
      expect(markers.single.title, 'Opening beat');
      expect(markers.single.sceneId, 's1');
      expect(markers.single.sceneTitle, 'Test Scene');
      expect(markers.single.primaryTagName, 'Beat');
      expect(markers.single.tagNames, ['Extra']);
      expect(markers.single.performerNames, ['Alice']);
    },
  );
}

class _FakeGraphQLClient extends GraphQLClient {
  _FakeGraphQLClient({required this.queryData})
    : super(
        cache: GraphQLCache(),
        link: HttpLink('http://localhost:9999/graphql'),
      );

  final Map<String, dynamic> queryData;
  Map<String, dynamic>? lastQueryVariables;

  @override
  Future<QueryResult<TParsed>> query<TParsed>(
    QueryOptions<TParsed> options,
  ) async {
    lastQueryVariables = options.variables;
    return QueryResult<TParsed>(
      source: QueryResultSource.network,
      data: queryData,
      options: options,
    );
  }
}
