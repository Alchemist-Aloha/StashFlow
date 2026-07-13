# Filters: images

- Endpoint / GraphQL call: findImages(filter: ImageFilterType, find_filter: FindFilterType)
- Schema reference: graphql/schema/types/image.graphql and graphql/schema/types/filters.graphql (ImageFilterType)
- Server implementation references: pkg/sqlite/image.go (makeQuery, setImageSortAndPagination), pkg/sqlite/criterion_handlers.go, pkg/sqlite/filter.go
- TypeScript UI reference: ui/v2.5/src/models/list-filter/* (criteria and filter-options)

Available Image filters (server-side names / input types):

- title, details: StringCriterionInput
- id: IntCriterionInput
- checksum, oshash: StringCriterionInput
- phash_distance: PhashDistanceCriterionInput
- path: StringCriterionInput
- file_count: IntCriterionInput
- rating100: IntCriterionInput
- date: DateCriterionInput
- url: StringCriterionInput
- organized: Boolean
- o_counter: IntCriterionInput
- resolution: ResolutionCriterionInput
- orientation: OrientationCriterionInput
- is_missing: String
- studios: HierarchicalMultiCriterionInput
- tags: HierarchicalMultiCriterionInput
- tag_count: IntCriterionInput
- performer_tags: HierarchicalMultiCriterionInput
- performers: MultiCriterionInput
- performer_count: IntCriterionInput
- performer_favorite: Boolean
- performer_age: IntCriterionInput
- galleries: MultiCriterionInput
- created_at, updated_at: TimestampCriterionInput
- code: StringCriterionInput
- photographer: StringCriterionInput
- images/galleries/performers/studios nested filters: images_filter, galleries_filter, performers_filter, studios_filter
- files_filter: FileFilterType (nested video/image file filters)

Quick Flutter snippet (example: filter images by resolution >= 1080p and tag includes "landscape")

```dart
final query = r'''
query FindImages($filter: ImageFilterType, $findFilter: FindFilterType) {
  findImages(filter: $filter, find_filter: $findFilter) {
    count
    images {
      id
      title
      paths { thumbnail }
      resolution
    }
  }
}
''';

final variables = {
  'filter': {
    'resolution': {
      'value': 'FULL_HD', // 1080p
      'modifier': 'GREATER_THAN'
    },
    'tags': {
      'value': ['landscape'],
      'modifier': 'INCLUDES'
    }
  },
  'findFilter': {
    'page': 1,
    'per_page': 25,
    'sort': 'resolution',
    'direction': 'DESC'
  }
};

final result = await client.query(QueryOptions(document: gql(query), variables: variables));
```

Notes:

- Image file-specific filters (format, resolution, orientation) exist under ImageFileFilterInput (see filters.graphql lines near ImageFileFilterInput).
- Use joined handlers server-side to filter by file attributes (pkg/sqlite/criterion_handlers.go and image.go addFilesJoin/addFolderJoin helpers).
