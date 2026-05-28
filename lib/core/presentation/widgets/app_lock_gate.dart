import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/app_lock_settings_provider.dart';

class AppLockGate extends ConsumerWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appLockSettingsProvider);

    return AppLock(
      builder: (context, launchArg) =>
          _AppLockBinding(settings: settings, child: child),
      lockScreenBuilder: (_) => const _PasscodeLockScreen(),
      initiallyEnabled: false,
      initialBackgroundLockLatency: Duration(
        seconds: settings.backgroundLockSeconds,
      ),
    );
  }
}

class _AppLockBinding extends StatefulWidget {
  const _AppLockBinding({required this.settings, required this.child});

  final AppLockSettings settings;
  final Widget child;

  @override
  State<_AppLockBinding> createState() => _AppLockBindingState();
}

class _AppLockBindingState extends State<_AppLockBinding> {
  bool _launchLockShown = false;
  bool _syncScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleLockStateSync();
  }

  @override
  void didUpdateWidget(covariant _AppLockBinding oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleLockStateSync();
  }

  void _scheduleLockStateSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;
      _syncLockState();
    });
  }

  void _syncLockState() {
    final lock = AppLock.of(context);
    if (lock == null) return;

    final shouldEnable = widget.settings.enabled && widget.settings.hasPasscode;
    lock.setEnabled(shouldEnable);
    lock.setBackgroundLockLatency(
      Duration(seconds: widget.settings.backgroundLockSeconds),
    );

    if (shouldEnable && widget.settings.lockOnLaunch && !_launchLockShown) {
      _launchLockShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppLock.of(context)?.showLockScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _PasscodeLockScreen extends ConsumerStatefulWidget {
  const _PasscodeLockScreen();

  @override
  ConsumerState<_PasscodeLockScreen> createState() =>
      _PasscodeLockScreenState();
}

class _PasscodeLockScreenState extends ConsumerState<_PasscodeLockScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
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
      AppLock.of(context)!.didUnlock();
      return;
    }

    setState(() {
      _submitting = false;
      _error = 'Incorrect passcode';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'App Locked',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Enter your passcode to continue.'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 8,
                    enabled: !_submitting,
                    onSubmitted: (_) => _unlock(),
                    decoration: InputDecoration(
                      labelText: 'Passcode',
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Unlock'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
