// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TagRandomSeed)
final tagRandomSeedProvider = TagRandomSeedProvider._();

final class TagRandomSeedProvider
    extends $NotifierProvider<TagRandomSeed, int> {
  TagRandomSeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagRandomSeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagRandomSeedHash();

  @$internal
  @override
  TagRandomSeed create() => TagRandomSeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$tagRandomSeedHash() => r'487567ef05ed58a6faacaa7767ae32cb96ff3984';

abstract class _$TagRandomSeed extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TagSort)
final tagSortProvider = TagSortProvider._();

final class TagSortProvider
    extends
        $NotifierProvider<
          TagSort,
          ({bool descending, int? randomSeed, String? sort})
        > {
  TagSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagSortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagSortHash();

  @$internal
  @override
  TagSort create() => TagSort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({bool descending, int? randomSeed, String? sort}) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            ({bool descending, int? randomSeed, String? sort})
          >(value),
    );
  }
}

String _$tagSortHash() => r'ec64cad7378744fd52cf36fd2af4550c28665ea4';

abstract class _$TagSort
    extends $Notifier<({bool descending, int? randomSeed, String? sort})> {
  ({bool descending, int? randomSeed, String? sort}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({bool descending, int? randomSeed, String? sort}),
              ({bool descending, int? randomSeed, String? sort})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({bool descending, int? randomSeed, String? sort}),
                ({bool descending, int? randomSeed, String? sort})
              >,
              ({bool descending, int? randomSeed, String? sort}),
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TagSearchQuery)
final tagSearchQueryProvider = TagSearchQueryProvider._();

final class TagSearchQueryProvider
    extends $NotifierProvider<TagSearchQuery, String> {
  TagSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagSearchQueryHash();

  @$internal
  @override
  TagSearchQuery create() => TagSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$tagSearchQueryHash() => r'5bb6b5a7a53dd4af83d487a481bc44facbb8470c';

abstract class _$TagSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TagFavoritesOnly)
final tagFavoritesOnlyProvider = TagFavoritesOnlyProvider._();

final class TagFavoritesOnlyProvider
    extends $NotifierProvider<TagFavoritesOnly, bool> {
  TagFavoritesOnlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagFavoritesOnlyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagFavoritesOnlyHash();

  @$internal
  @override
  TagFavoritesOnly create() => TagFavoritesOnly();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tagFavoritesOnlyHash() => r'6c27563b09aa460dcb737a355d3c1ffe065f1505';

abstract class _$TagFavoritesOnly extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TagList)
final tagListProvider = TagListProvider._();

final class TagListProvider extends $AsyncNotifierProvider<TagList, List<Tag>> {
  TagListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagListHash();

  @$internal
  @override
  TagList create() => TagList();
}

String _$tagListHash() => r'04fdcc24e6057fcff7d4056295fc6caa862a7804';

abstract class _$TagList extends $AsyncNotifier<List<Tag>> {
  FutureOr<List<Tag>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Tag>>, List<Tag>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Tag>>, List<Tag>>,
              AsyncValue<List<Tag>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
