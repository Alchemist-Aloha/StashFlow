// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_customization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RandomNavigationEnabled)
final randomNavigationEnabledProvider = RandomNavigationEnabledProvider._();

final class RandomNavigationEnabledProvider
    extends $NotifierProvider<RandomNavigationEnabled, bool> {
  RandomNavigationEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'randomNavigationEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$randomNavigationEnabledHash();

  @$internal
  @override
  RandomNavigationEnabled create() => RandomNavigationEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$randomNavigationEnabledHash() =>
    r'd3c1fbef5a696d99bd1bdc6f6737c8df853faf49';

abstract class _$RandomNavigationEnabled extends $Notifier<bool> {
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
