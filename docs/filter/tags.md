# Filters: tags

- Endpoint / GraphQL call: findTags(filter: TagFilterType, find_filter: FindFilterType)
- Schema reference: graphql/schema/types/tag.graphql and graphql/schema/types/filters.graphql (TagFilterType)
- Server implementation references: pkg/sqlite/tag.go (queryTagSort/getTagSort, repository), pkg/sqlite/criterion_handlers.go, pkg/sqlite/filter.go
- TypeScript UI reference: ui/v2.5/src/models/list-filter/tags.ts

Available Tag filters (server-side names / input types):

- name: StringCriterionInput
- favorite: Boolean
- ignore_auto_tag: Boolean
- description: StringCriterionInput
- tag counts and relations: images_count, scenes_count, galleries_count, performers_count, studios_count (IntCriterionInput)
- scene_markers_count: IntCriterionInput
- scenes_duration, scenes_size: aggregated metrics (not direct columns)
- created_at, updated_at: TimestampCriterionInput
- custom_fields: CustomFieldCriterionInput
- related entity filters: galleries_filter, performers_filter, scenes_filter, studios_filter, groups_filter

Quick Flutter snippet (example: filter tags by favorite true and scenes_count > 5)

```dart
final query = r'''
query FindTags($filter: TagFilterType, $findFilter: FindFilterType) {
  findTags(filter: $filter, find_filter: $findFilter) {
    count
    tags {
      id
      name
      favorite
      scenes_count
    }
  }
}
''';

final variables = {
  'filter': {
    'favorite': true,
    'scenes_count': {
      'value': 5,
      'modifier': 'GREATER_THAN'
    }
  },
  'findFilter': {
    'sort': 'name',
    'direction': 'ASC',
    'page': 1,
    'per_page': 50,
  }
};

final result = await client.query(QueryOptions(document: gql(query), variables: variables));
```

Notes:

- Aggregation-related filters (scenes_duration/scenes_size) use subqueries in tag.go to compute sums across related scenes/files.
- Tag repository manages joins to scenes/images/galleries via joinRepository helpers in tag.go.
