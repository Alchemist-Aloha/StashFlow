// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performer_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PerformerRandomSeed)
final performerRandomSeedProvider = PerformerRandomSeedProvider._();

final class PerformerRandomSeedProvider
    extends $NotifierProvider<PerformerRandomSeed, int> {
  PerformerRandomSeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performerRandomSeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerRandomSeedHash();

  @$internal
  @override
  PerformerRandomSeed create() => PerformerRandomSeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$performerRandomSeedHash() =>
    r'abd99fa2547783885f7d17543c8844547d420e7f';

abstract class _$PerformerRandomSeed extends $Notifier<int> {
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

@ProviderFor(PerformerSort)
final performerSortProvider = PerformerSortProvider._();

final class PerformerSortProvider
    extends
        $NotifierProvider<
          PerformerSort,
          ({bool descending, int? randomSeed, String? sort})
        > {
  PerformerSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performerSortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerSortHash();

  @$internal
  @override
  PerformerSort create() => PerformerSort();

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

String _$performerSortHash() => r'05b7eeebff15e0bf0c48731d0ed177d519047f3e';

abstract class _$PerformerSort
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

@ProviderFor(PerformerSearchQuery)
final performerSearchQueryProvider = PerformerSearchQueryProvider._();

final class PerformerSearchQueryProvider
    extends $NotifierProvider<PerformerSearchQuery, String> {
  PerformerSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performerSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerSearchQueryHash();

  @$internal
  @override
  PerformerSearchQuery create() => PerformerSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$performerSearchQueryHash() =>
    r'75114d2b1c46062ace3172c85372df02688b462c';

abstract class _$PerformerSearchQuery extends $Notifier<String> {
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

@ProviderFor(PerformerFilter)
final performerFilterProvider = PerformerFilterProvider._();

final class PerformerFilterProvider
    extends $NotifierProvider<PerformerFilter, PerformerFilterState> {
  PerformerFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performerFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerFilterHash();

  @$internal
  @override
  PerformerFilter create() => PerformerFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PerformerFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PerformerFilterState>(value),
    );
  }
}

String _$performerFilterHash() => r'10008aefebaf9846d005b22668590179c1894f55';

abstract class _$PerformerFilter extends $Notifier<PerformerFilterState> {
  PerformerFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PerformerFilterState, PerformerFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PerformerFilterState, PerformerFilterState>,
              PerformerFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PerformerFavoritesOnly)
final performerFavoritesOnlyProvider = PerformerFavoritesOnlyProvider._();

final class PerformerFavoritesOnlyProvider
    extends $NotifierProvider<PerformerFavoritesOnly, bool> {
  PerformerFavoritesOnlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performerFavoritesOnlyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerFavoritesOnlyHash();

  @$internal
  @override
  PerformerFavoritesOnly create() => PerformerFavoritesOnly();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$performerFavoritesOnlyHash() =>
    r'da04debecb17b2e114a155517795aa0f3f35f988';

abstract class _$PerformerFavoritesOnly extends $Notifier<bool> {
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

@ProviderFor(PerformerList)
final performerListProvider = PerformerListProvider._();

final class PerformerListProvider
    extends $AsyncNotifierProvider<PerformerList, List<Performer>> {
  PerformerListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performerListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerListHash();

  @$internal
  @override
  PerformerList create() => PerformerList();
}

String _$performerListHash() => r'107199abab3ed92bb4d3355d3b833041d0d63cee';

abstract class _$PerformerList extends $AsyncNotifier<List<Performer>> {
  FutureOr<List<Performer>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Performer>>, List<Performer>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Performer>>, List<Performer>>,
              AsyncValue<List<Performer>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
