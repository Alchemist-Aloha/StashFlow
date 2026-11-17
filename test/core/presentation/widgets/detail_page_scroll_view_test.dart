import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/detail_page_scroll_view.dart';

void main() {
  testWidgets('lazy sections reduce initial builds and repaint work', (
    tester,
  ) async {
    var builds = 0;
    final paints = List.filled(40, 0);
    List<Widget> sections() => List.generate(
      paints.length,
      (index) => Builder(
        builder: (context) {
          builds++;
          return SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _CountingPainter(() => paints[index]++),
            ),
          );
        },
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: Column(children: sections())),
        ),
      ),
    );
    final eagerBuilds = builds;
    expect(eagerBuilds, 40);
    final eagerPaints = paints.fold<int>(0, (sum, count) => sum + count);

    builds = 0;
    paints.fillRange(0, paints.length, 0);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DetailPageScrollView(children: sections())),
      ),
    );
    final lazyBuilds = builds;
    expect(lazyBuilds, lessThan(10));
    final lazyPaints = paints.fold<int>(0, (sum, count) => sum + count);
    expect(lazyPaints, lessThan(eagerPaints));
    final firstPaints = paints.first;
    await tester.drag(find.byType(ListView), const Offset(0, -60));
    await tester.pumpAndSettle();
    expect(paints.first, firstPaints);
    expect(tester.takeException(), isNull);
    // Deterministic work counts, not a claim about device frame times.
    debugPrint(
      'Detail sections built: eager=$eagerBuilds, lazy=$lazyBuilds; '
      'initial paints: eager=$eagerPaints, lazy=$lazyPaints',
    );
  });

  testWidgets('visited header and disclosure state survive scrolling away', (
    tester,
  ) async {
    var mounts = 0;
    var disposals = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DetailPageScrollView(
            header: _Disclosure(
              name: 'header',
              onMount: () => mounts++,
              onDispose: () => disposals++,
            ),
            children: [
              _Disclosure(
                name: 'section',
                onMount: () => mounts++,
                onDispose: () => disposals++,
              ),
              for (var i = 0; i < 20; i++)
                SizedBox(height: 200, child: Text('Section $i')),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Expand section'));
    await tester.pump();
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(mounts, 2);
    expect(disposals, 0);
    position.jumpTo(0);
    await tester.pumpAndSettle();
    expect(find.text('Expanded section'), findsOneWidget);
    expect(mounts, 2);
    await tester.pumpWidget(const SizedBox());
    expect(disposals, 2);
  });

  for (final scale in [0.8, 1.5]) {
    testWidgets('insets, scaled padding, and refresh remain intact ($scale)', (
      tester,
    ) async {
      var refreshes = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildTheme(
            Brightness.light,
            Colors.teal,
            fontSizeFactor: scale,
          ),
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async => refreshes++,
              child: const DetailPageScrollView(
                padding: EdgeInsets.only(top: 56, bottom: 90),
                header: SizedBox(key: Key('cover'), height: 100),
                children: [
                  Text('Identity'),
                  SizedBox(height: 1000),
                  Text('Last'),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.getTopLeft(find.byKey(const Key('cover'))).dy, 56);
      expect(tester.getTopLeft(find.text('Identity')).dx, 16 * scale);
      expect(tester.getTopLeft(find.text('Identity')).dy, 156 + 16 * scale);
      await tester.drag(find.byType(ListView), const Offset(0, 350));
      await tester.pumpAndSettle();
      expect(refreshes, 1);
      await tester.scrollUntilVisible(find.text('Last'), 300);
      await tester.pumpAndSettle();
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(find.text('Last')).dy,
        closeTo(
          tester.getBottomLeft(find.byType(ListView)).dy - 90 - 16 * scale,
          0.1,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

class _CountingPainter extends CustomPainter {
  _CountingPainter(this.onPaint);
  final VoidCallback onPaint;

  @override
  void paint(Canvas canvas, Size size) {
    onPaint();
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.teal);
  }

  @override
  bool shouldRepaint(_CountingPainter oldDelegate) => false;
}

class _Disclosure extends StatefulWidget {
  const _Disclosure({
    required this.name,
    required this.onMount,
    required this.onDispose,
  });
  final String name;
  final VoidCallback onMount;
  final VoidCallback onDispose;

  @override
  State<_Disclosure> createState() => _DisclosureState();
}

class _DisclosureState extends State<_Disclosure> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 100,
    child: TextButton(
      onPressed: () => setState(() => _expanded = !_expanded),
      child: Text('${_expanded ? 'Expanded' : 'Expand'} ${widget.name}'),
    ),
  );
}
