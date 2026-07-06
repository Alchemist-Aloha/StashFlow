import 'dart:convert';

abstract class SavedFilterConfig<TFilter> {
  const SavedFilterConfig({
    this.id,
    required this.name,
    required this.filterMode,
    required this.searchQuery,
    required this.sort,
    required this.descending,
    required this.filter,
    this.perPage,
  });

  final String? id;
  final String name;
  final String filterMode;
  final String searchQuery;
  final String? sort;
  final bool descending;
  final TFilter filter;
  final int? perPage;

  Map<String, dynamic> toSaveInput();
}

class SavedFilterSkipValue {
  const SavedFilterSkipValue._();
}

const savedFilterSkipValue = SavedFilterSkipValue._();

class SavedFilterPayload<TFilter> {
  const SavedFilterPayload({
    required this.searchQuery,
    required this.sort,
    required this.descending,
    required this.filter,
    this.perPage,
  });

  final String searchQuery;
  final String? sort;
  final bool descending;
  final TFilter filter;
  final int? perPage;
}

SavedFilterPayload<TFilter> savedFilterReadPayload<TFilter>({
  required Object? findFilter,
  required Object? objectFilter,
  required TFilter emptyFilter,
  required TFilter Function(Map<String, dynamic> json) fromJson,
  Map<String, String> serverToLocalKeys = const {},
  Object? Function(String localKey, Object? value)? normalizeValue,
}) {
  final findFilterMap = savedFilterAsMap(findFilter);
  final objectFilterMap = savedFilterAsMap(objectFilter);
  final direction = findFilterMap['direction'];

  return SavedFilterPayload(
    searchQuery: findFilterMap['q'] as String? ?? '',
    sort: findFilterMap['sort'] as String?,
    descending: direction is String ? direction.toUpperCase() == 'DESC' : true,
    perPage: findFilterMap['per_page'] as int?,
    filter: objectFilterMap.isEmpty
        ? emptyFilter
        : fromJson(
            savedFilterFromServerObjectFilter(
              objectFilter: objectFilterMap,
              serverToLocalKeys: serverToLocalKeys,
              normalizeValue: normalizeValue,
            ),
          ),
  );
}

Map<String, dynamic> savedFilterBuildInput({
  String? id,
  required String mode,
  required String name,
  required String searchQuery,
  required String? sort,
  required bool descending,
  required Map<String, dynamic> objectFilter,
  int? perPage,
}) {
  return {
    'id': ?id,
    'mode': mode,
    'name': name,
    'find_filter': {
      if (searchQuery.isNotEmpty) 'q': searchQuery,
      'page': 1,
      'per_page': ?perPage,
      'sort': ?sort,
      'direction': descending ? 'DESC' : 'ASC',
    },
    'object_filter': objectFilter,
    'ui_options': <String, Object?>{},
  };
}

Map<String, dynamic> savedFilterAsMap(Object? value) {
  if (value == null) return <String, dynamic>{};
  if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  if (value is String && value.trim().isNotEmpty) {
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  }
  return <String, dynamic>{};
}

Map<String, dynamic> savedFilterWithoutNulls(Map<String, dynamic> value) {
  return {
    for (final entry in value.entries)
      if (entry.value != null) entry.key: entry.value,
  };
}

Map<String, dynamic> savedFilterToServerObjectFilter({
  required Map<String, dynamic> localJson,
  Map<String, String> localToServerKeys = const {},
}) {
  final compact = savedFilterWithoutNulls(localJson);
  return {
    for (final entry in compact.entries)
      localToServerKeys[entry.key] ?? entry.key: entry.value,
  };
}

Map<String, dynamic> savedFilterFromServerObjectFilter({
  required Map<String, dynamic> objectFilter,
  Map<String, String> serverToLocalKeys = const {},
  Object? Function(String localKey, Object? value)? normalizeValue,
}) {
  final output = <String, dynamic>{};
  for (final entry in objectFilter.entries) {
    final localKey = serverToLocalKeys[entry.key] ?? entry.key;
    final normalized =
        normalizeValue?.call(localKey, entry.value) ?? entry.value;
    if (identical(normalized, savedFilterSkipValue)) continue;
    output[localKey] = normalized;
  }
  return output;
}

bool? savedFilterReadBooleanCriterionValue(Object? value) {
  final rawValue = value is Map ? value['value'] : value;
  if (rawValue is bool) return rawValue;
  if (rawValue is String) {
    return switch (rawValue.toLowerCase()) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }
  return null;
}
