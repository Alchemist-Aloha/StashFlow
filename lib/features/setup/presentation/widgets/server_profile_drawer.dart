import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import '../../../../core/data/auth/auth_mode.dart';
import '../../../../core/data/preferences/secure_storage_provider.dart';
import '../../domain/models/server_profile.dart';
import '../providers/connection_provider.dart';
import '../providers/server_profiles_provider.dart';

class ServerProfileDrawer extends ConsumerStatefulWidget {
  final ServerProfile? profile;

  const ServerProfileDrawer({super.key, this.profile});

  @override
  ConsumerState<ServerProfileDrawer> createState() => _ServerProfileDrawerState();
}

class _ServerProfileDrawerState extends ConsumerState<ServerProfileDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late AuthMode _authMode;
  bool _allowWebPasswordLogin = false;
  bool _isTesting = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name);
    _urlController = TextEditingController(text: widget.profile?.baseUrl);
    _apiKeyController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _authMode = widget.profile?.authMode ?? AuthMode.apiKey;
    _allowWebPasswordLogin = widget.profile?.allowWebPasswordLogin ?? false;

    if (widget.profile != null) {
      _loadCredentials();
    }
  }

  Future<void> _loadCredentials() async {
    final secureStorage = ref.read(secureStorageProvider);
    final profileId = widget.profile!.id;
    final apiKey = await secureStorage.read(key: 'profile_${profileId}_api_key');
    final username = await secureStorage.read(key: 'profile_${profileId}_username');
    final password = await secureStorage.read(key: 'profile_${profileId}_password');

    if (mounted) {
      setState(() {
        _apiKeyController.text = apiKey ?? '';
        _usernameController.text = username ?? '';
        _passwordController.text = password ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _apiKeyController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final tempProfile = ServerProfile(
        id: 'test',
        name: _nameController.text,
        baseUrl: _urlController.text,
        authMode: _authMode,
        allowWebPasswordLogin: _allowWebPasswordLogin,
      );

      // We need to temporarily set credentials for the test profile in secure storage
      // or modify connectionStatusProvider to take explicit credentials.
      // For simplicity here, we'll use a temporary profile ID and cleanup.
      final profilesNotifier = ref.read(serverProfilesProvider.notifier);
      await profilesNotifier.updateProfileCredentials(
        profileId: 'test',
        apiKey: _apiKeyController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );

      final result = await ref.refresh(connectionStatusProvider(tempProfile).future);
      setState(() {
        _testResult = result;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.profile?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final profile = ServerProfile(
      id: id,
      name: _nameController.text.isEmpty ? null : _nameController.text,
      baseUrl: _urlController.text,
      authMode: _authMode,
      allowWebPasswordLogin: _allowWebPasswordLogin,
    );

    final notifier = ref.read(serverProfilesProvider.notifier);
    if (widget.profile == null) {
      await notifier.addProfile(profile);
    } else {
      await notifier.updateProfile(profile);
    }

    await notifier.updateProfileCredentials(
      profileId: id,
      apiKey: _apiKeyController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_server_profile_delete),
        content: Text(l10n.settings_server_profile_delete_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.settings_server_profile_delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(serverProfilesProvider.notifier).removeProfile(widget.profile!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.profile == null ? l10n.settings_server_profile_add : l10n.settings_server_profile_edit,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.settings_server_profile_name,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: l10n.common_url,
                    hintText: 'http://localhost:9999/graphql',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'URL is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.settings_server_auth_method,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildAuthModeSelector(l10n),
                const SizedBox(height: 16),
                _buildAuthFields(l10n),
                const SizedBox(height: 24),
                if (_testResult != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _testResult!.startsWith('Error')
                          ? Theme.of(context).colorScheme.errorContainer
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _testResult!,
                      style: TextStyle(
                        color: _testResult!.startsWith('Error')
                            ? Theme.of(context).colorScheme.onErrorContainer
                            : Colors.green[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isTesting ? null : _testConnection,
                        icon: _isTesting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.sync),
                        label: Text(l10n.settings_server_test),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (widget.profile != null)
                      IconButton(
                        onPressed: _delete,
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        tooltip: l10n.settings_server_profile_delete,
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.common_cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(l10n.common_save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthModeSelector(AppLocalizations l10n) {
    return Column(
      children: AuthMode.values.map((mode) {
        return RadioListTile<AuthMode>(
          title: Text(_getAuthModeLabel(mode, l10n)),
          subtitle: Text(_getAuthModeDescription(mode, l10n)),
          value: mode,
          groupValue: _authMode,
          onChanged: (value) {
            if (value != null) {
              setState(() => _authMode = value);
            }
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  String _getAuthModeLabel(AuthMode mode, AppLocalizations l10n) {
    switch (mode) {
      case AuthMode.apiKey:
        return l10n.settings_server_auth_apikey;
      case AuthMode.password:
        return l10n.settings_server_auth_password;
      case AuthMode.basic:
        return l10n.settings_server_auth_basic;
      case AuthMode.bearer:
        return l10n.settings_server_auth_bearer;
    }
  }

  String _getAuthModeDescription(AuthMode mode, AppLocalizations l10n) {
    switch (mode) {
      case AuthMode.apiKey:
        return l10n.settings_server_auth_apikey_desc;
      case AuthMode.password:
        return l10n.settings_server_auth_password_desc;
      case AuthMode.basic:
        return l10n.settings_server_auth_basic_desc;
      case AuthMode.bearer:
        return l10n.settings_server_auth_bearer_desc;
    }
  }

  Widget _buildAuthFields(AppLocalizations l10n) {
    if (_authMode == AuthMode.apiKey || _authMode == AuthMode.bearer) {
      return TextFormField(
        controller: _apiKeyController,
        decoration: InputDecoration(
          labelText: _authMode == AuthMode.apiKey ? l10n.settings_server_auth_apikey : 'Token',
          border: const OutlineInputBorder(),
        ),
        obscureText: true,
      );
    } else {
      return Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: l10n.settings_server_username,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: l10n.settings_server_password,
              border: const OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      );
    }
  }
}
