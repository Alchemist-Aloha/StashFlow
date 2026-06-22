import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/list_page_scaffold.dart';
import 'package:stash_app_flutter/core/presentation/widgets/error_state_view.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ListPageScaffold', () {
    test('guards post-frame measurement callbacks after dispose', () {
      final source = File(
        'lib/core/presentation/widgets/list_page_scaffold.dart',
      ).readAsStringSync();

      expect(
        source,
        isNot(
          contains(
            'addPostFrameCallback((_) {\n'
            '      _pageSizeReportScheduled = false;\n'
            '      if (!mounted) return;',
          ),
        ),
      );
      expect(
        source,
        isNot(
          contains(
            'addPostFrameCallback((_) {\n'
            '                                                  if (_measuredItemExtent',
          ),
        ),
      );
      expect(
        source,
        isNot(
          contains(
            'addPostFrameCallback((_) {\n'
            '                                                if (_measuredItemExtent',
          ),
        ),
      );
      expect(
        source,
        isNot(
          contains(
            'addPostFrameCallback((_) {\n'
            '                                            if (_measuredItemExtent',
          ),
        ),
      );
    });

    testWidgets('shows loading state correctly', (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Test Title',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: const AsyncValue.loading(),
          itemBuilder: (context, item, mw, mh) => Text(item),
        ),
      );
      await tester.pump();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(SceneCard), findsWidgets);
    });

    testWidgets('shows empty state correctly', (WidgetTester tester) async {
      const emptyMessage = 'Nothing here';
      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Test Title',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: const AsyncValue.data([]),
          emptyMessage: emptyMessage,
          itemBuilder: (context, item, mw, mh) => Text(item),
        ),
      );
      await tester.pump();

      expect(find.text(emptyMessage), findsOneWidget);
    });

    testWidgets('shows error state correctly', (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Test Title',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: AsyncValue.error('An error occurred', StackTrace.empty),
          itemBuilder: (context, item, mw, mh) => Text(item),
        ),
      );
      await tester.pump();

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.textContaining('An error occurred'), findsOneWidget);
    });

    testWidgets('shows list view when gridDelegate is null', (
      WidgetTester tester,
    ) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];
      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Test Title',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: AsyncValue.data(items),
          itemBuilder: (context, item, mw, mh) => ListTile(title: Text(item)),
        ),
      );
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      for (final item in items) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets('uses always-scrollable physics when refresh is available', (
      WidgetTester tester,
    ) async {
      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Test Title',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: const AsyncValue.data(['Item 1']),
          onRefresh: () async {},
          itemBuilder: (context, item, mw, mh) => ListTile(title: Text(item)),
        ),
      );
      await tester.pump();

      expect(
        tester.widget<ListView>(find.byType(ListView)).physics,
        isA<AlwaysScrollableScrollPhysics>(),
      );
    });

    testWidgets('shows grid view when gridDelegate is provided', (
      WidgetTester tester,
    ) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];
      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Test Title',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: AsyncValue.data(items),
          useResponsiveGrid: false,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, item, mw, mh) => GridTile(child: Text(item)),
        ),
      );
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
      for (final item in items) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets(
      'uses two viewports of cache and grid density controls cached item count',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 600));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final items = List<String>.generate(100, (index) => 'Item $index');

        Future<({ScrollCacheExtent? cacheExtent, int builtCount})> pumpGrid(
          int columns,
        ) async {
          final builtItems = <String>{};
          await pumpTestWidget(
            tester,
            child: ListPageScaffold<String>(
              title: 'Test Title',
              searchHint: 'Search...',
              onSearchChanged: (_) {},
              provider: AsyncValue.data(items),
              hideAppBar: true,
              useResponsiveGrid: false,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
              ),
              itemBuilder: (context, item, mw, mh) {
                builtItems.add(item);
                return GridTile(child: Text(item));
              },
            ),
          );
          await tester.pump();

          final grid = tester.widget<GridView>(find.byType(GridView));
          return (
            cacheExtent: grid.scrollCacheExtent,
            builtCount: builtItems.length,
          );
        }

        final twoColumns = await pumpGrid(2);
        final fiveColumns = await pumpGrid(5);

        expect(twoColumns.cacheExtent, const ScrollCacheExtent.viewport(2.0));
        expect(fiveColumns.cacheExtent, const ScrollCacheExtent.viewport(2.0));
        expect(fiveColumns.builtCount, greaterThan(twoColumns.builtCount));
      },
    );

    testWidgets('uses configured cache for list and masonry layouts', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final items = List<String>.generate(30, (index) => 'Item $index');

      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'List',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: AsyncValue.data(items),
          hideAppBar: true,
          itemBuilder: (context, item, mw, mh) => Text(item),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<ListView>(find.byType(ListView)).scrollCacheExtent,
        const ScrollCacheExtent.viewport(2.0),
      );

      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Masonry',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: AsyncValue.data(items),
          hideAppBar: true,
          useResponsiveGrid: false,
          useMasonry: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (context, item, mw, mh) => Text(item),
        ),
      );
      await tester.pump();
      final masonryViewport = tester.widget<Viewport>(
        find.descendant(
          of: find.byType(MasonryGridView),
          matching: find.byType(Viewport),
        ),
      );
      expect(
        masonryViewport.scrollCacheExtent,
        const ScrollCacheExtent.pixels(600),
      );
    });

    testWidgets('toggles search bar when search icon is tapped', (
      WidgetTester tester,
    ) async {
      String searchQuery = '';
      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Test Title',
          searchHint: 'Search hint...',
          onSearchChanged: (val) => searchQuery = val,
          provider: const AsyncValue.data(['Item 1']),
          itemBuilder: (context, item, mw, mh) => Text(item),
        ),
      );
      await tester.pump();

      // Initially, search icon is visible
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Tap search icon (this opens SearchAnchor view)
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Now, Search view is open
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search hint...'), findsOneWidget); // Hint text

      // Type in search field
      await tester.enterText(find.byType(TextField), 'hello');

      // Submit search to close view and trigger callback
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(searchQuery, 'hello');

      // Check that the "Searching for" bar is visible
      expect(find.textContaining('Searching for: "hello"'), findsOneWidget);

      // Tap close icon in the searching for bar to clear search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Back to initial state, search query cleared
      expect(searchQuery, '');
    });

    testWidgets('places tools button between search and settings actions', (
      WidgetTester tester,
    ) async {
      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Test Title',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: const AsyncValue.data(['Item 1']),
          itemBuilder: (context, item, mw, mh) => Text(item),
        ),
      );
      await tester.pump();

      final searchX = tester.getCenter(find.byIcon(Icons.search)).dx;
      final toolsX = tester.getCenter(find.byIcon(Icons.construction)).dx;
      final settingsX = tester.getCenter(find.byIcon(Icons.settings)).dx;

      expect(searchX, lessThan(toolsX));
      expect(toolsX, lessThan(settingsX));
    });

    testWidgets('displays custom sortBar', (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Test Title',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: const AsyncValue.loading(),
          sortBar: const Text('Custom Sort Bar'),
          itemBuilder: (context, item, mw, mh) => Text(item),
        ),
      );
      await tester.pump();

      expect(find.text('Custom Sort Bar'), findsOneWidget);
    });

    testWidgets('displays custom floatingActionButton', (
      WidgetTester tester,
    ) async {
      await pumpTestWidget(
        tester,
        child: ListPageScaffold<String>(
          title: 'Test Title',
          searchHint: 'Search...',
          onSearchChanged: (_) {},
          provider: const AsyncValue.loading(),
          floatingActionButton: const FloatingActionButton(
            onPressed: null,
            child: Icon(Icons.add),
          ),
          itemBuilder: (context, item, mw, mh) => Text(item),
        ),
      );
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows long-press tooltip affordance on the title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hans',
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ListPageScaffold<String>(
              title: 'Test Title',
              searchHint: 'Search...',
              onSearchChanged: (_) {},
              provider: const AsyncValue.data(['Item 1']),
              itemBuilder: (context, item, mw, mh) => Text(item),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final title = find.text('Test Title');
      expect(title, findsOneWidget);

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Tooltip && widget.message == '长按查看资料库统计',
        ),
        findsOneWidget,
      );
    });
  });
}
