import 'package:graphql/client.dart';
import '../../domain/entities/performer.dart';
import '../../domain/repositories/performer_repository.dart';

class GraphQLPerformerRepository implements PerformerRepository {
  final GraphQLClient client;
  GraphQLPerformerRepository(this.client);

  @override
  Future<List<Performer>> findPerformers({
    int? page,
    int? perPage,
    String? filter,
  }) async {
    const String findPerformersQuery = r'''
      query FindPerformers($page: Int, $perPage: Int) {
        findPerformers(filter: { page: $page, per_page: $perPage }) {
          count
          performers {
            id
            name
            details
            image_path
          }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(findPerformersQuery),
        variables: {'page': page, 'perPage': perPage},
      ),
    );

    if (result.hasException) throw result.exception!;

    final List performersJson =
        result.data?['findPerformers']?['performers'] ?? [];

    return performersJson
        .map(
          (p) => Performer(
            id: p['id'],
            name: p['name'] ?? '',
            details: p['details'],
            gender: null,
            birthdate: null,
            imagePath: p['image_path'],
            tags: [],
          ),
        )
        .toList();
  }

  @override
  Future<Performer> getPerformerById(String id) async {
    const String findPerformerQuery = r'''
      query FindPerformer($id: ID!) {
        findPerformer(id: $id) {
          id
          name
          details
          gender
          birthdate
          image_path
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(document: gql(findPerformerQuery), variables: {'id': id}),
    );

    if (result.hasException) throw result.exception!;

    final performerJson = result.data?['findPerformer'];
    if (performerJson == null) {
      throw StateError('Performer not found for id: $id');
    }

    return Performer(
      id: performerJson['id'],
      name: performerJson['name'] ?? '',
      details: performerJson['details'],
      gender: performerJson['gender'],
      birthdate: performerJson['birthdate']?.toString(),
      imagePath: performerJson['image_path'],
      tags: [],
    );
  }
}
