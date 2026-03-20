// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GallerySort)
final gallerySortProvider = GallerySortProvider._();

final class GallerySortProvider
    extends $NotifierProvider<GallerySort, ({bool descending, String? sort})> {
  GallerySortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gallerySortProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gallerySortHash();

  @$internal
  @override
  GallerySort create() => GallerySort();

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

String _$gallerySortHash() => r'598ebd7c2d1c06272a444b269461780ed7b67863';

abstract class _$GallerySort
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

String _$galleryListHash() => r'c0a5d473a30b7483f595f14f38c6fedf5447909f';

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
