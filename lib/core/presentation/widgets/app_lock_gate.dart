import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/app_lock_settings_provider.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  Timer? _backgroundLockTimer;
  bool _locked = false;
  bool _launchLockShown = false;
  bool _lockFeatureEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundLockTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!_lockFeatureEnabled) return;

    if (state == AppLifecycleState.hidden && !_locked) {
      _backgroundLockTimer?.cancel();
      final settings = ref.read(appLockSettingsProvider);
      _backgroundLockTimer = Timer(
        Duration(seconds: settings.backgroundLockSeconds),
        _showLockScreen,
      );
    }

    if (state == AppLifecycleState.resumed) {
      _backgroundLockTimer?.cancel();
    }
  }

  bool _shouldEnable(AppLockSettings settings) {
    return settings.enabled && settings.hasPasscode;
  }

  void _showLockScreen() {
    if (!mounted || _locked) return;
    setState(() => _locked = true);
  }

  void _unlock() {
    if (!mounted) return;
    setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appLockSettingsProvider);
    final shouldEnable = _shouldEnable(settings);
    _lockFeatureEnabled = shouldEnable;

    if (!shouldEnable) {
      _backgroundLockTimer?.cancel();
      _launchLockShown = false;
      if (_locked) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _locked = false);
        });
      }
      return widget.child;
    }

    if (settings.lockOnLaunch && !_launchLockShown && !_locked) {
      _launchLockShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showLockScreen());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_locked)
          Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => _PasscodeLockScreen(onUnlocked: _unlock),
              ),
            ],
          ),
      ],
    );
  }
}

class _PasscodeLockScreen extends ConsumerStatefulWidget {
  const _PasscodeLockScreen({required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  ConsumerState<_PasscodeLockScreen> createState() =>
      _PasscodeLockScreenState();
}

class _PasscodeLockScreenState extends ConsumerState<_PasscodeLockScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusAndShowKeyboard();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!_focusNode.hasFocus) {
          _focusAndShowKeyboard();
        }
      });
    });
  }

  void _focusAndShowKeyboard() {
    if (!mounted) return;
    _focusNode.requestFocus();
    unawaited(SystemChannels.textInput.invokeMethod<void>('TextInput.show'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final ok = await ref
        .read(appLockSettingsProvider.notifier)
        .verifyPasscode(_controller.text.trim());

    if (!mounted) return;

    if (ok) {
      widget.onUnlocked();
      return;
    }

    setState(() {
      _submitting = false;
      _error = context.l10n.auth_incorrect_passcode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 44,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.auth_app_locked,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(context.l10n.auth_enter_passcode),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 8,
                      enabled: !_submitting,
                      onSubmitted: (_) => _unlock(),
                      decoration: InputDecoration(
                        labelText: context.l10n.settings_security_passcode,
                        errorText: _error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting ? null : _unlock,
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(context.l10n.auth_unlock),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
