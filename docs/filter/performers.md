# Filters: performers

- Endpoint / GraphQL call: findPerformers(filter: PerformerFilterType, find_filter: FindFilterType)
- Schema reference: graphql/schema/types/performer.graphql and graphql/schema/types/filters.graphql (PerformerFilterType)
- Server implementation references: pkg/sqlite/performer.go (getPerformerSort and criterion usage), pkg/sqlite/criterion_handlers.go, pkg/sqlite/filter.go
- TypeScript UI reference: ui/v2.5/src/models/list-filter/performers.ts

Available Performer filters (server-side names / input types):

- name, disambiguation, details: StringCriterionInput
- filter_favorites: Boolean
- birth_year, age: IntCriterionInput
- ethnicity, country, eye_color: StringCriterionInput
- height_cm: IntCriterionInput
- measurements: StringCriterionInput
- fake_tits: StringCriterionInput
- penis_length: FloatCriterionInput
- circumcised: CircumcisionCriterionInput
- career_start, career_end: DateCriterionInput
- tattoos, piercings, aliases: StringCriterionInput
- gender: GenderCriterionInput
- is_missing: String
- tags: HierarchicalMultiCriterionInput
- tag_count, scene_count, marker_count, image_count, gallery_count: IntCriterionInput
- play_count, o_counter, rating100: IntCriterionInput
- url: StringCriterionInput
- hair_color, weight, death_year: various inputs
- studios, groups, performers nested filters: studios, groups, performers
- created_at, updated_at: TimestampCriterionInput
- custom_fields: CustomFieldCriterionInput

Quick Flutter snippet (example: filter performers by birth_year range and tags includes)

```dart
final query = r'''
query FindPerformers($filter: PerformerFilterType, $findFilter: FindFilterType) {
  findPerformers(filter: $filter, find_filter: $findFilter) {
    count
    performers {
      id
      name
      birth_year
      tag_count
    }
  }
}
''';

final variables = {
  'filter': {
    'birth_year': {
      'value': 1980,
      'value2': 1995,
      'modifier': 'BETWEEN'
    },
    'tags': {
      'value': ['vintage'],
      'modifier': 'INCLUDES'
    }
  },
  'findFilter': {
    'sort': 'name',
    'direction': 'ASC',
    'page': 1,
    'per_page': 25,
  }
};

final result = await client.query(QueryOptions(document: gql(query), variables: variables));
```

Notes:

- Many performer filters map to columns on performers table or require joins to performers_scenes, performers_images tables for counts.
- Complex aggregations like scenes_duration use SQL subqueries in performer.go (selectPerformerScenesDurationSQL).
