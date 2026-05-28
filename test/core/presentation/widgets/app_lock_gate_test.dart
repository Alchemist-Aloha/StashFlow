import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

  testWidgets('does not add a nested Navigator above app content', (
    tester,
  ) async {
    await pumpLockedApp(tester);

    expect(find.byType(Navigator), findsOneWidget);
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

  testWidgets('focuses passcode field when lock screen opens', (tester) async {
    await pumpLockedApp(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump(const Duration(seconds: 2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.focusNode?.hasFocus, isTrue);
    expect(textField.autofocus, isTrue);
  });

  testWidgets('lets GoRouter handle system back before exiting app', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/details'),
              child: const Text('Home'),
            ),
          ),
        ),
        GoRoute(
          path: '/details',
          builder: (context, state) => const Scaffold(body: Text('Details')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockSettingsProvider.overrideWith(TestAppLockSettingsNotifier.new),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => AppLockGate(child: child!),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Details'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Details'), findsNothing);
  });
}
