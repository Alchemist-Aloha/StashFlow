// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrape_customization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScrapeEnabled)
final scrapeEnabledProvider = ScrapeEnabledProvider._();

final class ScrapeEnabledProvider
    extends $NotifierProvider<ScrapeEnabled, bool> {
  ScrapeEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scrapeEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scrapeEnabledHash();

  @$internal
  @override
  ScrapeEnabled create() => ScrapeEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$scrapeEnabledHash() => r'4cbe246ea73d51592ac5ffa85fd089f725bffb9b';

abstract class _$ScrapeEnabled extends $Notifier<bool> {
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
