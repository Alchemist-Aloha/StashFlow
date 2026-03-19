// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studio_media_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studioMedia)
final studioMediaProvider = StudioMediaFamily._();

final class StudioMediaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StudioMediaItem>>,
          List<StudioMediaItem>,
          FutureOr<List<StudioMediaItem>>
        >
    with
        $FutureModifier<List<StudioMediaItem>>,
        $FutureProvider<List<StudioMediaItem>> {
  StudioMediaProvider._({
    required StudioMediaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studioMediaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studioMediaHash();

  @override
  String toString() {
    return r'studioMediaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<StudioMediaItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StudioMediaItem>> create(Ref ref) {
    final argument = this.argument as String;
    return studioMedia(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StudioMediaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studioMediaHash() => r'9e404d06d2c77b7134659a3e522733f84753afdc';

final class StudioMediaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<StudioMediaItem>>, String> {
  StudioMediaFamily._()
    : super(
        retry: null,
        name: r'studioMediaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudioMediaProvider call(String studioId) =>
      StudioMediaProvider._(argument: studioId, from: this);

  @override
  String toString() => r'studioMediaProvider';
}

@ProviderFor(StudioMediaGrid)
final studioMediaGridProvider = StudioMediaGridFamily._();

final class StudioMediaGridProvider
    extends $AsyncNotifierProvider<StudioMediaGrid, List<StudioMediaItem>> {
  StudioMediaGridProvider._({
    required StudioMediaGridFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studioMediaGridProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studioMediaGridHash();

  @override
  String toString() {
    return r'studioMediaGridProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StudioMediaGrid create() => StudioMediaGrid();

  @override
  bool operator ==(Object other) {
    return other is StudioMediaGridProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studioMediaGridHash() => r'c8260b1c298f60402543e239f6ded25862be0ab3';

final class StudioMediaGridFamily extends $Family
    with
        $ClassFamilyOverride<
          StudioMediaGrid,
          AsyncValue<List<StudioMediaItem>>,
          List<StudioMediaItem>,
          FutureOr<List<StudioMediaItem>>,
          String
        > {
  StudioMediaGridFamily._()
    : super(
        retry: null,
        name: r'studioMediaGridProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudioMediaGridProvider call(String studioId) =>
      StudioMediaGridProvider._(argument: studioId, from: this);

  @override
  String toString() => r'studioMediaGridProvider';
}

abstract class _$StudioMediaGrid extends $AsyncNotifier<List<StudioMediaItem>> {
  late final _$args = ref.$arg as String;
  String get studioId => _$args;

  FutureOr<List<StudioMediaItem>> build(String studioId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<StudioMediaItem>>, List<StudioMediaItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<StudioMediaItem>>,
                List<StudioMediaItem>
              >,
              AsyncValue<List<StudioMediaItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
