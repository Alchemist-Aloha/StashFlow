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

String _$imageSortHash() => r'4f5369b8fba82e47b90642602e9e200b06659931';

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
    extends $NotifierProvider<ImageFilterState, ({String? galleryId})> {
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
  Override overrideWithValue(({String? galleryId}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({String? galleryId})>(value),
    );
  }
}

String _$imageFilterStateHash() => r'a84520046b8de9575e4a2706db54ddfe09f1a815';

abstract class _$ImageFilterState extends $Notifier<({String? galleryId})> {
  ({String? galleryId}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<({String? galleryId}), ({String? galleryId})>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<({String? galleryId}), ({String? galleryId})>,
              ({String? galleryId}),
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MediaViewToggle)
final mediaViewToggleProvider = MediaViewToggleProvider._();

final class MediaViewToggleProvider
    extends $NotifierProvider<MediaViewToggle, MediaViewType> {
  MediaViewToggleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaViewToggleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaViewToggleHash();

  @$internal
  @override
  MediaViewToggle create() => MediaViewToggle();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaViewType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaViewType>(value),
    );
  }
}

String _$mediaViewToggleHash() => r'7dfb561e69c5cd8d23ecde2730661ef7024d4e6c';

abstract class _$MediaViewToggle extends $Notifier<MediaViewType> {
  MediaViewType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MediaViewType, MediaViewType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MediaViewType, MediaViewType>,
              MediaViewType,
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

String _$imageListHash() => r'90728386ed63d98a117524317c8fc347970cab4b';

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
