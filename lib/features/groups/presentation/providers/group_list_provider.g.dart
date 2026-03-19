// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$groupListHash() => r'5a172412c3e62b3a64dc4505108ec129d4e2200b';

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
