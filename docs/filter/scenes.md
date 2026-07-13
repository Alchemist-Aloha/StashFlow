# Filters: scenes

- Endpoint / GraphQL call: findScenes(filter: SceneFilterType, find_filter: FindFilterType)
- Schema reference: graphql/schema/types/scene.graphql and graphql/schema/types/filters.graphql (SceneFilterType)
- Server implementation references: pkg/sqlite/scene.go (makeQuery, criterion handling), pkg/sqlite/criterion_handlers.go, pkg/sqlite/filter.go
- TypeScript UI reference: ui/v2.5/src/models/list-filter/ (criteria files and filter-options.ts)

Available Scene filters (server-side names / input types):

- id: IntCriterionInput
- title: StringCriterionInput
- code: StringCriterionInput
- details: StringCriterionInput
- oshash, checksum, phash (hash related)
- phash_distance: PhashDistanceCriterionInput
- path: StringCriterionInput
- file_count: IntCriterionInput
- rating100: IntCriterionInput
- date: DateCriterionInput
- organized: Boolean
- o_counter: IntCriterionInput
- resolution: ResolutionCriterionInput
- orientation: OrientationCriterionInput
- is_missing: String
- studios/groups/galleries: HierarchicalMultiCriterionInput / MultiCriterionInput
- tags: HierarchicalMultiCriterionInput
- tag_count, performer_count, performer_tags
- performers: MultiCriterionInput
- duration, framerate, bitrate, video_codec, audio_codec
- has_markers, captions, resume_time
- play_count, play_duration, last_played_at
- created_at, updated_at
- files_filter, images_filter, galleries_filter, markers_filter

Quick Flutter snippet (graphql_flutter) — example: filter scenes by date range and min play_count

```dart
final query = r'''
query FindScenes($filter: SceneFilterType, $findFilter: FindFilterType) {
  findScenes(filter: $filter, find_filter: $findFilter) {
    count
    scenes {
      id
      title
      date
      play_count
    }
  }
}
''';

final variables = {
  'filter': {
    'date': {
      'value': '2022-01-01',
      'value2': '2022-12-31',
      'modifier': 'BETWEEN'
    },
    'play_count': {
      'value': 10,
      'modifier': 'GREATER_THAN'
    }
  },
  'findFilter': {
    'page': 1,
    'per_page': 25,
    'sort': 'date',
    'direction': 'DESC'
  }
};

final result = await client.query(QueryOptions(document: gql(query), variables: variables));
```

Notes:

- Use the CriterionModifier enum (EQUALS, INCLUDES, BETWEEN, GREATER_THAN, etc.) when constructing criterion inputs.
- For filters that reference related entities (performers, tags, galleries), the GraphQL inputs accept nested filter types (e.g., performers_filter).
- Server-side handlers live in pkg/sqlite/criterion_handlers.go — they map criterion inputs into SQL WHERE clauses.
