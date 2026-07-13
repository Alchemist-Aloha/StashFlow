# Filter: file_format

- Endpoint / GraphQL call: findImages(filter: ImageFilterType, find_filter: FindFilterType)
- Filter input name (suggested): `format` (StringCriterionInput)
- Schema reference: graphql/schema/types/file.graphql (ImageFile.format, VideoFile.format) and graphql/schema/types/filters.graphql
- Server implementation reference: pkg/sqlite/criterion_handlers.go (joinedStringCriterionHandler), pkg/sqlite/image.go (makeQuery and handler attachment)
- Frontend (TypeScript) reference: ui/v2.5/src/models/list-filter/criteria/* (see examples like resolution.ts or path.ts for pattern)

Quick Flutter snippet (graphql_flutter)

```dart
final query = r'''
query FindImages($filter: ImageFilterType, $findFilter: FindFilterType) {
  findImages(filter: $filter, find_filter: $findFilter) {
    count
    images {
      id
      title
      paths { thumbnail }
    }
  }
}
''';

final variables = {
  'filter': {
    'format': {
      'value': 'webp',
      'modifier': 'EQUALS'
    }
  },
  'findFilter': {
    'page': 1,
    'per_page': 25,
  }
};

final result = await client.query(QueryOptions(
  document: gql(query),
  variables: variables,
));

// Parse result.data['findImages']['images'] for display
```

Implementation notes

- Backend: use joinedStringCriterionHandler to add joins to images_files -> image_files (or files table) and filter on format column.
- Frontend TS reference: see ui/v2.5/src/models/list-filter/criteria for how web UI exposes similar filters; follow that UI pattern for Flutter (multi-select or dropdown for formats).
