import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../galleries/presentation/providers/gallery_details_provider.dart';
import '../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../groups/presentation/providers/group_details_provider.dart';
import '../../groups/presentation/providers/group_list_provider.dart';
import '../../performers/presentation/providers/performer_details_provider.dart';
import '../../performers/presentation/providers/performer_list_provider.dart';
import '../../performers/presentation/providers/performer_media_provider.dart';
import '../../scenes/data/repositories/stream_resolver.dart';
import '../../scenes/presentation/providers/scene_details_provider.dart';
import '../../scenes/presentation/providers/scene_list_provider.dart';
import '../../scenes/presentation/providers/video_player_provider.dart';
import '../../studios/presentation/providers/studio_details_provider.dart';
import '../../studios/presentation/providers/studio_list_provider.dart';
import '../../studios/presentation/providers/studio_media_provider.dart';
import '../../tags/presentation/providers/tag_details_provider.dart';
import '../../tags/presentation/providers/tag_list_provider.dart';
import '../../tags/presentation/providers/tag_media_provider.dart';
import '../data/graphql/version.graphql.dart';
import '../presentation/providers/connection_provider.dart';

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
    final url = prefs.getString('server_base_url') ?? '';
    final apiKey = prefs.getString('server_api_key') ?? '';

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
    final previousUrl = prefs.getString('server_base_url')?.trim() ?? '';
    final previousApiKey = prefs.getString('server_api_key')?.trim() ?? '';
    final newApiKey = _apiKeyController.text.trim();

    await prefs.setString('server_base_url', normalizedUrl);
    await prefs.setString('server_api_key', newApiKey);

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
    return Scaffold(
      appBar: AppBar(title: const Text('Server Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConnectionStatusCard(),
                  const SizedBox(height: AppTheme.spacingLarge),
                  TextField(
                    controller: _baseUrlController,
                    focusNode: _baseUrlFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'GraphQL server URL',
                      border: OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
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
                      ElevatedButton.icon(
                        onPressed: () => _saveServerSettings(),
                        icon: const Icon(Icons.sync),
                        label: const Text('Test Connection'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          _baseUrlController.text = '';
                          _apiKeyController.text = '';
                          await _saveServerSettings();
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear Settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectionStatusCard() {
    final statusInfo = ref.watch(connectionStatusProvider);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(color: context.colors.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Status',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            statusInfo.when(
              data: (version) => Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connected (Stash $version)',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: Text('Checking connection...')),
                ],
              ),
              error: (error, stack) => Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Failed: $error',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
