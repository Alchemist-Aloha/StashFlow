import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return ProviderScope(
      overrides: [serverApiKeyProvider.overrideWithValue('dummy_api_key')],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('StashImage builds successfully with imageUrl', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        const StashImage(imageUrl: 'https://example.com/image.jpg'),
      ),
    );

    expect(find.byType(StashImage), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });

  testWidgets('StashImage builds error widget when imageUrl is null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(const StashImage(imageUrl: null)));

    expect(find.byType(StashImage), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });

  testWidgets('StashImage builds error widget when imageUrl is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(const StashImage(imageUrl: '')));

    expect(find.byType(StashImage), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });
}
