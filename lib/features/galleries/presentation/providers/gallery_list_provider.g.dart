// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GalleryScrollController)
final galleryScrollControllerProvider = GalleryScrollControllerProvider._();

final class GalleryScrollControllerProvider
    extends $NotifierProvider<GalleryScrollController, ScrollController> {
  GalleryScrollControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryScrollControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryScrollControllerHash();

  @$internal
  @override
  GalleryScrollController create() => GalleryScrollController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScrollController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScrollController>(value),
    );
  }
}

String _$galleryScrollControllerHash() =>
    r'2901a6523a5af7edcb053c9c1b9ad4daca29d29b';

abstract class _$GalleryScrollController extends $Notifier<ScrollController> {
  ScrollController build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ScrollController, ScrollController>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScrollController, ScrollController>,
              ScrollController,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(GalleryRandomSeed)
final galleryRandomSeedProvider = GalleryRandomSeedProvider._();

final class GalleryRandomSeedProvider
    extends $NotifierProvider<GalleryRandomSeed, int> {
  GalleryRandomSeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryRandomSeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryRandomSeedHash();

  @$internal
  @override
  GalleryRandomSeed create() => GalleryRandomSeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$galleryRandomSeedHash() => r'6f83715bd5d7d3b2fb434b614f9e9902ff5a2628';

abstract class _$GalleryRandomSeed extends $Notifier<int> {
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

@ProviderFor(GallerySort)
final gallerySortProvider = GallerySortProvider._();

final class GallerySortProvider
    extends
        $NotifierProvider<
          GallerySort,
          ({bool descending, int? randomSeed, String? sort})
        > {
  GallerySortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gallerySortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gallerySortHash();

  @$internal
  @override
  GallerySort create() => GallerySort();

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

String _$gallerySortHash() => r'47ecb1c676cb4140dad64aa907b1da980629705d';

abstract class _$GallerySort
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
        isAutoDispose: false,
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
    r'6048ffea8b874b487d71cf8eafb1b14fb2a8b15f';

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

@ProviderFor(GalleryFilterState)
final galleryFilterStateProvider = GalleryFilterStateProvider._();

final class GalleryFilterStateProvider
    extends $NotifierProvider<GalleryFilterState, GalleryFilter> {
  GalleryFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryFilterStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryFilterStateHash();

  @$internal
  @override
  GalleryFilterState create() => GalleryFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GalleryFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GalleryFilter>(value),
    );
  }
}

String _$galleryFilterStateHash() =>
    r'3ad0ede5cbbdfece3df669f9ffb1c70deddfc067';

abstract class _$GalleryFilterState extends $Notifier<GalleryFilter> {
  GalleryFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GalleryFilter, GalleryFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GalleryFilter, GalleryFilter>,
              GalleryFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(GalleryOrganizedOnly)
final galleryOrganizedOnlyProvider = GalleryOrganizedOnlyProvider._();

final class GalleryOrganizedOnlyProvider
    extends $NotifierProvider<GalleryOrganizedOnly, bool> {
  GalleryOrganizedOnlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryOrganizedOnlyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryOrganizedOnlyHash();

  @$internal
  @override
  GalleryOrganizedOnly create() => GalleryOrganizedOnly();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$galleryOrganizedOnlyHash() =>
    r'15acb183603aeac06e44bcb09ed5884547871e8b';

abstract class _$GalleryOrganizedOnly extends $Notifier<bool> {
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

@ProviderFor(GalleryGridLayout)
final galleryGridLayoutProvider = GalleryGridLayoutProvider._();

final class GalleryGridLayoutProvider
    extends $NotifierProvider<GalleryGridLayout, bool> {
  GalleryGridLayoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryGridLayoutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryGridLayoutHash();

  @$internal
  @override
  GalleryGridLayout create() => GalleryGridLayout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$galleryGridLayoutHash() => r'0f83d026f100f24fa21470a33fd69dbbb0c365be';

abstract class _$GalleryGridLayout extends $Notifier<bool> {
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
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryListHash();

  @$internal
  @override
  GalleryList create() => GalleryList();
}

String _$galleryListHash() => r'6d846429cc6e36603d5298ac59deba3c91134b78';

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
