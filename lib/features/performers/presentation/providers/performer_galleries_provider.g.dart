// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performer_galleries_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(performerGalleries)
final performerGalleriesProvider = PerformerGalleriesFamily._();

final class PerformerGalleriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PerformerGalleryItem>>,
          List<PerformerGalleryItem>,
          FutureOr<List<PerformerGalleryItem>>
        >
    with
        $FutureModifier<List<PerformerGalleryItem>>,
        $FutureProvider<List<PerformerGalleryItem>> {
  PerformerGalleriesProvider._({
    required PerformerGalleriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'performerGalleriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$performerGalleriesHash();

  @override
  String toString() {
    return r'performerGalleriesProvider'
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
    return performerGalleries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PerformerGalleriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$performerGalleriesHash() =>
    r'9fe998a2d3f1daee48f80bc422f1f5840fcf8ca2';

final class PerformerGalleriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PerformerGalleryItem>>,
          String
        > {
  PerformerGalleriesFamily._()
    : super(
        retry: null,
        name: r'performerGalleriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PerformerGalleriesProvider call(String performerId) =>
      PerformerGalleriesProvider._(argument: performerId, from: this);

  @override
  String toString() => r'performerGalleriesProvider';
}

@ProviderFor(PerformerGalleriesGrid)
final performerGalleriesGridProvider = PerformerGalleriesGridFamily._();

final class PerformerGalleriesGridProvider
    extends
        $AsyncNotifierProvider<
          PerformerGalleriesGrid,
          List<PerformerGalleryItem>
        > {
  PerformerGalleriesGridProvider._({
    required PerformerGalleriesGridFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'performerGalleriesGridProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$performerGalleriesGridHash();

  @override
  String toString() {
    return r'performerGalleriesGridProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PerformerGalleriesGrid create() => PerformerGalleriesGrid();

  @override
  bool operator ==(Object other) {
    return other is PerformerGalleriesGridProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$performerGalleriesGridHash() =>
    r'bb68ade32708f2a471a82433997ad3aa7dc01a39';

final class PerformerGalleriesGridFamily extends $Family
    with
        $ClassFamilyOverride<
          PerformerGalleriesGrid,
          AsyncValue<List<PerformerGalleryItem>>,
          List<PerformerGalleryItem>,
          FutureOr<List<PerformerGalleryItem>>,
          String
        > {
  PerformerGalleriesGridFamily._()
    : super(
        retry: null,
        name: r'performerGalleriesGridProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PerformerGalleriesGridProvider call(String performerId) =>
      PerformerGalleriesGridProvider._(argument: performerId, from: this);

  @override
  String toString() => r'performerGalleriesGridProvider';
}

abstract class _$PerformerGalleriesGrid
    extends $AsyncNotifier<List<PerformerGalleryItem>> {
  late final _$args = ref.$arg as String;
  String get performerId => _$args;

  FutureOr<List<PerformerGalleryItem>> build(String performerId);
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
