import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import 'providers/connection_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  static const _preferSceneStreamsKey = 'prefer_scene_streams';
  static const _sceneGridLayoutKey = 'scene_grid_layout';

  bool _preferSceneStreams = true;
  bool _sceneGridLayout = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final url = prefs.getString('server_base_url') ?? '';
    final apiKey = prefs.getString('server_api_key') ?? '';
    final preferSceneStreams = prefs.getBool(_preferSceneStreamsKey) ?? true;
    final sceneGridLayout = prefs.getBool(_sceneGridLayoutKey) ?? false;
    _baseUrlController.text = url;
    _apiKeyController.text = apiKey;
    _preferSceneStreams = preferSceneStreams;
    _sceneGridLayout = sceneGridLayout;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final normalizedUrl = normalizeGraphqlServerUrl(_baseUrlController.text);
    if (_baseUrlController.text.trim().isNotEmpty && normalizedUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid server URL')));
      return;
    }

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('server_base_url', normalizedUrl);
    await prefs.setString('server_api_key', _apiKeyController.text.trim());
    await prefs.setBool(_preferSceneStreamsKey, _preferSceneStreams);
    await prefs.setBool(_sceneGridLayoutKey, _sceneGridLayout);

    _baseUrlController.text = normalizedUrl;

    ref.invalidate(graphqlClientProvider);
    ref.invalidate(connectionStatusProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Server settings saved')));
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Server base URL'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'https://example.com/graphql',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  const Text('API key'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Paste ApiKey header value',
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Prefer sceneStreams first'),
                    subtitle: const Text(
                      'When off, playback directly uses paths.stream',
                    ),
                    value: _preferSceneStreams,
                    onChanged: (value) {
                      setState(() => _preferSceneStreams = value);
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Scenes Grid Layout'),
                    subtitle: const Text(
                      'When on, Scenes page uses grid view by default',
                    ),
                    value: _sceneGridLayout,
                    onChanged: (value) {
                      setState(() => _sceneGridLayout = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          _baseUrlController.text = '';
                          _apiKeyController.text = '';
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
