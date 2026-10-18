import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import 'package:stash_app_flutter/core/presentation/widgets/list_sort_bottom_sheet.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

void main() {
  Future<void> openSheet(
    WidgetTester tester, {
    List<int>? commonOptions,
    int initialOption = 0,
    double scale = 1,
    Locale locale = const Locale('en'),
    void Function(int, bool)? onApply,
    Future<void> Function()? onSaveDefault,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildTheme(
          Brightness.light,
          Colors.teal,
          fontSizeFactor: scale,
        ),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showFrostedPanelBottomSheet<void>(
                context: context,
                builder: (_) => ListSortBottomSheet<int>(
                  title: 'Sort',
                  options: List.generate(31, (i) => i),
                  commonOptions: commonOptions,
                  initialOption: initialOption,
                  initialDescending: true,
                  resetOption: 0,
                  resetDescending: true,
                  optionLabel: (option) => 'Option $option',
                  onApply: onApply ?? (_, _) {},
                  onSaveDefault: onSaveDefault ?? () async {},
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('existing callers retain every option without grouping', (
    tester,
  ) async {
    await openSheet(tester);
    expect(find.byType(ChoiceChip), findsNWidgets(31));
    expect(find.byType(ExpansionTile), findsNothing);
  });

  testWidgets(
    'advanced choices are disclosed and selected choice stays visible',
    (tester) async {
      int? applied;
      await openSheet(
        tester,
        commonOptions: [0, 1, 2, 3],
        onApply: (option, _) => applied = option,
      );
      expect(find.byType(ChoiceChip), findsNWidgets(4));
      expect(find.text('Option 4'), findsNothing);
      await tester.ensureVisible(find.byType(ExpansionTile));
      await tester.tap(find.text('Advanced sort options'));
      await tester.pumpAndSettle();
      expect(find.byType(ChoiceChip), findsNWidgets(31));
      await tester.ensureVisible(find.text('Option 4'));
      await tester.tap(find.text('Option 4'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Option 4'))
            .selected,
        isTrue,
      );
      await tester.tap(find.text('Apply Sort'));
      await tester.pumpAndSettle();
      expect(applied, 4);
    },
  );

  testWidgets('restored advanced sort is visible without expanding', (
    tester,
  ) async {
    await openSheet(tester, commonOptions: [0, 1, 2, 3], initialOption: 30);
    expect(find.byType(ChoiceChip), findsNWidgets(5));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Option 30'))
          .selected,
      isTrue,
    );
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNWidgets(4));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Option 0'))
          .selected,
      isTrue,
    );
  });

  testWidgets('save default preserves the advanced sort and direction', (
    tester,
  ) async {
    (int, bool)? applied;
    var saved = false;
    await openSheet(
      tester,
      commonOptions: [0, 1, 2, 3],
      initialOption: 30,
      onApply: (option, descending) => applied = (option, descending),
      onSaveDefault: () async => saved = true,
    );
    await tester.tap(find.text('Ascending'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save as Default'));
    await tester.pumpAndSettle();
    expect(applied, (30, false));
    expect(saved, isTrue);
  });

  for (final scale in [0.8, 1.5]) {
    testWidgets('small German sheet keeps actions reachable at scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openSheet(
        tester,
        commonOptions: [0, 1, 2, 3],
        initialOption: 30,
        scale: scale,
        locale: const Locale('de'),
      );
      final apply = find.byType(ElevatedButton);
      expect(apply.hitTestable(), findsOneWidget);
      expect(tester.getRect(apply).bottom, lessThanOrEqualTo(480));
      expect(tester.takeException(), isNull);
    });
  }
}
