import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_repository.dart';

void main() {
  group('GraphQLSceneRepository', () {
    test('findScenes maps performer birthdates', () async {
      final client = _FakeGraphQLClient(
        queryData: {
          '__typename': 'Query',
          'findScenes': {
            '__typename': 'FindScenesResultType',
            'count': 1,
            'scenes': [
              {
                '__typename': 'Scene',
                'id': 'scene-1',
                'title': 'Scene',
                'date': '2020-01-01',
                'rating100': null,
                'o_counter': 0,
                'organized': false,
                'interactive': false,
                'resume_time': null,
                'play_count': 0,
                'play_duration': null,
                'files': const [],
                'paths': {
                  '__typename': 'ScenePathsType',
                  'screenshot': null,
                  'preview': null,
                  'stream': null,
                  'caption': null,
                  'vtt': null,
                  'sprite': null,
                },
                'captions': const [],
                'urls': const [],
                'studio': null,
                'performers': [
                  {
                    '__typename': 'Performer',
                    'id': 'performer-1',
                    'name': 'Alice',
                    'image_path': null,
                    'birthdate': '2000-12-31',
                  },
                ],
                'tags': const [],
                'scene_markers': const [],
              },
            ],
          },
        },
        mutationData: const {'__typename': 'Mutation'},
      );

      final scenes = await GraphQLSceneRepository(client).findScenes();

      expect(scenes.single.performerBirthdates, ['2000-12-31']);
    });

    test(
      'createSceneMarker resolves primary tag and sends marker input',
      () async {
        final client = _FakeGraphQLClient(
          queryData: {
            '__typename': 'Query',
            'findTags': {
              '__typename': 'FindTagsResultType',
              'tags': [
                {'__typename': 'Tag', 'id': 'tag-1', 'name': 'Opening beat'},
              ],
            },
          },
          mutationData: {
            '__typename': 'Mutation',
            'sceneMarkerCreate': {
              '__typename': 'SceneMarker',
              'id': 'marker-1',
              'title': 'Opening beat',
              'seconds': 12.5,
              'end_seconds': null,
              'screenshot': '/marker.jpg',
              'preview': '/marker-preview.jpg',
              'stream': '/marker.mp4',
              'primary_tag': {
                '__typename': 'Tag',
                'id': 'tag-1',
                'name': 'Opening beat',
              },
              'tags': [
                {'__typename': 'Tag', 'id': 'tag-1', 'name': 'Opening beat'},
              ],
            },
          },
        );
        final repository = GraphQLSceneRepository(client);

        final marker = await repository.createSceneMarker(
          sceneId: 'scene-1',
          title: 'Opening beat',
          seconds: 12.5,
        );

        expect(client.lastQueryVariables?['filter']['q'], 'Opening beat');
        final input =
            client.lastMutationVariables?['input'] as Map<String, dynamic>;
        expect(input['scene_id'], 'scene-1');
        expect(input['title'], 'Opening beat');
        expect(input['seconds'], 12.5);
        expect(input['primary_tag_id'], 'tag-1');
        expect(input['tag_ids'], ['tag-1']);
        expect(marker.id, 'marker-1');
        expect(marker.title, 'Opening beat');
        expect(marker.seconds, 12.5);
        expect(marker.primaryTagId, 'tag-1');
        expect(marker.primaryTagName, 'Opening beat');
      },
    );

    test('deleteSceneMarker sends marker id to destroy mutation', () async {
      final client = _FakeGraphQLClient(
        queryData: const {'__typename': 'Query'},
        mutationData: const {
          '__typename': 'Mutation',
          'sceneMarkerDestroy': true,
        },
      );
      final repository = GraphQLSceneRepository(client);

      await repository.deleteSceneMarker('marker-1');

      expect(client.lastMutationVariables, {'id': 'marker-1'});
    });

    test(
      'saveScrapedScene normalizes scraped details before scene update',
      () async {
        final client = _FakeGraphQLClient(
          queryData: const {'__typename': 'Query'},
          mutationData: const {
            '__typename': 'Mutation',
            'sceneUpdate': {'__typename': 'Scene', 'id': 'scene-1'},
          },
        );
        final repository = GraphQLSceneRepository(client);

        await repository.saveScrapedScene(
          sceneId: 'scene-1',
          scraped: ScrapedScene(
            title: '  Scraped title  ',
            details: '  Scraped details  ',
            urls: const ['example.com/scene', '  '],
            image: 'https://images.example/cover.jpg',
            studioId: 'studio-1',
          ),
          performerIds: const ['performer-1'],
          tagIds: const ['tag-1'],
        );

        final input =
            client.lastMutationVariables?['input'] as Map<String, dynamic>;
        expect(input['id'], 'scene-1');
        expect(input['title'], 'Scraped title');
        expect(input['details'], 'Scraped details');
        expect(input['urls'], ['http://example.com/scene']);
        expect(input.containsKey('cover_image'), isFalse);
        expect(input['studio_id'], 'studio-1');
        expect(input['performer_ids'], ['performer-1']);
        expect(input['tag_ids'], ['tag-1']);
        expect(input['organized'], isTrue);
      },
    );
  });
}

class _FakeGraphQLClient extends GraphQLClient {
  _FakeGraphQLClient({required this.queryData, required this.mutationData})
    : super(
        cache: GraphQLCache(),
        link: HttpLink('http://localhost:9999/graphql'),
      );

  final Map<String, dynamic> queryData;
  final Map<String, dynamic> mutationData;
  Map<String, dynamic>? lastQueryVariables;
  Map<String, dynamic>? lastMutationVariables;

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

  @override
  Future<QueryResult<TParsed>> mutate<TParsed>(
    MutationOptions<TParsed> options,
  ) async {
    lastMutationVariables = options.variables;
    return QueryResult<TParsed>(
      source: QueryResultSource.network,
      data: mutationData,
      options: options,
    );
  }
}
