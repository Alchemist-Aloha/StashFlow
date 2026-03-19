// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GallerySearchQuery)
final gallerySearchQueryProvider = GallerySearchQueryProvider._();

final class GallerySearchQueryProvider
    extends $NotifierProvider<GallerySearchQuery, String> {
  GallerySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gallerySearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gallerySearchQueryHash();

  @$internal
  @override
  GallerySearchQuery create() => GallerySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$gallerySearchQueryHash() =>
    r'6ef9b99ec7ca0a2c05cb5b144446f3f24e9251ec';

abstract class _$GallerySearchQuery extends $Notifier<String> {
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

@ProviderFor(GalleryList)
final galleryListProvider = GalleryListProvider._();

final class GalleryListProvider
    extends $AsyncNotifierProvider<GalleryList, List<Gallery>> {
  GalleryListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryListHash();

  @$internal
  @override
  GalleryList create() => GalleryList();
}

String _$galleryListHash() => r'31f39d725f987b87cb01c5b2219424e8ecb32f00';

abstract class _$GalleryList extends $AsyncNotifier<List<Gallery>> {
  FutureOr<List<Gallery>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Gallery>>, List<Gallery>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Gallery>>, List<Gallery>>,
              AsyncValue<List<Gallery>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
