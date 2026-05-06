import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Navigation edge cases', () {
    testWidgets(
      'deep link while app is alive does not resurrect stale route history',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => context.push('/home/scene/1'),
                    child: const Text('Open Scene 1'),
                  ),
                ),
              ),
              routes: [
                GoRoute(
                  path: 'scene/:id',
                  builder: (context, state) => Scaffold(
                    appBar: AppBar(),
                    body: Text('Scene:${state.pathParameters['id']}'),
                  ),
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Scene 1'));
        await tester.pumpAndSettle();
        expect(find.text('Scene:1'), findsOneWidget);

        // Simulate a deep link arriving while app is already running.
        router.go('/home/scene/123');
        await tester.pumpAndSettle();
        expect(find.text('Scene:123'), findsOneWidget);

        // Back should return to the home root.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Open Scene 1'), findsOneWidget);

        // Another back should not resurrect an old scene route.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Scene:1'), findsNothing);
        expect(find.text('Scene:123'), findsNothing);
      },
    );

    testWidgets('hardware back closes in-page UI before popping route', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _SearchLikePage(),
                      ),
                    );
                  },
                  child: const Text('Open Search Page'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Search Page'));
      await tester.pumpAndSettle();
      expect(find.text('Search Open'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Search Closed'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Open Search Page'), findsOneWidget);
    });

    testWidgets('nested tab stacks preserve state and reset on re-tap', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: _NestedTabsTestApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open A Detail'));
      await tester.pumpAndSettle();
      expect(find.text('Tab A Detail'), findsOneWidget);

      await tester.tap(find.text('Tab B'));
      await tester.pumpAndSettle();
      expect(find.text('Tab B Root'), findsOneWidget);

      await tester.tap(find.text('Tab A'));
      await tester.pumpAndSettle();
      expect(find.text('Tab A Detail'), findsOneWidget);

      // Re-tapping active tab resets that tab's internal stack.
      await tester.tap(find.text('Tab A'));
      await tester.pumpAndSettle();
      expect(find.text('Tab A Root'), findsOneWidget);
      expect(find.text('Tab A Detail'), findsNothing);
    });

    testWidgets('state-driven redirect is deferred post-frame safely', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const _AuthGate()),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Login Page')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('player-like route is disposed after pop transition completes', (
      tester,
    ) async {
      final disposed = ValueNotifier<bool>(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        transitionDuration: const Duration(milliseconds: 200),
                        reverseTransitionDuration:
                            const Duration(milliseconds: 200),
                        pageBuilder: (_, _, _) => _FakePlayerPage(
                          disposed: disposed,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Player'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Player'));
      await tester.pumpAndSettle();
      expect(find.text('Player Route'), findsOneWidget);
      expect(disposed.value, isFalse);

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 50));
      expect(disposed.value, isFalse);

      await tester.pumpAndSettle();
      expect(disposed.value, isTrue);
      expect(find.text('Open Player'), findsOneWidget);
    });
  });
}

class _SearchLikePage extends StatefulWidget {
  const _SearchLikePage();

  @override
  State<_SearchLikePage> createState() => _SearchLikePageState();
}

class _SearchLikePageState extends State<_SearchLikePage> {
  bool _searchOpen = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_searchOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _searchOpen) {
          setState(() {
            _searchOpen = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_searchOpen ? 'Search Open' : 'Search Closed')),
      ),
    );
  }
}

class _NestedTabsTestApp extends StatefulWidget {
  const _NestedTabsTestApp();

  @override
  State<_NestedTabsTestApp> createState() => _NestedTabsTestAppState();
}

class _NestedTabsTestAppState extends State<_NestedTabsTestApp> {
  int _currentIndex = 0;
  final _tabANavKey = GlobalKey<NavigatorState>();
  final _tabBNavKey = GlobalKey<NavigatorState>();

  void _onTabSelected(int index) {
    if (_currentIndex == index) {
      final key = index == 0 ? _tabANavKey : _tabBNavKey;
      key.currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Navigator(
            key: _tabANavKey,
            onGenerateRoute: (settings) {
              if (settings.name == '/detail') {
                return MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('Tab A Detail')),
                  ),
                );
              }
              return MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Tab A Root'),
                        ElevatedButton(
                          onPressed: () => _tabANavKey.currentState?.pushNamed(
                            '/detail',
                          ),
                          child: const Text('Open A Detail'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Navigator(
            key: _tabBNavKey,
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Tab B Root')),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Tab A'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tab B'),
        ],
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Gate')));
  }
}

class _FakePlayerPage extends StatefulWidget {
  const _FakePlayerPage({required this.disposed});

  final ValueNotifier<bool> disposed;

  @override
  State<_FakePlayerPage> createState() => _FakePlayerPageState();
}

class _FakePlayerPageState extends State<_FakePlayerPage> {
  @override
  void dispose() {
    widget.disposed.value = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: const Center(child: Text('Player Route')));
  }
}