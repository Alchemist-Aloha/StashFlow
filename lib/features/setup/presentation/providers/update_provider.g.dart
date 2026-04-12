// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the current application version.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// Returns the current application version.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Returns the current application version.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'e8bdf0eb01e50b65eb7931eadc45c32b561fce64';

@ProviderFor(AppUpdate)
final appUpdateProvider = AppUpdateProvider._();

final class AppUpdateProvider
    extends $AsyncNotifierProvider<AppUpdate, UpdateInfo?> {
  AppUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateHash();

  @$internal
  @override
  AppUpdate create() => AppUpdate();
}

String _$appUpdateHash() => r'02ea3a6842df50eb4adbb8870834a1d21e2eff7d';

abstract class _$AppUpdate extends $AsyncNotifier<UpdateInfo?> {
  FutureOr<UpdateInfo?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UpdateInfo?>, UpdateInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UpdateInfo?>, UpdateInfo?>,
              AsyncValue<UpdateInfo?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// A provider that handles the logic for the initial app update check.
/// It ensures that the update check is performed at most once per day.

@ProviderFor(StartupUpdateCheck)
final startupUpdateCheckProvider = StartupUpdateCheckProvider._();

/// A provider that handles the logic for the initial app update check.
/// It ensures that the update check is performed at most once per day.
final class StartupUpdateCheckProvider
    extends $AsyncNotifierProvider<StartupUpdateCheck, UpdateInfo?> {
  /// A provider that handles the logic for the initial app update check.
  /// It ensures that the update check is performed at most once per day.
  StartupUpdateCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupUpdateCheckProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupUpdateCheckHash();

  @$internal
  @override
  StartupUpdateCheck create() => StartupUpdateCheck();
}

String _$startupUpdateCheckHash() =>
    r'6b1fd7f6113252957ed11a76f85c64c19b584aad';

/// A provider that handles the logic for the initial app update check.
/// It ensures that the update check is performed at most once per day.

abstract class _$StartupUpdateCheck extends $AsyncNotifier<UpdateInfo?> {
  FutureOr<UpdateInfo?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UpdateInfo?>, UpdateInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UpdateInfo?>, UpdateInfo?>,
              AsyncValue<UpdateInfo?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
