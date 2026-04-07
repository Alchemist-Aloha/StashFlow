import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/secure_storage_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_details_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_details_provider.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_details_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_media_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_details_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_details_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_list_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_media_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_details_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_list_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_media_provider.dart';
import 'package:stash_app_flutter/features/setup/data/graphql/version.graphql.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/connection_provider.dart';
import '../../widgets/settings_page_shell.dart';

class ServerSettingsPage extends ConsumerStatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  ConsumerState<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends ConsumerState<ServerSettingsPage> {
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _baseUrlFocusNode = FocusNode();
  final _apiKeyFocusNode = FocusNode();
  bool _loading = true;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _baseUrlFocusNode.addListener(_onTextFieldFocusChanged);
    _apiKeyFocusNode.addListener(_onTextFieldFocusChanged);
    _load();
  }

  void _onTextFieldFocusChanged() {
    if (_baseUrlFocusNode.hasFocus || _apiKeyFocusNode.hasFocus) {
      return;
    }
    _saveServerSettings();
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final secureStorage = ref.read(secureStorageProvider);
    final url = prefs.getString('server_base_url') ?? '';
    final apiKey = await secureStorage.read(key: 'server_api_key') ?? '';

    _baseUrlController.text = url;
    _apiKeyController.text = apiKey;

    setState(() => _loading = false);
  }

  bool _isHostOnlyInput(String raw) {
    final parsed = Uri.tryParse(raw.trim());
    if (parsed == null) return false;
    return !parsed.hasScheme && parsed.host.isNotEmpty;
  }

  Future<bool> _canConnect(String endpointUrl, String apiKey) async {
    final testClient = GraphQLClient(
      link: HttpLink(endpointUrl, defaultHeaders: {'ApiKey': apiKey}),
      cache: GraphQLCache(store: InMemoryStore()),
    );

    final result = await testClient
        .query$GetVersion(
          Options$Query$GetVersion(fetchPolicy: FetchPolicy.networkOnly),
        )
        .timeout(const Duration(seconds: 4));

    return !result.hasException;
  }

  Future<String?> _resolveHostOnlyEndpoint(String hostOnlyInput) async {
    final apiKey = _apiKeyController.text.trim();
    final httpsCandidate = normalizeGraphqlServerUrl('https://$hostOnlyInput');
    final httpCandidate = normalizeGraphqlServerUrl('http://$hostOnlyInput');

    if (httpsCandidate.isNotEmpty) {
      try {
        if (await _canConnect(httpsCandidate, apiKey)) return httpsCandidate;
      } catch (_) {}
    }

    if (httpCandidate.isNotEmpty) {
      try {
        if (await _canConnect(httpCandidate, apiKey)) return httpCandidate;
      } catch (_) {}
    }

    return null;
  }

  Future<void> _saveServerSettings() async {
    final rawUrl = _baseUrlController.text.trim();
    String normalizedUrl = normalizeGraphqlServerUrl(rawUrl);

    if (_isHostOnlyInput(rawUrl)) {
      final resolved = await _resolveHostOnlyEndpoint(rawUrl);
      if (resolved == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not connect using https:// or http://. Check host, port, and API key.',
            ),
          ),
        );
        return;
      }
      normalizedUrl = resolved;
    }

    if (_baseUrlController.text.trim().isNotEmpty && normalizedUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid server URL')));
      return;
    }

    final prefs = ref.read(sharedPreferencesProvider);
    final secureStorage = ref.read(secureStorageProvider);
    final previousUrl = prefs.getString('server_base_url')?.trim() ?? '';
    final previousApiKey =
        await secureStorage.read(key: 'server_api_key') ?? '';
    final newApiKey = _apiKeyController.text.trim();

    await prefs.setString('server_base_url', normalizedUrl);
    if (newApiKey.isEmpty) {
      await secureStorage.delete(key: 'server_api_key');
    } else {
      await secureStorage.write(key: 'server_api_key', value: newApiKey);
    }
    ref.read(serverApiKeyInternalProvider.notifier).update(newApiKey);

    ref.read(sharedPreferencesTriggerProvider.notifier).trigger();

    _baseUrlController.text = normalizedUrl;

    final endpointChanged =
        previousUrl != normalizedUrl || previousApiKey != newApiKey;
    if (endpointChanged) {
      await _flushRuntimeCachesAfterServerChange();
    } else {
      ref.invalidate(connectionStatusProvider);
    }
  }

  Future<void> _flushRuntimeCachesAfterServerChange() async {
    final currentClient = ref.read(graphqlClientProvider);
    currentClient.cache.store.reset();

    ref.read(playerStateProvider.notifier).stop();

    ref.invalidate(serverUrlProvider);
    ref.invalidate(serverApiKeyProvider);
    ref.invalidate(graphqlClientProvider);
    ref.invalidate(connectionStatusProvider);
    ref.invalidate(mediaHeadersProvider);

    ref.invalidate(sceneListProvider);
    ref.invalidate(sceneDetailsProvider);
    ref.invalidate(streamResolverProvider);

    ref.invalidate(performerListProvider);
    ref.invalidate(performerDetailsProvider);
    ref.invalidate(performerMediaProvider);
    ref.invalidate(performerMediaGridProvider);

    ref.invalidate(studioListProvider);
    ref.invalidate(studioDetailsProvider);
    ref.invalidate(studioMediaProvider);
    ref.invalidate(studioMediaGridProvider);

    ref.invalidate(tagListProvider);
    ref.invalidate(tagDetailsProvider);
    ref.invalidate(tagMediaProvider);
    ref.invalidate(tagMediaGridProvider);

    ref.invalidate(galleryListProvider);
    ref.invalidate(galleryDetailsProvider);
    ref.invalidate(groupListProvider);
    ref.invalidate(groupDetailsProvider);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _baseUrlFocusNode
      ..removeListener(_onTextFieldFocusChanged)
      ..dispose();
    _apiKeyFocusNode
      ..removeListener(_onTextFieldFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageShell(
      title: 'Server Settings',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsSectionCard(
                    title: 'Connection Status',
                    subtitle: 'Live connectivity against the configured server',
                    child: _buildConnectionStatusBody(),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: 'Server Details',
                    subtitle: 'URL and API key used by the GraphQL client',
                    child: Column(
                      children: [
                        TextField(
                          controller: _baseUrlController,
                          focusNode: _baseUrlFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'GraphQL server URL',
                            hintText: 'http://192.168.1.100:9999/graphql',
                            helperText:
                                'Example format: http(s)://host:port/graphql.',
                          ),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                            _saveServerSettings();
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        TextField(
                          controller: _apiKeyController,
                          focusNode: _apiKeyFocusNode,
                          decoration: InputDecoration(
                            labelText: 'API key',
                            hintText: 'Paste ApiKey header value',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureApiKey
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureApiKey = !_obscureApiKey;
                                });
                              },
                            ),
                          ),
                          autocorrect: false,
                          enableSuggestions: false,
                          obscureText: _obscureApiKey,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                            _saveServerSettings();
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        Wrap(
                          spacing: AppTheme.spacingSmall,
                          runSpacing: AppTheme.spacingSmall,
                          children: [
                            FilledButton.icon(
                              onPressed: _saveServerSettings,
                              icon: const Icon(Icons.sync_rounded),
                              label: const Text('Test Connection'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                _baseUrlController.text = '';
                                _apiKeyController.text = '';
                                await _saveServerSettings();
                              },
                              icon: const Icon(Icons.clear_all_rounded),
                              label: const Text('Clear Settings'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectionStatusBody() {
    final statusInfo = ref.watch(connectionStatusProvider);
    return statusInfo.when(
      data: (version) => Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Connected (Stash $version)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      loading: () => const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(child: Text('Checking connection...')),
        ],
      ),
      error: (error, stack) => Row(
        children: [
          Icon(Icons.error_rounded, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed: $error',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
