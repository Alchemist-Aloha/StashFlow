import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
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

    expect(find.byType(BackdropFilter), findsOneWidget);

    final material = tester
        .widgetList<Material>(
          find.descendant(
            of: find.byType(BackdropFilter),
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

    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byType(BottomSheetPanelHeader), findsOneWidget);
    expect(find.byType(BottomSheetPanelActions), findsOneWidget);

    final material = tester
        .widgetList<Material>(
          find.descendant(
            of: find.byType(BackdropFilter),
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
