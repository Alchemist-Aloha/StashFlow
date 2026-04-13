// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SceneRandomSeed)
final sceneRandomSeedProvider = SceneRandomSeedProvider._();

final class SceneRandomSeedProvider
    extends $NotifierProvider<SceneRandomSeed, int> {
  SceneRandomSeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sceneRandomSeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sceneRandomSeedHash();

  @$internal
  @override
  SceneRandomSeed create() => SceneRandomSeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sceneRandomSeedHash() => r'fa45f9405f200ccb9c365d233966240a7677b573';

abstract class _$SceneRandomSeed extends $Notifier<int> {
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

@ProviderFor(SceneSort)
final sceneSortProvider = SceneSortProvider._();

final class SceneSortProvider
    extends
        $NotifierProvider<
          SceneSort,
          ({bool descending, int? randomSeed, String? sort})
        > {
  SceneSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sceneSortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sceneSortHash();

  @$internal
  @override
  SceneSort create() => SceneSort();

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

String _$sceneSortHash() => r'b2290e52a1c069de9120a4bd847149b50a9caf92';

abstract class _$SceneSort
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

@ProviderFor(SceneSearchQuery)
final sceneSearchQueryProvider = SceneSearchQueryProvider._();

final class SceneSearchQueryProvider
    extends $NotifierProvider<SceneSearchQuery, String> {
  SceneSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sceneSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sceneSearchQueryHash();

  @$internal
  @override
  SceneSearchQuery create() => SceneSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$sceneSearchQueryHash() => r'df641a2bb28498b77b93c39717b4867a460def38';

abstract class _$SceneSearchQuery extends $Notifier<String> {
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

@ProviderFor(SceneFilterState)
final sceneFilterStateProvider = SceneFilterStateProvider._();

final class SceneFilterStateProvider
    extends $NotifierProvider<SceneFilterState, SceneFilter> {
  SceneFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sceneFilterStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sceneFilterStateHash();

  @$internal
  @override
  SceneFilterState create() => SceneFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SceneFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SceneFilter>(value),
    );
  }
}

String _$sceneFilterStateHash() => r'b2358b4dac7a86cff0100295bbe04de2c3f124ab';

abstract class _$SceneFilterState extends $Notifier<SceneFilter> {
  SceneFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SceneFilter, SceneFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SceneFilter, SceneFilter>,
              SceneFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SceneOrganizedOnly)
final sceneOrganizedOnlyProvider = SceneOrganizedOnlyProvider._();

final class SceneOrganizedOnlyProvider
    extends $NotifierProvider<SceneOrganizedOnly, bool> {
  SceneOrganizedOnlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sceneOrganizedOnlyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sceneOrganizedOnlyHash();

  @$internal
  @override
  SceneOrganizedOnly create() => SceneOrganizedOnly();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$sceneOrganizedOnlyHash() =>
    r'ee6114f968d38f4e8cee57513faa9400ff3b0a22';

abstract class _$SceneOrganizedOnly extends $Notifier<bool> {
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

@ProviderFor(SceneTiktokLayout)
final sceneTiktokLayoutProvider = SceneTiktokLayoutProvider._();

final class SceneTiktokLayoutProvider
    extends $NotifierProvider<SceneTiktokLayout, bool> {
  SceneTiktokLayoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sceneTiktokLayoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sceneTiktokLayoutHash();

  @$internal
  @override
  SceneTiktokLayout create() => SceneTiktokLayout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$sceneTiktokLayoutHash() => r'4d864f786cd9949595cf38655cfa7e291c2d0b19';

abstract class _$SceneTiktokLayout extends $Notifier<bool> {
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

@ProviderFor(SceneGridLayout)
final sceneGridLayoutProvider = SceneGridLayoutProvider._();

final class SceneGridLayoutProvider
    extends $NotifierProvider<SceneGridLayout, bool> {
  SceneGridLayoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sceneGridLayoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sceneGridLayoutHash();

  @$internal
  @override
  SceneGridLayout create() => SceneGridLayout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$sceneGridLayoutHash() => r'5d8ef03c750e04f134df37d1bf4f3ae2eefb2bc2';

abstract class _$SceneGridLayout extends $Notifier<bool> {
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

/// A notifier that manages the primary list of scenes with support for
/// filtering, sorting, and infinite pagination.
///
/// This provider is responsible for:
/// - Initializing and refreshing the scene list from the [SceneRepository].
/// - Managing the current page state and loading more scenes as the user scrolls.
/// - Providing search and filtering capabilities.
/// - Synchronizing the initial playback sequence with the [playbackQueueProvider].

@ProviderFor(SceneList)
final sceneListProvider = SceneListProvider._();

/// A notifier that manages the primary list of scenes with support for
/// filtering, sorting, and infinite pagination.
///
/// This provider is responsible for:
/// - Initializing and refreshing the scene list from the [SceneRepository].
/// - Managing the current page state and loading more scenes as the user scrolls.
/// - Providing search and filtering capabilities.
/// - Synchronizing the initial playback sequence with the [playbackQueueProvider].
final class SceneListProvider
    extends $AsyncNotifierProvider<SceneList, List<Scene>> {
  /// A notifier that manages the primary list of scenes with support for
  /// filtering, sorting, and infinite pagination.
  ///
  /// This provider is responsible for:
  /// - Initializing and refreshing the scene list from the [SceneRepository].
  /// - Managing the current page state and loading more scenes as the user scrolls.
  /// - Providing search and filtering capabilities.
  /// - Synchronizing the initial playback sequence with the [playbackQueueProvider].
  SceneListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sceneListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sceneListHash();

  @$internal
  @override
  SceneList create() => SceneList();
}

String _$sceneListHash() => r'24123d91c23e248585a9c0904ef842b7afdc81e8';

/// A notifier that manages the primary list of scenes with support for
/// filtering, sorting, and infinite pagination.
///
/// This provider is responsible for:
/// - Initializing and refreshing the scene list from the [SceneRepository].
/// - Managing the current page state and loading more scenes as the user scrolls.
/// - Providing search and filtering capabilities.
/// - Synchronizing the initial playback sequence with the [playbackQueueProvider].

abstract class _$SceneList extends $AsyncNotifier<List<Scene>> {
  FutureOr<List<Scene>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Scene>>, List<Scene>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Scene>>, List<Scene>>,
              AsyncValue<List<Scene>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
