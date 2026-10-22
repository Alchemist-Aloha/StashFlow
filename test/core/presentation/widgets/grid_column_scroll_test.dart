import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/providers/layout_settings_provider.dart';
import 'package:stash_app_flutter/core/presentation/widgets/list_page_scaffold.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  Future<
    ({
      ProviderContainer container,
      SharedPreferences prefs,
      ScrollController scroll,
    })
  >
  pumpGrid(
    WidgetTester tester, {
    GridColumnSetting setting = GridColumnSetting.scene,
    int? columns,
    bool masonry = false,
    bool list = false,
    bool configured = true,
    bool customBody = false,
    VoidCallback? onItemTap,
  }) async {
    SharedPreferences.setMockInitialValues({setting.storageKey: ?columns});
    final prefs = await SharedPreferences.getInstance();
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: Consumer(
        builder: (context, ref, _) {
          final count = ref.watch(gridColumnSettingProvider(setting));
          return ListPageScaffold<int>(
            title: 'Grid',
            searchHint: 'Search',
            onSearchChanged: (_) {},
            provider: AsyncData(List.generate(100, (index) => index)),
            gridColumnSetting: configured ? setting : null,
            scrollController: scroll,
            gridDelegate: list
                ? null
                : SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count ?? 3,
                    mainAxisExtent: 120,
                  ),
            mobileCrossAxisCount: count ?? 2,
            tabletCrossAxisCount: count ?? 5,
            useMasonry: masonry,
            customBody: customBody
                ? const Center(child: Text('Custom feed'))
                : null,
            itemBuilder: (_, item, _, _) => InkWell(
              onTap: onItemTap,
              child: SizedBox(height: 120, child: Text('Item $item')),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();
    return (
      container: ProviderScope.containerOf(
        tester.element(find.byType(Consumer)),
      ),
      prefs: prefs,
      scroll: scroll,
    );
  }

  Future<void> holdControl(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    addTearDown(() => tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft));
  }

  Future<void> wheel(
    WidgetTester tester,
    double delta, {
    PointerDeviceKind kind = PointerDeviceKind.mouse,
  }) async {
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: const Offset(300, 300),
        scrollDelta: Offset(0, delta),
        kind: kind,
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final setting in GridColumnSetting.values) {
    testWidgets('Ctrl+wheel updates only the $setting preference', (
      tester,
    ) async {
      final result = await pumpGrid(tester, setting: setting, columns: 3);
      result.scroll.jumpTo(200);
      await tester.pump();
      await holdControl(tester);
      await wheel(tester, -120);
      expect(result.container.read(gridColumnSettingProvider(setting)), 2);
      expect(result.prefs.getInt(setting.storageKey), 2);
      expect(result.scroll.offset, 200);
      await wheel(tester, 120);
      expect(result.prefs.getInt(setting.storageKey), 3);
      expect(result.scroll.offset, 200);
      for (final other in GridColumnSetting.values.where(
        (item) => item != setting,
      )) {
        expect(result.prefs.getInt(other.storageKey), isNull);
      }
    });
  }

  for (final masonry in [false, true]) {
    testWidgets(
      'automatic ${masonry ? 'masonry' : 'fixed'} columns start at the displayed count',
      (tester) async {
        final result = await pumpGrid(tester, masonry: masonry);
        await holdControl(tester);
        await wheel(tester, 120);
        expect(result.prefs.getInt(GridColumnSetting.scene.storageKey), 6);
        expect(
          result.container.read(
            gridColumnSettingProvider(GridColumnSetting.scene),
          ),
          6,
        );
      },
    );
  }

  for (final limit in [1, 10]) {
    testWidgets('Ctrl+wheel stays within the $limit column limit', (
      tester,
    ) async {
      final result = await pumpGrid(tester, columns: limit);
      result.scroll.jumpTo(200);
      await tester.pump();
      await holdControl(tester);
      await wheel(tester, limit == 1 ? -120 : 120);
      expect(result.prefs.getInt(GridColumnSetting.scene.storageKey), limit);
      expect(result.scroll.offset, 200);
    });
  }

  testWidgets('ordinary mouse wheel still scrolls without changing columns', (
    tester,
  ) async {
    final result = await pumpGrid(tester, columns: 3);
    await wheel(tester, 120);
    expect(result.scroll.offset, greaterThan(0));
    expect(result.prefs.getInt(GridColumnSetting.scene.storageKey), 3);
  });

  testWidgets('Ctrl+trackpad does not change columns', (tester) async {
    final result = await pumpGrid(tester, columns: 3);
    await holdControl(tester);
    await wheel(tester, 120, kind: PointerDeviceKind.trackpad);
    expect(result.prefs.getInt(GridColumnSetting.scene.storageKey), 3);
  });

  testWidgets('grid items remain clickable through the wheel listener', (
    tester,
  ) async {
    var taps = 0;
    await pumpGrid(tester, columns: 3, onItemTap: () => taps++);
    await tester.tap(find.text('Item 10'));
    expect(taps, 1);
    await holdControl(tester);
    await wheel(tester, 120);
    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(
      (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
          .crossAxisCount,
      4,
    );
    await tester.tap(find.text('Item 10'));
    expect(taps, 2);
  });

  for (final mode in ['list', 'unconfigured', 'custom']) {
    testWidgets('Ctrl+wheel leaves $mode views unchanged', (tester) async {
      final result = await pumpGrid(
        tester,
        columns: 3,
        list: mode == 'list',
        configured: mode != 'unconfigured',
        customBody: mode == 'custom',
      );
      await holdControl(tester);
      await wheel(tester, -120);
      expect(result.prefs.getInt(GridColumnSetting.scene.storageKey), 3);
    });
  }
}
