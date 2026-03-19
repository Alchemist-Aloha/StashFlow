// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_media_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tagMedia)
final tagMediaProvider = TagMediaFamily._();

final class TagMediaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TagMediaItem>>,
          List<TagMediaItem>,
          FutureOr<List<TagMediaItem>>
        >
    with
        $FutureModifier<List<TagMediaItem>>,
        $FutureProvider<List<TagMediaItem>> {
  TagMediaProvider._({
    required TagMediaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tagMediaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tagMediaHash();

  @override
  String toString() {
    return r'tagMediaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TagMediaItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TagMediaItem>> create(Ref ref) {
    final argument = this.argument as String;
    return tagMedia(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TagMediaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tagMediaHash() => r'd298b1556a042539000a1ba3fec11ca271235ee6';

final class TagMediaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TagMediaItem>>, String> {
  TagMediaFamily._()
    : super(
        retry: null,
        name: r'tagMediaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TagMediaProvider call(String tagId) =>
      TagMediaProvider._(argument: tagId, from: this);

  @override
  String toString() => r'tagMediaProvider';
}

@ProviderFor(TagMediaGrid)
final tagMediaGridProvider = TagMediaGridFamily._();

final class TagMediaGridProvider
    extends $AsyncNotifierProvider<TagMediaGrid, List<TagMediaItem>> {
  TagMediaGridProvider._({
    required TagMediaGridFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tagMediaGridProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tagMediaGridHash();

  @override
  String toString() {
    return r'tagMediaGridProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TagMediaGrid create() => TagMediaGrid();

  @override
  bool operator ==(Object other) {
    return other is TagMediaGridProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tagMediaGridHash() => r'b6842288ae62e01daac1cef2044d827e137eab83';

final class TagMediaGridFamily extends $Family
    with
        $ClassFamilyOverride<
          TagMediaGrid,
          AsyncValue<List<TagMediaItem>>,
          List<TagMediaItem>,
          FutureOr<List<TagMediaItem>>,
          String
        > {
  TagMediaGridFamily._()
    : super(
        retry: null,
        name: r'tagMediaGridProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TagMediaGridProvider call(String tagId) =>
      TagMediaGridProvider._(argument: tagId, from: this);

  @override
  String toString() => r'tagMediaGridProvider';
}

abstract class _$TagMediaGrid extends $AsyncNotifier<List<TagMediaItem>> {
  late final _$args = ref.$arg as String;
  String get tagId => _$args;

  FutureOr<List<TagMediaItem>> build(String tagId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<TagMediaItem>>, List<TagMediaItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TagMediaItem>>, List<TagMediaItem>>,
              AsyncValue<List<TagMediaItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
