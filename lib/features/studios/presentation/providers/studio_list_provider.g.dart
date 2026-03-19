// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studio_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
        isAutoDispose: true,
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

String _$studioSearchQueryHash() => r'37d6a207ea36be45da0d8c55238db84c11a19425';

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
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studioListHash();

  @$internal
  @override
  StudioList create() => StudioList();
}

String _$studioListHash() => r'99666f5659aab84dcf0d5798f2733efae0ae5422';

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
