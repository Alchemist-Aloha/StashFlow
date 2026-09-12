import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/list_page_scaffold.dart';

import '../test/helpers/test_helpers.dart';

void main() {
  testWidgets('common list surfaces stay cheap to build and scroll', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final surface in const [
      _Surface.list,
      _Surface.grid,
      _Surface.masonry,
    ]) {
      await _benchmarkSurface(tester, surface);
    }
  });
}

enum _Surface { list, grid, masonry }

const _initialBuildLimits = {
  _Surface.list: 35,
  _Surface.grid: 60,
  _Surface.masonry: 90,
};
const _scrollBuildLimits = {
  _Surface.list: 500,
  _Surface.grid: 800,
  _Surface.masonry: 1200,
};

Future<void> _benchmarkSurface(WidgetTester tester, _Surface surface) async {
  final controller = ScrollController();
  var builds = 0;
  final isGrid = surface != _Surface.list;

  await pumpTestWidget(
    tester,
    child: ListPageScaffold<int>(
      title: surface.name,
      searchHint: 'Search',
      onSearchChanged: (_) {},
      provider: AsyncValue.data(List.generate(2000, (index) => index)),
      hideAppBar: true,
      scrollController: controller,
      useResponsiveGrid: false,
      useMasonry: surface == _Surface.masonry,
      gridDelegate: isGrid
          ? const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5)
          : null,
      itemBuilder: (context, item, width, height) {
        builds++;
        return SizedBox(
          height: surface == _Surface.masonry ? 120 + (item % 5) * 32 : 96,
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.movie_outlined),
              title: Text('Item $item'),
              subtitle: const Text('Representative metadata'),
            ),
          ),
        );
      },
    ),
  );
  await tester.pump();

  final initialBuilds = builds;
  final timer = Stopwatch()..start();
  for (var frame = 0; frame < 120; frame++) {
    controller.jumpTo(
      math.min(controller.offset + 320, controller.position.maxScrollExtent),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
  timer.stop();
  final scrollBuilds = builds - initialBuilds;

  expect(initialBuilds, lessThanOrEqualTo(_initialBuildLimits[surface]!));
  expect(scrollBuilds, lessThanOrEqualTo(_scrollBuildLimits[surface]!));

  // ignore: avoid_print
  print(
    'PERF ${surface.name} initial_builds=$initialBuilds '
    'scroll_builds=$scrollBuilds elapsed_us=${timer.elapsedMicroseconds}',
  );
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  controller.dispose();
}
