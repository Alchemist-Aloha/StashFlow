import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql/client.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/theme/theme_mode_provider.dart';
import '../../../../core/presentation/theme/theme_color_provider.dart';
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
import 'providers/navigation_customization_provider.dart';

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
  static const _autoplayNextKey = 'autoplay_next';
  static const _showVideoDebugInfoKey = 'show_video_debug_info';
  static const _useDoubleTapSeekKey = 'video_use_double_tap_seek';
  static const _enableBackgroundPlaybackKey = 'video_background_playback';
  static const _enableNativePipKey = 'video_native_pip';

  static const _presetColors = [
    Color(0xFF0F766E), // Teal
    Color(0xFF2196F3), // Blue
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF4CAF50), // Green
    Color(0xFF9E9E9E), // Grey
  ];

  final _customHexController = TextEditingController();
  final _customHexFocusNode = FocusNode();
  Color _seedColor = const Color(0xFF0F766E);
  bool _preferSceneStreams = true;
  bool _sceneGridLayout = false;
  bool _sceneTiktokLayout = false;
  bool _autoplayNext = false;
  bool _showVideoDebugInfo = false;
  bool _useDoubleTapSeek = true;
  bool _enableBackgroundPlayback = false;
  bool _enableNativePip = false;
  bool _showRandomNavigation = true;
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
    _customHexFocusNode.addListener(_onTextFieldFocusChanged);
    _load();
  }

  void _onTextFieldFocusChanged() {
    if (_baseUrlFocusNode.hasFocus ||
        _apiKeyFocusNode.hasFocus ||
        _customHexFocusNode.hasFocus) {
      return;
    }
    _saveServerSettings();
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final url = prefs.getString('server_base_url') ?? '';
    final apiKey = prefs.getString('server_api_key') ?? '';
    final preferSceneStreams = prefs.getBool(_preferSceneStreamsKey) ?? true;
    final sceneGridLayout = ref.read(sceneGridLayoutProvider);
    final sceneTiktokLayout = ref.read(sceneTiktokLayoutProvider);
    final autoplayNext = prefs.getBool(_autoplayNextKey) ?? false;
    final showVideoDebugInfo = prefs.getBool(_showVideoDebugInfoKey) ?? false;
    final useDoubleTapSeek = prefs.getBool(_useDoubleTapSeekKey) ?? true;
    final enableBackgroundPlayback =
        prefs.getBool(_enableBackgroundPlaybackKey) ?? false;
    final enableNativePip = prefs.getBool(_enableNativePipKey) ?? false;
    final showRandomNavigation = ref.read(randomNavigationEnabledProvider);
    final themeMode = ref.read(appThemeModeProvider);
    final seedColor = ref.read(appThemeColorProvider);

    _baseUrlController.text = url;
    _apiKeyController.text = apiKey;
    _preferSceneStreams = preferSceneStreams;
    _sceneGridLayout = sceneGridLayout;
    _sceneTiktokLayout = sceneTiktokLayout;
    _autoplayNext = autoplayNext;
    _showVideoDebugInfo = showVideoDebugInfo;
    _useDoubleTapSeek = useDoubleTapSeek;
    _enableBackgroundPlayback = enableBackgroundPlayback;
    _enableNativePip = enableNativePip;
    _showRandomNavigation = showRandomNavigation;
    _themeMode = themeMode;
    _seedColor = seedColor;

    if (!_presetColors.contains(seedColor)) {
      _customHexController.text =
          seedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    }

    setState(() => _loading = false);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await ref.read(appThemeModeProvider.notifier).setThemeMode(mode);
  }

  Future<void> _saveThemeColor(Color color) async {
    setState(() => _seedColor = color);
    await ref.read(appThemeColorProvider.notifier).setThemeColor(color);
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

  Future<void> _saveToggleSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_preferSceneStreamsKey, _preferSceneStreams);
    await ref.read(sceneGridLayoutProvider.notifier).set(_sceneGridLayout);
    await ref.read(sceneTiktokLayoutProvider.notifier).set(_sceneTiktokLayout);
    await prefs.setBool(_autoplayNextKey, _autoplayNext);
    await prefs.setBool(_showVideoDebugInfoKey, _showVideoDebugInfo);
    await prefs.setBool(_useDoubleTapSeekKey, _useDoubleTapSeek);
    await prefs.setBool(
      _enableBackgroundPlaybackKey,
      _enableBackgroundPlayback,
    );
    await prefs.setBool(_enableNativePipKey, _enableNativePip);

    ref
        .read(randomNavigationEnabledProvider.notifier)
        .set(_showRandomNavigation);

    // Keep in-memory player state synchronized with persisted settings.
    final playerStateNotifier = ref.read(playerStateProvider.notifier);
    playerStateNotifier.setAutoplayNext(_autoplayNext);
    playerStateNotifier.setShowVideoDebugInfo(_showVideoDebugInfo);
    playerStateNotifier.setUseDoubleTapSeek(_useDoubleTapSeek);
    playerStateNotifier.setEnableBackgroundPlayback(_enableBackgroundPlayback);
    playerStateNotifier.setEnableNativePip(_enableNativePip);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _customHexController.dispose();
    _baseUrlFocusNode
      ..removeListener(_onTextFieldFocusChanged)
      ..dispose();
    _apiKeyFocusNode
      ..removeListener(_onTextFieldFocusChanged)
      ..dispose();
    _customHexFocusNode
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
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConnectionStatusCard(),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Server Configuration'),
                  const SizedBox(height: AppTheme.spacingSmall),
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
                    onSubmitted: (_) => _saveServerSettings(),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      _saveServerSettings();
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  TextField(
                    controller: _apiKeyController,
                    focusNode: _apiKeyFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'API key',
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
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _saveServerSettings(),
                        icon: const Icon(Icons.sync),
                        label: const Text('Test Connection'),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
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
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Playback'),
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
                    title: const Text('Background Playback'),
                    subtitle: const Text(
                      'Keep video audio playing when app is backgrounded',
                    ),
                    value: _enableBackgroundPlayback,
                    onChanged: (value) async {
                      setState(() => _enableBackgroundPlayback = value);
                      await _saveToggleSettings();
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Native Picture-in-Picture'),
                    subtitle: const Text(
                      'Enable Android PiP button and auto-enter on background',
                    ),
                    value: _enableNativePip,
                    onChanged: (value) async {
                      setState(() => _enableNativePip = value);
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
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Navigation'),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show Random Navigation Buttons'),
                    subtitle: const Text(
                      'Enable/disable the floating casino buttons across list and details pages',
                    ),
                    value: _showRandomNavigation,
                    onChanged: (value) async {
                      setState(() => _showRandomNavigation = value);
                      await _saveToggleSettings();
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Display'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Scenes Layout', style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Choose the default layout for the Scenes page', style: TextStyle(fontSize: 14, color: context.colors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMedium),
                        DropdownMenu<String>(
                          initialSelection: _sceneTiktokLayout
                                  ? 'tiktok'
                                  : (_sceneGridLayout ? 'grid' : 'list'),
                          onSelected: (String? value) async {
                            if (value == null) return;
                            setState(() {
                              _sceneTiktokLayout = value == 'tiktok';
                              _sceneGridLayout = value == 'grid';
                            });
                            await _saveToggleSettings();
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry<String>(
                              value: 'list',
                              label: '1 Column',
                              leadingIcon: Icon(Icons.view_list),
                            ),
                            DropdownMenuEntry<String>(
                              value: 'grid',
                              label: '2 Column',
                              leadingIcon: Icon(Icons.grid_view),
                            ),
                            DropdownMenuEntry<String>(
                              value: 'tiktok',
                              label: 'Infinite Scroll',
                              leadingIcon: Icon(Icons.swipe_up),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Appearance'),
                  const SizedBox(height: AppTheme.spacingSmall),
                  _buildColorSelector(),
                  const SizedBox(height: AppTheme.spacingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
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
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('Diagnostics'),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bug_report_outlined),
                    title: const Text('Debug Log Viewer'),
                    subtitle: const Text('Open a live view of in-app logs'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/logs'),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSectionHeader('About'),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.code),
                    title: const Text('GitHub Repository'),
                    subtitle: const Text('View source code and report issues'),
                    trailing: const Icon(Icons.open_in_new, size: 20),
                    onTap: () async {
                      final url = Uri.parse(
                        'https://github.com/Alchemist-Aloha/StashFlow',
                      );
                      try {
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open GitHub link'),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    final isCustom = !_presetColors.contains(_seedColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._presetColors.map((color) => _buildColorSwatch(color)),
              _buildColorSwatch(null), // Custom
            ],
          ),
        ),
        if (isCustom) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          TextField(
            controller: _customHexController,
            focusNode: _customHexFocusNode,
            decoration: const InputDecoration(
              labelText: 'Custom Hex Color',
              hintText: 'FF0F766E',
              prefixText: '#',
              helperText: 'Enter an 8-digit ARGB hex code',
            ),
            maxLength: 8,
            onChanged: (value) {
              if (value.length == 8) {
                final colorValue = int.tryParse(value, radix: 16);
                if (colorValue != null) {
                  _saveThemeColor(Color(colorValue));
                }
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildColorSwatch(Color? color) {
    final isSelected = color == null
        ? !_presetColors.contains(_seedColor)
        : _seedColor == color;
    final displayColor = color ?? _seedColor;

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingSmall),
      child: InkWell(
        onTap: () {
          if (color != null) {
            _saveThemeColor(color);
          } else if (!_presetColors.contains(_seedColor)) {
            // Already custom, just focus
            _customHexFocusNode.requestFocus();
          } else {
            // Switch to custom, use current as base
            _customHexController.text =
                _seedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase();
            setState(() {}); // Show text field
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: displayColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? context.colors.onSurface
                  : context.colors.outline.withValues(alpha: 0.2),
              width: isSelected ? 3 : 1,
            ),
          ),
          child: color == null && !isSelected
              ? Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color:
                      displayColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                )
              : isSelected
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: displayColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    )
                  : null,
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
                  Text(
                    'Connected (Stash $version)',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
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
                  Text('Checking connection...'),
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
