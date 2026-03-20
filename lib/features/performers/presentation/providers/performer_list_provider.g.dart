// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performer_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PerformerSort)
final performerSortProvider = PerformerSortProvider._();

final class PerformerSortProvider
    extends
        $NotifierProvider<PerformerSort, ({bool descending, String? sort})> {
  PerformerSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performerSortProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerSortHash();

  @$internal
  @override
  PerformerSort create() => PerformerSort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({bool descending, String? sort}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({bool descending, String? sort})>(
        value,
      ),
    );
  }
}

String _$performerSortHash() => r'7802a23e6c55b452015b6c2c83d1630c36673a6a';

abstract class _$PerformerSort
    extends $Notifier<({bool descending, String? sort})> {
  ({bool descending, String? sort}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({bool descending, String? sort}),
              ({bool descending, String? sort})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({bool descending, String? sort}),
                ({bool descending, String? sort})
              >,
              ({bool descending, String? sort}),
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
        isAutoDispose: true,
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
    r'ad7ecd461e2dad720f269bed09c975eb6bcba0fe';

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
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerListHash();

  @$internal
  @override
  PerformerList create() => PerformerList();
}

String _$performerListHash() => r'64dc62ca6e3488e93fd592c30d0a5198eded536a';

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
