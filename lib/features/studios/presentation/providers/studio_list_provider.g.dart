// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studio_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudioRandomSeed)
final studioRandomSeedProvider = StudioRandomSeedProvider._();

final class StudioRandomSeedProvider
    extends $NotifierProvider<StudioRandomSeed, int> {
  StudioRandomSeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studioRandomSeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studioRandomSeedHash();

  @$internal
  @override
  StudioRandomSeed create() => StudioRandomSeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$studioRandomSeedHash() => r'8713e9df5e902efe9cb41ac32ddd4b0c48875fe7';

abstract class _$StudioRandomSeed extends $Notifier<int> {
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

@ProviderFor(StudioSort)
final studioSortProvider = StudioSortProvider._();

final class StudioSortProvider
    extends
        $NotifierProvider<
          StudioSort,
          ({bool descending, int? randomSeed, String? sort})
        > {
  StudioSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studioSortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studioSortHash();

  @$internal
  @override
  StudioSort create() => StudioSort();

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

String _$studioSortHash() => r'5db5abd5451e413592e288fd4eec55746b59aa9e';

abstract class _$StudioSort
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

@ProviderFor(StudioSearchQuery)
final studioSearchQueryProvider = StudioSearchQueryProvider._();

final class StudioSearchQueryProvider
    extends $NotifierProvider<StudioSearchQuery, String> {
  StudioSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studioSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studioSearchQueryHash();

  @$internal
  @override
  StudioSearchQuery create() => StudioSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$studioSearchQueryHash() => r'59ba940e44f748c4b7d394f262c5ed0838fcb837';

abstract class _$StudioSearchQuery extends $Notifier<String> {
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

@ProviderFor(StudioFavoritesOnly)
final studioFavoritesOnlyProvider = StudioFavoritesOnlyProvider._();

final class StudioFavoritesOnlyProvider
    extends $NotifierProvider<StudioFavoritesOnly, bool> {
  StudioFavoritesOnlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studioFavoritesOnlyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studioFavoritesOnlyHash();

  @$internal
  @override
  StudioFavoritesOnly create() => StudioFavoritesOnly();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$studioFavoritesOnlyHash() =>
    r'e1dcc49ec813db78b275aaf662d7272c221e1162';

abstract class _$StudioFavoritesOnly extends $Notifier<bool> {
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

@ProviderFor(StudioList)
final studioListProvider = StudioListProvider._();

final class StudioListProvider
    extends $AsyncNotifierProvider<StudioList, List<Studio>> {
  StudioListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studioListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studioListHash();

  @$internal
  @override
  StudioList create() => StudioList();
}

String _$studioListHash() => r'9c941c0344f1bbb1cf834b87dcb9afb0b38a3db8';

abstract class _$StudioList extends $AsyncNotifier<List<Studio>> {
  FutureOr<List<Studio>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Studio>>, List<Studio>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Studio>>, List<Studio>>,
              AsyncValue<List<Studio>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
