import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import 'package:stash_app_flutter/core/presentation/widgets/frosted_surface.dart';
import 'package:stash_app_flutter/core/presentation/widgets/rating_bottom_sheet.dart';
import 'package:stash_app_flutter/core/presentation/widgets/saved_filter_dialog.dart';
import 'package:stash_app_flutter/core/domain/entities/saved_filter_config.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  testWidgets('filter panel scaffold uses the shared panel layout contract', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      child: Scaffold(
        body: SizedBox(
          height: 420,
          child: FilterBottomSheetScaffold(
            title: 'Filter Title',
            onReset: () {},
            body: const SizedBox.shrink(),
            onApply: () {},
            onSaveDefault: () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final filterTitle = find.text('Filter Title');

    final filterHeaderPadding = tester.widget<Padding>(
      find.ancestor(of: filterTitle, matching: find.byType(Padding)).first,
    );
    expect(
      filterHeaderPadding.padding,
      const EdgeInsets.all(AppTheme.spacingLarge),
    );

    final filterText = tester.widget<Text>(filterTitle);
    expect(
      filterText.style?.fontSize,
      greaterThan(AppTheme.lightTheme.textTheme.titleLarge?.fontSize ?? 0),
    );

    expect(
      find.ancestor(of: filterTitle, matching: find.byType(Expanded)),
      findsOneWidget,
    );

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(FrostedSurface), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FrostedSurface),
        matching: find.byType(ClipRRect),
      ),
      findsOneWidget,
    );

    final material = tester
        .widgetList<Material>(
          find.descendant(
            of: find.byType(FrostedSurface),
            matching: find.byType(Material),
          ),
        )
        .firstWhere((material) => material.clipBehavior == Clip.antiAlias);
    expect(material.clipBehavior, Clip.antiAlias);
    expect(
      material.borderRadius,
      const BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusExtraLarge),
      ),
    );
  });

  testWidgets('saved presets dialog uses the shared panel layout contract', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      child: Scaffold(
        body: SizedBox(
          height: 520,
          child: SavedFilterDialog<_TestSavedFilterConfig>(
            searchQuery: '',
            sort: null,
            descending: true,
            activeFilterCount: 0,
            defaultSortLabel: 'Date',
            saveSuccessMessage: 'saved',
            loadPresets: () async => const [],
            savePreset: ({required String name, String? existingId}) async =>
                const _TestSavedFilterConfig(name: 'saved'),
            deletePreset: (_) async => true,
            onLoad: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(FrostedSurface), findsOneWidget);
    expect(find.byType(BottomSheetPanelHeader), findsOneWidget);
    expect(find.byType(BottomSheetPanelActions), findsOneWidget);

    final material = tester
        .widgetList<Material>(
          find.descendant(
            of: find.byType(FrostedSurface),
            matching: find.byType(Material),
          ),
        )
        .firstWhere((material) => material.clipBehavior == Clip.antiAlias);

    expect(
      material.borderRadius,
      const BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusExtraLarge),
      ),
    );

    final savedTitle = find.text('Saved Presets');
    final headerPadding = tester.widget<Padding>(
      find.ancestor(of: savedTitle, matching: find.byType(Padding)).first,
    );
    expect(headerPadding.padding, const EdgeInsets.all(AppTheme.spacingLarge));
    expect(
      find.ancestor(of: savedTitle, matching: find.byType(Expanded)),
      findsOneWidget,
    );
  });

  testWidgets('rating details use the scene details panel layout', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      child: Scaffold(
        body: RatingBottomSheet(
          initialRating: 40,
          title: 'Gallery Details',
          subtitle: 'Gallery title',
          detailsWidget: const Text('Metadata'),
          onRatingSelected: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(FrostedSurface), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(tester.widget<ListView>(find.byType(ListView)).shrinkWrap, isTrue);
    expect(find.text('Gallery Details'), findsOneWidget);
    expect(find.text('Gallery title'), findsOneWidget);
    expect(find.text('Metadata'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });
}

class _TestSavedFilterConfig extends SavedFilterConfig<bool> {
  const _TestSavedFilterConfig({
    required super.name,
    super.filterMode = 'TEST',
    super.searchQuery = '',
    super.sort,
    super.descending = true,
    super.filter = false,
  });

  @override
  Map<String, dynamic> toSaveInput() => const {};
}
