import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/app_lock_gate.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/app_lock_settings_provider.dart';

class TestAppLockSettingsNotifier extends AppLockSettingsNotifier {
  @override
  AppLockSettings build() {
    return const AppLockSettings(
      enabled: true,
      hasPasscode: true,
      backgroundLockSeconds: 1,
    );
  }

  @override
  Future<bool> verifyPasscode(String input) async => input == '1234';

  @override
  Future<void> setBackgroundLockSeconds(int seconds) async {
    state = state.copyWith(backgroundLockSeconds: seconds);
  }
}

void main() {
  Future<void> pumpLockedApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockSettingsProvider.overrideWith(TestAppLockSettingsNotifier.new),
        ],
        child: MaterialApp(
          builder: (context, child) => AppLockGate(child: child!),
          home: Consumer(
            builder: (context, ref, child) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => ref
                      .read(appLockSettingsProvider.notifier)
                      .setBackgroundLockSeconds(5),
                  child: const Text('Change timeout'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
  }

  testWidgets('updates lock settings without recreating AppLock state', (
    tester,
  ) async {
    await pumpLockedApp(tester);
    final firstState = tester.state<AppLockState>(find.byType(AppLock));

    await tester.tap(find.text('Change timeout'));
    await tester.pump();
    await tester.pump();

    final secondState = tester.state<AppLockState>(find.byType(AppLock));
    expect(identical(firstState, secondState), isTrue);
  });

  testWidgets('shows lock screen after background timeout', (tester) async {
    await pumpLockedApp(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump(const Duration(seconds: 2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(find.text('App Locked'), findsOneWidget);
  });
}
