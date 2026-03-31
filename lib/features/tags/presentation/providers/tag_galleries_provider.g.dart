// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_galleries_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tagGalleries)
final tagGalleriesProvider = TagGalleriesFamily._();

final class TagGalleriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PerformerGalleryItem>>,
          List<PerformerGalleryItem>,
          FutureOr<List<PerformerGalleryItem>>
        >
    with
        $FutureModifier<List<PerformerGalleryItem>>,
        $FutureProvider<List<PerformerGalleryItem>> {
  TagGalleriesProvider._({
    required TagGalleriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tagGalleriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tagGalleriesHash();

  @override
  String toString() {
    return r'tagGalleriesProvider'
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
    return tagGalleries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TagGalleriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tagGalleriesHash() => r'077d493bfe938206fa49116979a67c6370d7a96e';

final class TagGalleriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PerformerGalleryItem>>,
          String
        > {
  TagGalleriesFamily._()
    : super(
        retry: null,
        name: r'tagGalleriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TagGalleriesProvider call(String tagId) =>
      TagGalleriesProvider._(argument: tagId, from: this);

  @override
  String toString() => r'tagGalleriesProvider';
}

@ProviderFor(TagGalleriesGrid)
final tagGalleriesGridProvider = TagGalleriesGridFamily._();

final class TagGalleriesGridProvider
    extends
        $AsyncNotifierProvider<TagGalleriesGrid, List<PerformerGalleryItem>> {
  TagGalleriesGridProvider._({
    required TagGalleriesGridFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tagGalleriesGridProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tagGalleriesGridHash();

  @override
  String toString() {
    return r'tagGalleriesGridProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TagGalleriesGrid create() => TagGalleriesGrid();

  @override
  bool operator ==(Object other) {
    return other is TagGalleriesGridProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tagGalleriesGridHash() => r'4de13399f771d88ec67dec803e30d19c6bc2f091';

final class TagGalleriesGridFamily extends $Family
    with
        $ClassFamilyOverride<
          TagGalleriesGrid,
          AsyncValue<List<PerformerGalleryItem>>,
          List<PerformerGalleryItem>,
          FutureOr<List<PerformerGalleryItem>>,
          String
        > {
  TagGalleriesGridFamily._()
    : super(
        retry: null,
        name: r'tagGalleriesGridProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TagGalleriesGridProvider call(String tagId) =>
      TagGalleriesGridProvider._(argument: tagId, from: this);

  @override
  String toString() => r'tagGalleriesGridProvider';
}

abstract class _$TagGalleriesGrid
    extends $AsyncNotifier<List<PerformerGalleryItem>> {
  late final _$args = ref.$arg as String;
  String get tagId => _$args;

  FutureOr<List<PerformerGalleryItem>> build(String tagId);
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
