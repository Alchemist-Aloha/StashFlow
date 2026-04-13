// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GroupRandomSeed)
final groupRandomSeedProvider = GroupRandomSeedProvider._();

final class GroupRandomSeedProvider
    extends $NotifierProvider<GroupRandomSeed, int> {
  GroupRandomSeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupRandomSeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupRandomSeedHash();

  @$internal
  @override
  GroupRandomSeed create() => GroupRandomSeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$groupRandomSeedHash() => r'f378782397f67125a7002eab6c49cd8d3f3b6d6c';

abstract class _$GroupRandomSeed extends $Notifier<int> {
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

@ProviderFor(GroupSort)
final groupSortProvider = GroupSortProvider._();

final class GroupSortProvider
    extends
        $NotifierProvider<
          GroupSort,
          ({bool descending, int? randomSeed, String? sort})
        > {
  GroupSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupSortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupSortHash();

  @$internal
  @override
  GroupSort create() => GroupSort();

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

String _$groupSortHash() => r'287cbbf886abbf3a3cf938d4bff46314ff4cc4a2';

abstract class _$GroupSort
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

@ProviderFor(GroupSearchQuery)
final groupSearchQueryProvider = GroupSearchQueryProvider._();

final class GroupSearchQueryProvider
    extends $NotifierProvider<GroupSearchQuery, String> {
  GroupSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupSearchQueryHash();

  @$internal
  @override
  GroupSearchQuery create() => GroupSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$groupSearchQueryHash() => r'ddd9ed856a641a02df7f8b2e74abf0e22c455862';

abstract class _$GroupSearchQuery extends $Notifier<String> {
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

@ProviderFor(GroupList)
final groupListProvider = GroupListProvider._();

final class GroupListProvider
    extends $AsyncNotifierProvider<GroupList, List<Group>> {
  GroupListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupListHash();

  @$internal
  @override
  GroupList create() => GroupList();
}

String _$groupListHash() => r'ef4e7446d0f8af298fbb63807ab0c1bd4b13e5cf';

abstract class _$GroupList extends $AsyncNotifier<List<Group>> {
  FutureOr<List<Group>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Group>>, List<Group>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Group>>, List<Group>>,
              AsyncValue<List<Group>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
