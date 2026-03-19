import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql/client.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/theme/theme_mode_provider.dart';
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
import '../data/graphql/version.graphql.dart';
import '../../scenes/presentation/providers/video_player_provider.dart';
import '../../studios/presentation/providers/studio_details_provider.dart';
import '../../studios/presentation/providers/studio_list_provider.dart';
import '../../studios/presentation/providers/studio_media_provider.dart';
import '../../tags/presentation/providers/tag_details_provider.dart';
import '../../tags/presentation/providers/tag_list_provider.dart';
import '../../tags/presentation/providers/tag_media_provider.dart';
import 'providers/connection_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _baseUrlFocusNode = FocusNode();
  final _apiKeyFocusNode = FocusNode();
  static const _preferSceneStreamsKey = 'prefer_scene_streams';
  static const _sceneGridLayoutKey = 'scene_grid_layout';
  static const _autoplayNextKey = 'autoplay_next';
  static const _showVideoDebugInfoKey = 'show_video_debug_info';
  static const _useDoubleTapSeekKey = 'video_use_double_tap_seek';

  bool _preferSceneStreams = true;
  bool _sceneGridLayout = false;
  bool _autoplayNext = false;
  bool _showVideoDebugInfo = false;
  bool _useDoubleTapSeek = true;
  ThemeMode _themeMode = ThemeMode.system;
  bool _loading = true;

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
      } catch (_) {
        // Try http fallback.
      }
    }

    if (httpCandidate.isNotEmpty) {
      try {
        if (await _canConnect(httpCandidate, apiKey)) return httpCandidate;
      } catch (_) {
        // Both candidates failed.
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _baseUrlFocusNode.addListener(_onTextFieldFocusChanged);
    _apiKeyFocusNode.addListener(_onTextFieldFocusChanged);
    _load();
  }

  void _onTextFieldFocusChanged() {
    if (_baseUrlFocusNode.hasFocus || _apiKeyFocusNode.hasFocus) return;
    _saveServerSettings();
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final url = prefs.getString('server_base_url') ?? '';
    final apiKey = prefs.getString('server_api_key') ?? '';
    final preferSceneStreams = prefs.getBool(_preferSceneStreamsKey) ?? true;
    final sceneGridLayout = prefs.getBool(_sceneGridLayoutKey) ?? false;
    final autoplayNext = prefs.getBool(_autoplayNextKey) ?? false;
    final showVideoDebugInfo = prefs.getBool(_showVideoDebugInfoKey) ?? false;
    final useDoubleTapSeek = prefs.getBool(_useDoubleTapSeekKey) ?? true;
    final themeMode = ref.read(appThemeModeProvider);
    _baseUrlController.text = url;
    _apiKeyController.text = apiKey;
    _preferSceneStreams = preferSceneStreams;
    _sceneGridLayout = sceneGridLayout;
    _autoplayNext = autoplayNext;
    _showVideoDebugInfo = showVideoDebugInfo;
    _useDoubleTapSeek = useDoubleTapSeek;
    _themeMode = themeMode;
    setState(() => _loading = false);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await ref.read(appThemeModeProvider.notifier).setThemeMode(mode);
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

    ref.invalidate(graphqlClientProvider);
    ref.invalidate(connectionStatusProvider);

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

  Future<void> _saveToggleSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_preferSceneStreamsKey, _preferSceneStreams);
    await prefs.setBool(_sceneGridLayoutKey, _sceneGridLayout);
    await prefs.setBool(_autoplayNextKey, _autoplayNext);
    await prefs.setBool(_showVideoDebugInfoKey, _showVideoDebugInfo);
    await prefs.setBool(_useDoubleTapSeekKey, _useDoubleTapSeek);

    // Keep in-memory player state synchronized with persisted settings.
    final playerStateNotifier = ref.read(playerStateProvider.notifier);
    playerStateNotifier.setAutoplayNext(_autoplayNext);
    playerStateNotifier.setShowVideoDebugInfo(_showVideoDebugInfo);
    playerStateNotifier.setUseDoubleTapSeek(_useDoubleTapSeek);
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
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GraphQL server URL'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _baseUrlController,
                    focusNode: _baseUrlFocusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'http://192.168.1.100:9999/graphql',
                      helperText:
                          'Example format: http(s)://host:port/graphql.',
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveServerSettings(),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      _saveServerSettings();
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('API key'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    focusNode: _apiKeyFocusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Paste ApiKey header value',
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveServerSettings(),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      _saveServerSettings();
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Prefer sceneStreams first'),
                    subtitle: const Text(
                      'When off, playback directly uses paths.stream',
                    ),
                    value: _preferSceneStreams,
                    onChanged: (value) async {
                      setState(() => _preferSceneStreams = value);
                      await _saveToggleSettings();
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Scenes Grid Layout'),
                    subtitle: const Text(
                      'When on, Scenes page uses grid view by default',
                    ),
                    value: _sceneGridLayout,
                    onChanged: (value) async {
                      setState(() => _sceneGridLayout = value);
                      await _saveToggleSettings();
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Autoplay Next Scene'),
                    subtitle: const Text(
                      'Automatically play the next scene when current playback ends',
                    ),
                    value: _autoplayNext,
                    onChanged: (value) async {
                      setState(() => _autoplayNext = value);
                      await _saveToggleSettings();
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show Video Debug Info'),
                    subtitle: const Text(
                      'Display stream source and startup timing overlay on player',
                    ),
                    value: _showVideoDebugInfo,
                    onChanged: (value) async {
                      setState(() => _showVideoDebugInfo = value);
                      await _saveToggleSettings();
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Seek Interaction'),
                    subtitle: Text(
                      _useDoubleTapSeek
                          ? 'Double-tap left/right to seek 10s'
                          : 'Drag the timeline to seek',
                    ),
                    trailing: SegmentedButton<bool>(
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      segments: const [
                        ButtonSegment<bool>(
                          value: false,
                          icon: Icon(Icons.drag_indicator),
                          label: Text('Drag'),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          icon: Icon(Icons.touch_app_outlined),
                          label: Text('Double-tap'),
                        ),
                      ],
                      selected: {_useDoubleTapSeek},
                      onSelectionChanged: (selection) async {
                        setState(() => _useDoubleTapSeek = selection.first);
                        await _saveToggleSettings();
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bug_report_outlined),
                    title: const Text('Debug Log Viewer'),
                    subtitle: const Text('Open a live view of in-app logs'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/logs'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appearance',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('System'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {_themeMode},
                    onSelectionChanged: (selection) {
                      final selected = selection.first;
                      _saveThemeMode(selected);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          _baseUrlController.text = '';
                          _apiKeyController.text = '';
                          await _saveServerSettings();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Connection Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      final statusInfo = ref.watch(connectionStatusProvider);
                      return statusInfo.when(
                        data: (version) => Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Text('Connected (Stash $version)'),
                          ],
                        ),
                        loading: () => const Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Checking connection...'),
                          ],
                        ),
                        error: (error, stack) => Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Failed: $error',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
