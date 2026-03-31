// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studio_galleries_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studioGalleries)
final studioGalleriesProvider = StudioGalleriesFamily._();

final class StudioGalleriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PerformerGalleryItem>>,
          List<PerformerGalleryItem>,
          FutureOr<List<PerformerGalleryItem>>
        >
    with
        $FutureModifier<List<PerformerGalleryItem>>,
        $FutureProvider<List<PerformerGalleryItem>> {
  StudioGalleriesProvider._({
    required StudioGalleriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studioGalleriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studioGalleriesHash();

  @override
  String toString() {
    return r'studioGalleriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PerformerGalleryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PerformerGalleryItem>> create(Ref ref) {
    final argument = this.argument as String;
    return studioGalleries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StudioGalleriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studioGalleriesHash() => r'0aae31cfb53ea50ad25419656964f872aaf6ffc4';

final class StudioGalleriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PerformerGalleryItem>>,
          String
        > {
  StudioGalleriesFamily._()
    : super(
        retry: null,
        name: r'studioGalleriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudioGalleriesProvider call(String studioId) =>
      StudioGalleriesProvider._(argument: studioId, from: this);

  @override
  String toString() => r'studioGalleriesProvider';
}

@ProviderFor(StudioGalleriesGrid)
final studioGalleriesGridProvider = StudioGalleriesGridFamily._();

final class StudioGalleriesGridProvider
    extends
        $AsyncNotifierProvider<
          StudioGalleriesGrid,
          List<PerformerGalleryItem>
        > {
  StudioGalleriesGridProvider._({
    required StudioGalleriesGridFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studioGalleriesGridProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studioGalleriesGridHash();

  @override
  String toString() {
    return r'studioGalleriesGridProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StudioGalleriesGrid create() => StudioGalleriesGrid();

  @override
  bool operator ==(Object other) {
    return other is StudioGalleriesGridProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studioGalleriesGridHash() =>
    r'201240a7a33f7187498685607818e07db7910c64';

final class StudioGalleriesGridFamily extends $Family
    with
        $ClassFamilyOverride<
          StudioGalleriesGrid,
          AsyncValue<List<PerformerGalleryItem>>,
          List<PerformerGalleryItem>,
          FutureOr<List<PerformerGalleryItem>>,
          String
        > {
  StudioGalleriesGridFamily._()
    : super(
        retry: null,
        name: r'studioGalleriesGridProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudioGalleriesGridProvider call(String studioId) =>
      StudioGalleriesGridProvider._(argument: studioId, from: this);

  @override
  String toString() => r'studioGalleriesGridProvider';
}

abstract class _$StudioGalleriesGrid
    extends $AsyncNotifier<List<PerformerGalleryItem>> {
  late final _$args = ref.$arg as String;
  String get studioId => _$args;

  FutureOr<List<PerformerGalleryItem>> build(String studioId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<PerformerGalleryItem>>,
              List<PerformerGalleryItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PerformerGalleryItem>>,
                List<PerformerGalleryItem>
              >,
              AsyncValue<List<PerformerGalleryItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
