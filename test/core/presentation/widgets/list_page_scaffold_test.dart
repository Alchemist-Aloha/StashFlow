import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/list_page_scaffold.dart';
import 'package:stash_app_flutter/core/presentation/widgets/error_state_view.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ListPageScaffold', () {
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

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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

      expect(find.byType(ListView), findsOneWidget);
      for (final item in items) {
        expect(find.text(item), findsOneWidget);
      }
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

      expect(find.byType(GridView), findsOneWidget);
      for (final item in items) {
        expect(find.text(item), findsOneWidget);
      }
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
          provider: const AsyncValue.loading(),
          itemBuilder: (context, item, mw, mh) => Text(item),
        ),
      );

      // Initially, title is shown, search icon is visible
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byType(TextField), findsNothing);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Now, TextField is shown, close icon is visible, title is hidden
      expect(find.text('Test Title'), findsNothing);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search hint...'), findsOneWidget); // Hint text

      // Type in search field
      await tester.enterText(find.byType(TextField), 'hello');
      expect(searchQuery, 'hello');

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Back to initial state, search query cleared
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(searchQuery, '');
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

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
