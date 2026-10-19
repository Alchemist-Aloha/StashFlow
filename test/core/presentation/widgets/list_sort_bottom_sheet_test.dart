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
    int optionCount = 31,
    int initialOption = 0,
    double scale = 1,
    Locale locale = const Locale('en'),
    BoxConstraints? sheetConstraints,
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
                constraints: sheetConstraints,
                builder: (_) => ListSortBottomSheet<int>(
                  title: 'Sort',
                  options: List.generate(optionCount, (i) => i),
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
    await tester.ensureVisible(find.text('Ascending'));
    await tester.tap(find.text('Ascending'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save as Default'));
    await tester.pumpAndSettle();
    expect(applied, (30, false));
    expect(saved, isTrue);
  });

  testWidgets('ungrouped short lists fit their content', (tester) async {
    await openSheet(tester, optionCount: 3);
    expect(
      tester.getSize(find.byType(ListSortBottomSheet<int>)).height,
      lessThan(600 * 0.88),
    );
    expect(find.text('Apply Sort').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final availableHeight in [300.0, 900.0]) {
    testWidgets(
      'content height stays capped in a $availableHeight-high modal',
      (tester) async {
        tester.view.physicalSize = const Size(800, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await openSheet(
          tester,
          commonOptions: [0, 1, 2, 3],
          sheetConstraints: BoxConstraints(maxHeight: availableHeight),
        );
        final sheet = find.byType(ListSortBottomSheet<int>);
        final originalBounds = tester.getRect(sheet);
        final maxHeight = availableHeight * 0.88;
        if (availableHeight == 900) {
          expect(originalBounds.height, lessThan(maxHeight));
        } else {
          expect(originalBounds.height, closeTo(maxHeight, 0.01));
        }
        await tester.ensureVisible(find.byType(ExpansionTile));
        await tester.tap(find.text('Advanced sort options'));
        // Check intermediate animation frames as well as the final layout.
        for (var frame = 0; frame < 20; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(tester.getSize(sheet).height, lessThanOrEqualTo(maxHeight));
          expect(tester.takeException(), isNull);
        }
        await tester.pumpAndSettle();
        final expandedBounds = tester.getRect(sheet);
        expect(expandedBounds.height, closeTo(maxHeight, 0.01));
        if (availableHeight == 900) {
          expect(expandedBounds.height, greaterThan(originalBounds.height));
        }
        await tester.ensureVisible(find.text('Option 30'));
        expect(find.text('Option 30').hitTestable(), findsOneWidget);
        expect(find.text('Apply Sort').hitTestable(), findsOneWidget);
        await tester.ensureVisible(find.byType(ExpansionTile));
        await tester.tap(find.text('Advanced sort options'));
        await tester.pumpAndSettle();
        expect(tester.getRect(sheet), originalBounds);
        expect(find.text('Apply Sort').hitTestable(), findsOneWidget);
        await tester.tapAt(Offset(400, originalBounds.top - 10));
        await tester.pumpAndSettle();
        expect(sheet, findsNothing);
      },
    );
  }

  for (final size in [const Size(320, 480), const Size(640, 320)]) {
    for (final scale in [0.8, 1.5]) {
      testWidgets(
        'expanded sheet stays capped and dismissible at $size / $scale',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var applied = false;
          await openSheet(
            tester,
            commonOptions: [0, 1, 2, 3],
            scale: scale,
            onApply: (_, _) => applied = true,
          );
          await tester.ensureVisible(find.byType(ExpansionTile));
          await tester.tap(find.text('Advanced sort options'));
          await tester.pumpAndSettle();
          final sheet = find.byType(ListSortBottomSheet<int>);
          expect(
            tester.getSize(sheet).height,
            lessThanOrEqualTo(size.height * 0.88),
          );
          expect(
            tester.getRect(sheet).top,
            greaterThanOrEqualTo(size.height * 0.12 - 0.01),
          );
          await tester.ensureVisible(find.text('Option 30'));
          expect(find.text('Option 30').hitTestable(), findsOneWidget);
          expect(find.text('Apply Sort').hitTestable(), findsOneWidget);
          expect(find.text('Save as Default').hitTestable(), findsOneWidget);
          await tester.tapAt(Offset(size.width / 2, size.height * 0.05));
          await tester.pumpAndSettle();
          expect(sheet, findsNothing);
          expect(applied, isFalse);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

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
