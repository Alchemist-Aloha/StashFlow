import 'package:graphql/client.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../graphql/performers.graphql.dart';
import '../../domain/entities/performer.dart';
import '../../domain/repositories/performer_repository.dart';

class GraphQLPerformerRepository implements PerformerRepository {
  final GraphQLClient client;
  GraphQLPerformerRepository(this.client);

  Uri get _graphqlEndpoint => client.link is HttpLink
      ? (client.link as HttpLink).uri
      : Uri.parse('https://localhost/graphql');

  @override
  Future<List<Performer>> findPerformers({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
  }) async {
    final result = await client.query$FindPerformers(
      Options$Query$FindPerformers(
        variables: Variables$Query$FindPerformers(
          filter: Input$FindFilterType(
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          performer_filter: filter != null
              ? Input$PerformerFilterType(
                  name: Input$StringCriterionInput(
                    value: filter,
                    modifier: Enum$CriterionModifier.EQUALS,
                  ),
                )
              : null,
        ),
      ),
    );

    if (result.hasException) throw result.exception!;

    return result.parsedData!.findPerformers.performers
        .map(
          (p) => Performer(
            id: p.id,
            name: p.name,
            disambiguation: p.disambiguation,
            urls: p.urls ?? [],
            gender: p.gender?.name,
            birthdate: p.birthdate,
            ethnicity: p.ethnicity,
            country: p.country,
            eyeColor: p.eye_color,
            heightCm: p.height_cm,
            measurements: p.measurements,
            fakeTits: p.fake_tits,
            penisLength: p.penis_length,
            circumcised: p.circumcised?.name,
            careerStart: null,
            careerEnd: null,
            tattoos: p.tattoos,
            piercings: p.piercings,
            aliasList: p.alias_list,
            favorite: p.favorite,
            imagePath: resolveGraphqlMediaUrl(
              rawUrl: p.image_path,
              graphqlEndpoint: _graphqlEndpoint,
            ),
            sceneCount: p.scene_count,
            imageCount: p.image_count,
            galleryCount: p.gallery_count,
            groupCount: p.group_count,
            rating100: p.rating100,
            details: p.details,
            deathDate: p.death_date,
            hairColor: p.hair_color,
            weight: p.weight,
            tagIds: p.tags.map((t) => t.id).toList(),
            tagNames: p.tags.map((t) => t.name).toList(),
          ),
        )
        .toList();
  }

  @override
  Future<Performer> getPerformerById(String id) async {
    final result = await client.query$FindPerformer(
      Options$Query$FindPerformer(
        variables: Variables$Query$FindPerformer(id: id),
      ),
    );

    if (result.hasException) throw result.exception!;
    final p = result.parsedData!.findPerformer;
    if (p == null) throw StateError('Performer not found');

    return Performer(
      id: p.id,
      name: p.name,
      disambiguation: p.disambiguation,
      urls: p.urls ?? [],
      gender: p.gender?.name,
      birthdate: p.birthdate,
      ethnicity: p.ethnicity,
      country: p.country,
      eyeColor: p.eye_color,
      heightCm: p.height_cm,
      measurements: p.measurements,
      fakeTits: p.fake_tits,
      penisLength: p.penis_length,
      circumcised: p.circumcised?.name,
      careerStart: null,
      careerEnd: null,
      tattoos: p.tattoos,
      piercings: p.piercings,
      aliasList: p.alias_list,
      favorite: p.favorite,
      imagePath: resolveGraphqlMediaUrl(
        rawUrl: p.image_path,
        graphqlEndpoint: _graphqlEndpoint,
      ),
      sceneCount: p.scene_count,
      imageCount: p.image_count,
      galleryCount: p.gallery_count,
      groupCount: p.group_count,
      rating100: p.rating100,
      details: p.details,
      deathDate: p.death_date,
      hairColor: p.hair_color,
      weight: p.weight,
      tagIds: p.tags.map((t) => t.id).toList(),
      tagNames: p.tags.map((t) => t.name).toList(),
    );
  }
}
