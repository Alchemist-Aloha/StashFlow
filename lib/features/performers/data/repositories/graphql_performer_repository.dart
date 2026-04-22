import 'package:graphql/client.dart';
import '../../../../core/data/graphql/criterion_mapping.dart';
import '../../../../core/data/graphql/schema.graphql.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../domain/entities/performer.dart';
import '../../domain/entities/performer_filter.dart';
import '../../domain/repositories/performer_repository.dart';
import '../graphql/performers.graphql.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_performer.dart';

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
    PerformerFilter? performerFilter,
    @Deprecated('Use performerFilter instead') bool favoritesOnly = false,
    @Deprecated('Use performerFilter instead') List<String>? genders,
  }) async {
    QueryResult<Query$FindPerformers>? result;
    String? effectiveSort = sort == 'scene_count' ? 'scenes_count' : sort;

    result = await _runFindPerformers(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: effectiveSort,
      descending: descending,
      favoritesOnly: favoritesOnly,
      genders: genders,
      performerFilter: performerFilter,
    );

    // Some servers may still use scene_count; retry if scenes_count is rejected.
    if (result.hasException &&
        effectiveSort == 'scenes_count' &&
        _isInvalidSort(result.exception!, 'scenes_count')) {
      effectiveSort = 'scene_count';
      result = await _runFindPerformers(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: effectiveSort,
        descending: descending,
        favoritesOnly: favoritesOnly,
        genders: genders,
      );
    }

    final shouldLocalSortBySceneCount =
        (sort == 'scene_count' || sort == 'scenes_count') &&
        result.hasException &&
        (_isInvalidSort(result.exception!, 'scenes_count') ||
            _isInvalidSort(result.exception!, 'scene_count'));

    if (shouldLocalSortBySceneCount) {
      result = await _runFindPerformers(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: null,
        descending: descending,
        favoritesOnly: favoritesOnly,
        genders: genders,
      );
    }

    if (result.hasException) throw result.exception!;

    final performers = result.parsedData!.findPerformers.performers
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

    if ((sort == 'scene_count' || sort == 'scenes_count') &&
        shouldLocalSortBySceneCount) {
      performers.sort(
        (a, b) => descending
            ? b.sceneCount.compareTo(a.sceneCount)
            : a.sceneCount.compareTo(b.sceneCount),
      );
    }

    return performers;
  }

  Future<QueryResult<Query$FindPerformers>> _runFindPerformers({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    required bool descending,
    bool favoritesOnly = false,
    List<String>? genders,
    PerformerFilter? performerFilter,
  }) {
    final genderEnums = (genders ?? const <String>[])
        .map(fromJson$Enum$GenderEnum)
        .toList();

    final inputFilter = Input$PerformerFilterType(
      filter_favorites:
          (favoritesOnly || performerFilter?.favorite == true) ? true : null,
      gender: performerFilter?.gender != null
          ? mapGenderCriterion(performerFilter!.gender)
          : genderEnums.isNotEmpty
              ? Input$GenderCriterionInput(
                  value_list: genderEnums,
                  modifier: Enum$CriterionModifier.INCLUDES,
                )
              : null,
      circumcised: mapCircumcisionCriterion(performerFilter?.circumcised),
      tags: mapHierarchicalMultiCriterion(performerFilter?.tags),
      groups: mapHierarchicalMultiCriterion(performerFilter?.groups),
      studios: mapHierarchicalMultiCriterion(performerFilter?.studios),
      url: mapStringCriterion(performerFilter?.url),
      rating100: mapIntCriterion(performerFilter?.rating100),
      tag_count: mapIntCriterion(performerFilter?.tagCount),
      scene_count: mapIntCriterion(performerFilter?.sceneCount),
      image_count: mapIntCriterion(performerFilter?.imageCount),
      gallery_count: mapIntCriterion(performerFilter?.galleryCount),
      play_count: mapIntCriterion(performerFilter?.playCount),
      o_counter: mapIntCriterion(performerFilter?.oCounter),
      ignore_auto_tag: performerFilter?.ignoreAutoTag,
      country: mapStringCriterion(performerFilter?.country),
      height_cm: mapIntCriterion(performerFilter?.heightCm),
      birth_year: mapIntCriterion(performerFilter?.birthYear),
      death_year: mapIntCriterion(performerFilter?.deathYear),
      age: mapIntCriterion(performerFilter?.age),
      weight: mapIntCriterion(performerFilter?.weight),
      penis_length: mapFloatCriterion(performerFilter?.penisLength),
      name: mapStringCriterion(performerFilter?.name),
      disambiguation: mapStringCriterion(performerFilter?.disambiguation),
      details: mapStringCriterion(performerFilter?.details),
      ethnicity: mapStringCriterion(performerFilter?.ethnicity),
      hair_color: mapStringCriterion(performerFilter?.hairColor),
      eye_color: mapStringCriterion(performerFilter?.eyeColor),
      measurements: mapStringCriterion(performerFilter?.measurements),
      fake_tits: mapStringCriterion(performerFilter?.fakeTits),
      tattoos: mapStringCriterion(performerFilter?.tattoos),
      piercings: mapStringCriterion(performerFilter?.piercings),
      aliases: mapStringCriterion(performerFilter?.aliases),
      birthdate: mapDateCriterion(performerFilter?.birthdate),
      death_date: mapDateCriterion(performerFilter?.deathDate),
      career_start: mapDateCriterion(performerFilter?.careerStart),
      career_end: mapDateCriterion(performerFilter?.careerEnd),
      is_missing: performerFilter?.isMissing?.toString(),
      created_at: mapTimestampCriterion(performerFilter?.createdAt),
      updated_at: mapTimestampCriterion(performerFilter?.updatedAt),
    );

    return client.query$FindPerformers(
      Options$Query$FindPerformers(
        fetchPolicy: sort == 'random'
            ? FetchPolicy.noCache
            : FetchPolicy.cacheAndNetwork,
        variables: Variables$Query$FindPerformers(
          filter: Input$FindFilterType(
            q: filter ?? performerFilter?.searchQuery,
            page: page,
            per_page: perPage,
            sort: sort,
            direction: descending
                ? Enum$SortDirectionEnum.DESC
                : Enum$SortDirectionEnum.ASC,
          ),
          performer_filter: inputFilter,
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
  Future<Performer> getPerformerById(String id, {bool refresh = false}) async {
    final result = await client.query$FindPerformer(
      Options$Query$FindPerformer(
        fetchPolicy: refresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
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

  @override
  Future<void> setPerformerFavorite(String id, bool favorite) async {
    final result = await client.mutate$UpdatePerformerFavorite(
      Options$Mutation$UpdatePerformerFavorite(
        variables: Variables$Mutation$UpdatePerformerFavorite(
          id: id,
          favorite: favorite,
        ),
      ),
    );

    if (result.hasException) throw result.exception!;
  }

  @override
  Future<List<ScrapedPerformer>> scrapePerformer({
    String? scraperId,
    String? stashBoxEndpoint,
    String? performerId,
    String? query,
  }) async {
    final result = await client.query$ScrapeSinglePerformer(
      Options$Query$ScrapeSinglePerformer(
        variables: Variables$Query$ScrapeSinglePerformer(
          source: Input$ScraperSourceInput(
            scraper_id: scraperId,
            stash_box_endpoint: stashBoxEndpoint,
          ),
          input: Input$ScrapeSinglePerformerInput(
            performer_id: performerId,
            query: query,
          ),
        ),
      ),
    );

    if (result.hasException) throw result.exception!;

    final List<Query$ScrapeSinglePerformer$scrapeSinglePerformer> raw =
        result.parsedData?.scrapeSinglePerformer ?? [];

    return raw.map((e) => ScrapedPerformer.fromJson(e.toJson())).toList();
  }

  @override
  Future<ScrapedPerformer?> scrapePerformerURL(String url) async {
    final result = await client.query$ScrapePerformerURL(
      Options$Query$ScrapePerformerURL(
        variables: Variables$Query$ScrapePerformerURL(url: url),
      ),
    );

    if (result.hasException) throw result.exception!;

    final raw = result.parsedData?.scrapePerformerURL;
    return raw != null ? ScrapedPerformer.fromJson(raw.toJson()) : null;
  }

  @override
  Future<void> updatePerformer({
    required String id,
    required Map<String, dynamic> input,
  }) async {
    final result = await client.mutate$PerformerUpdate(
      Options$Mutation$PerformerUpdate(
        variables: Variables$Mutation$PerformerUpdate(
          input: Input$PerformerUpdateInput.fromJson({...input, 'id': id}),
        ),
      ),
    );

    if (result.hasException) throw result.exception!;
  }
}
