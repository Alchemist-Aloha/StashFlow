// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graphql_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A trigger to notify listeners when [SharedPreferences] settings are manually updated.

@ProviderFor(SharedPreferencesTrigger)
final sharedPreferencesTriggerProvider = SharedPreferencesTriggerProvider._();

/// A trigger to notify listeners when [SharedPreferences] settings are manually updated.
final class SharedPreferencesTriggerProvider
    extends $NotifierProvider<SharedPreferencesTrigger, int> {
  /// A trigger to notify listeners when [SharedPreferences] settings are manually updated.
  SharedPreferencesTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesTriggerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesTriggerHash();

  @$internal
  @override
  SharedPreferencesTrigger create() => SharedPreferencesTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sharedPreferencesTriggerHash() =>
    r'c70cbe660d5fac8026347daace3a579c5c5092b2';

/// A trigger to notify listeners when [SharedPreferences] settings are manually updated.

abstract class _$SharedPreferencesTrigger extends $Notifier<int> {
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

/// Provider for the normalized Stash server URL.

@ProviderFor(serverUrl)
final serverUrlProvider = ServerUrlProvider._();

/// Provider for the normalized Stash server URL.

final class ServerUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider for the normalized Stash server URL.
  ServerUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return serverUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$serverUrlHash() => r'a5b703d1d7a5ed8a0c2bdf6683545bd3fa9b607a';

/// Provider for the Stash server API Key.

@ProviderFor(serverApiKey)
final serverApiKeyProvider = ServerApiKeyProvider._();

/// Provider for the Stash server API Key.

final class ServerApiKeyProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider for the Stash server API Key.
  ServerApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverApiKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverApiKeyHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return serverApiKey(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$serverApiKeyHash() => r'a7caa4f8a9dc8726451b81345aadcf92f96a60fa';

/// A centralized [GraphQLClient] provider for all feature repositories.
///
/// This client is automatically re-initialized whenever [serverUrl]
/// or [serverApiKey] changes. It handles the [HttpLink] setup with the
/// correct `ApiKey` header required by Stash.

@ProviderFor(graphqlClient)
final graphqlClientProvider = GraphqlClientProvider._();

/// A centralized [GraphQLClient] provider for all feature repositories.
///
/// This client is automatically re-initialized whenever [serverUrl]
/// or [serverApiKey] changes. It handles the [HttpLink] setup with the
/// correct `ApiKey` header required by Stash.

final class GraphqlClientProvider
    extends $FunctionalProvider<GraphQLClient, GraphQLClient, GraphQLClient>
    with $Provider<GraphQLClient> {
  /// A centralized [GraphQLClient] provider for all feature repositories.
  ///
  /// This client is automatically re-initialized whenever [serverUrl]
  /// or [serverApiKey] changes. It handles the [HttpLink] setup with the
  /// correct `ApiKey` header required by Stash.
  GraphqlClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'graphqlClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$graphqlClientHash();

  @$internal
  @override
  $ProviderElement<GraphQLClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GraphQLClient create(Ref ref) {
    return graphqlClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GraphQLClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GraphQLClient>(value),
    );
  }
}

String _$graphqlClientHash() => r'4cb3599e6e01ec54c2df271358c0e1d1bb2a62a3';
