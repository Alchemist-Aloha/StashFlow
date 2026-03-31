import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/presentation/widgets/media_strip.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return ProviderScope(
      overrides: [serverApiKeyProvider.overrideWithValue('dummy_api_key')],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('MediaStripItem tests', () {
    test('MediaStripItem instantiation works correctly', () {
      bool tapped = false;
      final item = MediaStripItem(
        id: '1',
        title: 'Test Title',
        thumbnailUrl: 'https://example.com/image.jpg',
        onTap: () {
          tapped = true;
        },
      );

      expect(item.id, '1');
      expect(item.title, 'Test Title');
      expect(item.thumbnailUrl, 'https://example.com/image.jpg');

      item.onTap();
      expect(tapped, isTrue);
    });
  });

  group('MediaStrip tests', () {
    testWidgets('renders empty state when items list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const MediaStrip(items: [])));

      expect(find.text('No media available.'), findsOneWidget);
    });

    testWidgets('renders items and handles tap correctly', (WidgetTester tester) async {
      bool tapped = false;
      final item = MediaStripItem(
        id: '1',
        title: 'Test Video',
        // Using an empty url prevents CachedNetworkImage from downloading and causing MissingPluginExceptions during tests
        thumbnailUrl: '',
        onTap: () {
          tapped = true;
        },
      );

      await tester.pumpWidget(
        buildTestWidget(
          MediaStrip(items: [item]),
        ),
      );

      expect(find.text('Test Video'), findsOneWidget);

      await tester.tap(find.text('Test Video'));

      expect(tapped, isTrue);
    });

    testWidgets('handles scrolling without errors', (WidgetTester tester) async {
      final items = List.generate(
        10,
        (index) => MediaStripItem(
          id: '$index',
          title: 'Video $index',
          thumbnailUrl: '', // avoid downloading
          onTap: () {},
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          MediaStrip(items: items),
        ),
      );

      final listFinder = find.byType(Scrollable);

      // Scroll horizontally to trigger NotificationListener
      await tester.drag(listFinder, const Offset(-300, 0));

      expect(tester.takeException(), isNull);
    });
  });
}
