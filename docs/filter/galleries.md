# Filters: galleries

- Endpoint / GraphQL call: findGalleries(filter: GalleryFilterType, find_filter: FindFilterType)
- Schema reference: graphql/schema/types/gallery.graphql and graphql/schema/types/filters.graphql (GalleryFilterType)
- Server implementation references: pkg/sqlite/gallery.go (makeQuery, setGallerySort), pkg/sqlite/criterion_handlers.go, pkg/sqlite/filter.go
- TypeScript UI reference: ui/v2.5/src/models/list-filter/galleries.ts

Available Gallery filters (server-side names / input types):

- title: StringCriterionInput
- id: IntCriterionInput
- date: DateCriterionInput
- path, folder related filters: path: StringCriterionInput, folder filters
- file_count, images_count, tag_count, performer_count: IntCriterionInput
- rating: IntCriterionInput
- created_at, updated_at: TimestampCriterionInput
- related filters: performers_filter, tags_filter, scenes_filter, studios_filter

Quick Flutter snippet (example: filter galleries with images_count >= 10)

```dart
final query = r'''
query FindGalleries($filter: GalleryFilterType, $findFilter: FindFilterType) {
  findGalleries(filter: $filter, find_filter: $findFilter) {
    count
    galleries {
      id
      title
      images_count
    }
  }
}
''';

final variables = {
  'filter': {
    'images_count': {
      'value': 10,
      'modifier': 'GREATER_THAN'
    }
  },
  'findFilter': {
    'sort': 'title',
    'direction': 'ASC',
    'page': 1,
    'per_page': 25,
  }
};

final result = await client.query(QueryOptions(document: gql(query), variables: variables));
```

Notes:

- Path-based filters may require additional joins to folders/files; see gallery.go addFileTable/addFolderTable helpers.
- Aggregated counts use getCountSort helper where needed.
