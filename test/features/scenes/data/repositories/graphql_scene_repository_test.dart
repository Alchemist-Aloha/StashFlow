import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_repository.dart';

void main() {
  group('GraphQLSceneRepository', () {
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
