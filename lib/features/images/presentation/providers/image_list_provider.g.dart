// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImageScrollController)
final imageScrollControllerProvider = ImageScrollControllerProvider._();

final class ImageScrollControllerProvider
    extends $NotifierProvider<ImageScrollController, ScrollController> {
  ImageScrollControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageScrollControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageScrollControllerHash();

  @$internal
  @override
  ImageScrollController create() => ImageScrollController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScrollController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScrollController>(value),
    );
  }
}

String _$imageScrollControllerHash() =>
    r'2c34a7df2c05bbcf57cae15dbc5250e11fbf34df';

abstract class _$ImageScrollController extends $Notifier<ScrollController> {
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

@ProviderFor(ImageSort)
final imageSortProvider = ImageSortProvider._();

final class ImageSortProvider
    extends $NotifierProvider<ImageSort, ({bool descending, String? sort})> {
  ImageSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageSortProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageSortHash();

  @$internal
  @override
  ImageSort create() => ImageSort();

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

String _$imageSortHash() => r'8fd26a1e333853077e69105164e5da54289c7d47';

abstract class _$ImageSort
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

@ProviderFor(ImageSearchQuery)
final imageSearchQueryProvider = ImageSearchQueryProvider._();

final class ImageSearchQueryProvider
    extends $NotifierProvider<ImageSearchQuery, String> {
  ImageSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageSearchQueryHash();

  @$internal
  @override
  ImageSearchQuery create() => ImageSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$imageSearchQueryHash() => r'786cb26c7a2fc901c999ddcff04a5f111de7f822';

abstract class _$ImageSearchQuery extends $Notifier<String> {
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

@ProviderFor(ImageFilterState)
final imageFilterStateProvider = ImageFilterStateProvider._();

final class ImageFilterStateProvider
    extends
        $NotifierProvider<
          ImageFilterState,
          ({ImageFilter filter, String? galleryId})
        > {
  ImageFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageFilterStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageFilterStateHash();

  @$internal
  @override
  ImageFilterState create() => ImageFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({ImageFilter filter, String? galleryId}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<({ImageFilter filter, String? galleryId})>(value),
    );
  }
}

String _$imageFilterStateHash() => r'c43d353209193b53fe600e3a1f62bac785573fba';

abstract class _$ImageFilterState
    extends $Notifier<({ImageFilter filter, String? galleryId})> {
  ({ImageFilter filter, String? galleryId}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({ImageFilter filter, String? galleryId}),
              ({ImageFilter filter, String? galleryId})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({ImageFilter filter, String? galleryId}),
                ({ImageFilter filter, String? galleryId})
              >,
              ({ImageFilter filter, String? galleryId}),
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ImageOrganizedOnly)
final imageOrganizedOnlyProvider = ImageOrganizedOnlyProvider._();

final class ImageOrganizedOnlyProvider
    extends $NotifierProvider<ImageOrganizedOnly, bool> {
  ImageOrganizedOnlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageOrganizedOnlyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageOrganizedOnlyHash();

  @$internal
  @override
  ImageOrganizedOnly create() => ImageOrganizedOnly();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$imageOrganizedOnlyHash() =>
    r'ed1087d6b5fa2d7a8fd089810851ef4643cd438e';

abstract class _$ImageOrganizedOnly extends $Notifier<bool> {
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

@ProviderFor(ImageList)
final imageListProvider = ImageListProvider._();

final class ImageListProvider
    extends $AsyncNotifierProvider<ImageList, List<entity.Image>> {
  ImageListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageListHash();

  @$internal
  @override
  ImageList create() => ImageList();
}

String _$imageListHash() => r'4ebeeda70e94686f5cb633ffaeb3f08c5043bf38';

abstract class _$ImageList extends $AsyncNotifier<List<entity.Image>> {
  FutureOr<List<entity.Image>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<entity.Image>>, List<entity.Image>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<entity.Image>>, List<entity.Image>>,
              AsyncValue<List<entity.Image>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
