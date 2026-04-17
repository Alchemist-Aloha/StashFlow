import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
import 'package:stash_app_flutter/core/data/auth/auth_provider.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/secure_storage_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
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
import 'package:stash_app_flutter/features/setup/data/graphql/version.graphql.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/connection_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_details_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_list_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_media_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_details_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_list_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_media_provider.dart';

import '../../widgets/settings_page_shell.dart';

class ServerSettingsPage extends ConsumerStatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  ConsumerState<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends ConsumerState<ServerSettingsPage> {
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _baseUrlFocusNode = FocusNode();
  final _apiKeyFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _loading = true;
  bool _isSaving = false;
  bool _obscureApiKey = true;
  bool _obscurePassword = true;
  bool _allowWebPasswordLogin = false;
  AuthMode _selectedAuthMode = AuthMode.password;

  @override
  void initState() {
    super.initState();
    _baseUrlFocusNode.addListener(_onTextFieldFocusChanged);
    _apiKeyFocusNode.addListener(_onTextFieldFocusChanged);
    _usernameFocusNode.addListener(_onTextFieldFocusChanged);
    _passwordFocusNode.addListener(_onTextFieldFocusChanged);
    _load();
  }

  void _onTextFieldFocusChanged() {
    if (_baseUrlFocusNode.hasFocus ||
        _apiKeyFocusNode.hasFocus ||
        _usernameFocusNode.hasFocus ||
        _passwordFocusNode.hasFocus) {
      return;
    }
    _saveServerSettings();
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final secureStorage = ref.read(secureStorageProvider);

    final url = prefs.getString('server_base_url') ?? '';
    final apiKey = await secureStorage.read(key: 'server_api_key') ?? '';
    final username = await secureStorage.read(key: 'server_username') ?? '';
    final password = await secureStorage.read(key: 'server_password') ?? '';
    final modeRaw = prefs.getString('auth_mode') ?? AuthMode.password.name;

    _allowWebPasswordLogin = prefs.getBool('allow_web_password_login') ?? false;

    _baseUrlController.text = url;
    _apiKeyController.text = apiKey;
    _usernameController.text = username;
    _passwordController.text = password;

    final canUsePassword = !kIsWeb || _allowWebPasswordLogin;
    _selectedAuthMode = modeRaw == AuthMode.password.name && canUsePassword
        ? AuthMode.password
        : AuthMode.apiKey;

    setState(() => _loading = false);
  }

  bool _isHostOnlyInput(String raw) {
    final parsed = Uri.tryParse(raw.trim());
    if (parsed == null) return false;
    return !parsed.hasScheme && parsed.host.isNotEmpty;
  }

  Future<bool> _canConnect(
    String endpointUrl, {
    required Map<String, String> headers,
  }) async {
    final testClient = GraphQLClient(
      link: HttpLink(endpointUrl, defaultHeaders: headers),
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
    final httpsCandidate = normalizeGraphqlServerUrl('https://$hostOnlyInput');
    final httpCandidate = normalizeGraphqlServerUrl('http://$hostOnlyInput');

    if (_selectedAuthMode == AuthMode.password) {
      final authState = ref.read(authProvider);
      if (authState.cookieHeader.isNotEmpty) {
        final cookieHeaders = <String, String>{
          'Cookie': authState.cookieHeader,
        };

        if (httpsCandidate.isNotEmpty) {
          try {
            if (await _canConnect(httpsCandidate, headers: cookieHeaders)) {
              return httpsCandidate;
            }
          } catch (_) {}
        }

        if (httpCandidate.isNotEmpty) {
          try {
            if (await _canConnect(httpCandidate, headers: cookieHeaders)) {
              return httpCandidate;
            }
          } catch (_) {}
        }
      }

      if (httpsCandidate.isNotEmpty) {
        return httpsCandidate;
      }
      return httpCandidate.isNotEmpty ? httpCandidate : null;
    }

    final apiKey = _apiKeyController.text.trim();
    final headers = apiKey.isEmpty
        ? const <String, String>{}
        : <String, String>{'ApiKey': apiKey};

    if (httpsCandidate.isNotEmpty) {
      try {
        if (await _canConnect(httpsCandidate, headers: headers)) {
          return httpsCandidate;
        }
      } catch (_) {}
    }

    if (httpCandidate.isNotEmpty) {
      try {
        if (await _canConnect(httpCandidate, headers: headers)) {
          return httpCandidate;
        }
      } catch (_) {}
    }

    return null;
  }

  Future<void> _saveServerSettings({bool attemptPasswordLogin = false}) async {
    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);

    try {
      final rawUrl = _baseUrlController.text.trim();
      String normalizedUrl = normalizeGraphqlServerUrl(rawUrl);

      if (_isHostOnlyInput(rawUrl)) {
        final resolved = await _resolveHostOnlyEndpoint(rawUrl);
        if (resolved == null) {
          if (!mounted) return;
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.settings_server_resolve_error),
            ),
          );
          return;
        }
        normalizedUrl = resolved;
      }

      if (_baseUrlController.text.trim().isNotEmpty && normalizedUrl.isEmpty) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settings_server_invalid_url)));
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

      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.setMode(_selectedAuthMode);
      await authNotifier.updateUsername(_usernameController.text);
      await authNotifier.updatePassword(_passwordController.text);

      if (_selectedAuthMode == AuthMode.password && attemptPasswordLogin) {
        final loggedIn = await authNotifier.login();
        if (!loggedIn && mounted) {
          final l10n = AppLocalizations.of(context)!;
          final error = ref.read(authProvider).errorMessage ?? l10n.settings_server_login_failed;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      }

      ref.read(sharedPreferencesTriggerProvider.notifier).trigger();

      _baseUrlController.text = normalizedUrl;

      final endpointChanged =
          previousUrl != normalizedUrl || previousApiKey != newApiKey;
      if (endpointChanged) {
        await _flushRuntimeCachesAfterServerChange();
      } else {
        ref.invalidate(connectionStatusProvider);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
    ref.invalidate(mediaPlaybackHeadersProvider);

    await ref.read(authProvider.notifier).refreshCookieHeader();

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
    _usernameController.dispose();
    _passwordController.dispose();

    _baseUrlFocusNode
      ..removeListener(_onTextFieldFocusChanged)
      ..dispose();
    _apiKeyFocusNode
      ..removeListener(_onTextFieldFocusChanged)
      ..dispose();
    _usernameFocusNode
      ..removeListener(_onTextFieldFocusChanged)
      ..dispose();
    _passwordFocusNode
      ..removeListener(_onTextFieldFocusChanged)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final l10n = AppLocalizations.of(context)!;

    return SettingsPageShell(
      title: '${l10n.settings_server} ${l10n.settings_title}',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsSectionCard(
                    title: l10n.settings_server_status,
                    subtitle: l10n.settings_server_status_subtitle,
                    child: _buildConnectionStatusBody(),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: l10n.settings_server_details,
                    subtitle: l10n.settings_server_details_subtitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _baseUrlController,
                          focusNode: _baseUrlFocusNode,
                          decoration: InputDecoration(
                            labelText: l10n.settings_server_url,
                              hintText: l10n.settings_server_url_example,
                              helperText: l10n.settings_server_url_helper,
                          ),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                            _saveServerSettings();
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        Text(
                          l10n.settings_server_auth_method,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        SegmentedButton<AuthMode>(
                          segments: [
                            ButtonSegment<AuthMode>(
                              value: AuthMode.apiKey,
                              label: Text(l10n.settings_server_auth_apikey),
                              icon: const Icon(Icons.vpn_key_rounded),
                            ),
                            if (!kIsWeb || _allowWebPasswordLogin)
                              ButtonSegment<AuthMode>(
                                value: AuthMode.password,
                                label: Text(l10n.settings_server_auth_password),
                                icon: const Icon(Icons.password_rounded),
                              ),
                          ],
                          selected: <AuthMode>{_selectedAuthMode},
                          onSelectionChanged: (selection) async {
                            final selected = selection.first;
                            setState(() => _selectedAuthMode = selected);
                            await _saveServerSettings();
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          _selectedAuthMode == AuthMode.password
                              ? l10n.settings_server_auth_password_desc
                              : l10n.settings_server_auth_apikey_desc,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        if (_selectedAuthMode == AuthMode.apiKey)
                          TextField(
                            controller: _apiKeyController,
                            focusNode: _apiKeyFocusNode,
                            decoration: InputDecoration(
                              labelText: l10n.settings_server_auth_apikey,
                              hintText: l10n.settings_server_auth_apikey_desc,
                              suffixIcon: IconButton(
                                tooltip: _obscureApiKey
                                    ? l10n.common_show
                                    : l10n.common_hide,
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
                        if (_selectedAuthMode == AuthMode.password) ...[
                          TextField(
                            controller: _usernameController,
                            focusNode: _usernameFocusNode,
                            decoration: InputDecoration(
                              labelText: l10n.settings_server_username,
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          TextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            decoration: InputDecoration(
                              labelText: l10n.settings_server_password,
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? l10n.common_show
                                    : l10n.common_hide,
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                              _saveServerSettings();
                            },
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
                          Text(
                            _buildAuthStatusLabel(authState),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacingMedium),
                        Wrap(
                          spacing: AppTheme.spacingSmall,
                          runSpacing: AppTheme.spacingSmall,
                          children: [
                            FilledButton.icon(
                              onPressed: _isSaving
                                  ? null
                                  : () async {
                                      await _saveServerSettings(
                                        attemptPasswordLogin:
                                            _selectedAuthMode ==
                                            AuthMode.password,
                                      );
                                    },
                              icon: const Icon(Icons.sync_rounded),
                              label: Text(
                                _selectedAuthMode == AuthMode.password
                                    ? l10n.settings_server_login_test
                                    : l10n.settings_server_test,
                              ),
                            ),
                            if (_selectedAuthMode == AuthMode.password)
                              OutlinedButton.icon(
                                onPressed: _isSaving
                                    ? null
                                    : () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        await ref
                                            .read(authProvider.notifier)
                                            .logout();
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.settings_server_logout_confirm,
                                            ),
                                          ),
                                        );
                                        ref.invalidate(
                                          connectionStatusProvider,
                                        );
                                      },
                                icon: const Icon(Icons.logout_rounded),
                                label: Text(l10n.settings_server_logout),
                              ),
                            OutlinedButton.icon(
                              onPressed: _isSaving
                                  ? null
                                  : () async {
                                      _baseUrlController.text = '';
                                      _apiKeyController.text = '';
                                      _usernameController.text = '';
                                      _passwordController.text = '';
                                      await ref
                                          .read(authProvider.notifier)
                                          .logout();
                                      await _saveServerSettings();
                                    },
                              icon: const Icon(Icons.clear_all_rounded),
                              label: Text(l10n.settings_server_clear),
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

  String _buildAuthStatusLabel(AuthState authState) {
    final l10n = AppLocalizations.of(context)!;
    switch (authState.loginStatus) {
      case AuthLoginStatus.loggingIn:
        return l10n.settings_server_auth_status_logging_in;
      case AuthLoginStatus.loggedIn:
        return l10n.settings_server_auth_status_logged_in;
      case AuthLoginStatus.error:
        return l10n.settings_server_failed(authState.errorMessage ?? 'error');
      case AuthLoginStatus.loggedOut:
        return l10n.settings_server_auth_status_logged_out;
    }
  }

  Widget _buildConnectionStatusBody() {
    final statusInfo = ref.watch(connectionStatusProvider);
    final l10n = AppLocalizations.of(context)!;
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
              l10n.settings_server_connected(version),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      loading: () => Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(l10n.settings_server_checking)),
        ],
      ),
      error: (error, stack) => Row(
        children: [
          Icon(Icons.error_rounded, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.settings_server_failed(error.toString()),
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
