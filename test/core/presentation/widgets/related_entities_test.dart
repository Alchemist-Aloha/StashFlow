import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/providers/related_entities_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/related_entities.dart';
import 'package:stash_app_flutter/core/presentation/widgets/section_header.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  for (final scale in [0.5, 1.0, 2.0]) {
    for (final subtitle in [null, '', ' \n ']) {
      testWidgets('blank subtitle keeps name centered at $scale ($subtitle)', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          child: Theme(
            data: AppTheme.buildTheme(
              Brightness.dark,
              const Color(0xFF0F766E),
              fontSizeFactor: scale,
            ),
            child: Scaffold(
              body: SizedBox(
                width: 320,
                child: RelatedEntityTile(
                  title: 'Co Star',
                  route: '/performers/performer/p2',
                  fallbackIcon: Icons.person,
                  imagePath: 'https://example.com/performer?default=true',
                  subtitle: subtitle,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final tile = tester.widget<ListTile>(find.byType(ListTile));
        expect(tile.subtitle, isNull);
        expect(
          tester.getCenter(find.text('Co Star')).dy,
          closeTo(tester.getCenter(find.byIcon(Icons.chevron_right)).dy, 0.01),
        );
        expect(
          tester.getCenter(find.byType(CircleAvatar)).dy,
          closeTo(tester.getCenter(find.text('Co Star')).dy, 0.01),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('meaningful relationship subtitles remain visible', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      child: const Scaffold(
        body: RelatedEntityTile(
          title: 'Group',
          route: '/groups/group/1',
          fallbackIcon: Icons.folder,
          subtitle: '  Relationship description  ',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Relationship description'), findsOneWidget);
  });

  testWidgets('related performer rows use scene performer spacing', (
    tester,
  ) async {
    const query = (
      kind: RelatedEntityKind.performers,
      owner: RelatedEntityOwner.performer,
      id: 'p1',
    );
    await pumpTestWidget(
      tester,
      overrides: [
        relatedEntitiesProvider(query).overrideWith(
          (ref) => [
            for (var i = 2; i <= 3; i++)
              (
                id: 'p$i',
                title: 'Co Star $i',
                subtitle: '',
                imagePath: null,
                route: '/performers/performer/p$i',
              ),
          ],
        ),
      ],
      child: const Scaffold(
        body: RelatedEntitiesSection(
          title: 'Appears With',
          query: query,
          fallbackIcon: Icons.person,
          collapsedCount: 5,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final tiles = find.byType(ListTile);
    expect(
      tester.getTopLeft(tiles.first).dy -
          tester.getBottomLeft(find.byType(SectionHeader)).dy,
      AppTheme.spacingSmall,
    );
    expect(
      tester.getTopLeft(tiles.last).dy - tester.getBottomLeft(tiles.first).dy,
      AppTheme.spacingSmall,
    );
    expect(
      tester.widget<ListTile>(tiles.first).contentPadding,
      EdgeInsets.zero,
    );
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    final context = tester.element(tiles.first);
    expect(
      tester.widget<Text>(find.text('Co Star 2')).style,
      context.textTheme.bodyLarge,
    );
    expect(tester.takeException(), isNull);
  });
}
