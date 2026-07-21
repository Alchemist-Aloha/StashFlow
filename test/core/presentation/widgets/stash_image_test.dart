import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  test('prefetch deduplication only tracks active work', () {
    final source = File(
      'lib/core/presentation/widgets/stash_image.dart',
    ).readAsStringSync();

    expect(source, contains('static final Set<String> _prefetching'));
    expect(source, contains('_prefetching.remove(dedupeKey);'));
    expect(source, isNot(contains('_prefetched')));
  });

  testWidgets('StashImage builds successfully with imageUrl', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(
      tester,
      child: const StashImage(imageUrl: 'https://example.com/image.jpg'),
    );
    await tester.pump();

    expect(find.byType(StashImage), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });

  testWidgets('StashImage builds error widget when imageUrl is null', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester, child: const StashImage(imageUrl: null));
    await tester.pump();

    expect(find.byType(StashImage), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });

  testWidgets('StashImage builds error widget when imageUrl is empty', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester, child: const StashImage(imageUrl: ''));
    await tester.pump();

    expect(find.byType(StashImage), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });
}
