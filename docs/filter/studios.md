# Filters: studios

- Endpoint / GraphQL call: findStudios(filter: StudioFilterType, find_filter: FindFilterType)
- Schema reference: graphql/schema/types/studio.graphql and graphql/schema/types/filters.graphql (StudioFilterType)
- Server implementation references: pkg/sqlite/studio.go (studio repository, sort/filter handlers), pkg/sqlite/criterion_handlers.go, pkg/sqlite/filter.go
- TypeScript UI reference: ui/v2.5/src/models/list-filter/studios.ts

Available Studio filters (server-side names / input types):

- name: StringCriterionInput
- sort_name: StringCriterionInput
- favorite: Boolean
- description: StringCriterionInput
- images_count, movies_count, scenes_count: IntCriterionInput or aggregated counts
- created_at, updated_at: TimestampCriterionInput
- related entity filters: scenes_filter, images_filter, performers_filter

Quick Flutter snippet (example: filter studios by name includes "studio")

```dart
final query = r'''
query FindStudios($filter: StudioFilterType, $findFilter: FindFilterType) {
  findStudios(filter: $filter, find_filter: $findFilter) {
    count
    studios {
      id
      name
      images_count
    }
  }
}
''';

final variables = {
  'filter': {
    'name': {
      'value': 'studio',
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

- Studio filters generally map to columns on the studios table or aggregated counts via joins.
- See pkg/sqlite/studio.go for how joins and sorting are managed for related counts.
