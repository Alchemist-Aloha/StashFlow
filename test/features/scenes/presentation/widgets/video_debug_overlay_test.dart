import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/video_controls/video_debug_overlay.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

class DiagnosticPlatform extends Fake implements mk.NativePlayer {
  final values = <String, String>{
    'video-codec': 'h264',
    'hwdec-current': 'no',
    'current-vo': 'gpu',
    'container-fps': '24',
    'estimated-vf-fps': '23.98',
    'decoder-frame-drop-count': '0',
    'frame-drop-count': '3',
    'avsync': '-0.012',
    'demuxer-cache-duration': '4.5',
  };
  int reads = 0;

  @override
  Future<String> getProperty(
    String property, {
    bool waitForInitialization = true,
  }) async {
    reads++;
    expect(waitForInitialization, isFalse);
    if (!values.containsKey(property)) throw StateError('Unsupported');
    return values[property]!;
  }
}

class DiagnosticPlayer extends Fake implements mk.Player {
  DiagnosticPlayer(this.platform);

  @override
  final mk.PlatformPlayer? platform;

  @override
  mk.PlayerState get state => const mk.PlayerState(
    width: 1920,
    height: 1080,
    position: Duration(seconds: 20),
    buffer: Duration(seconds: 25),
  );
}

Widget panel(mk.Player player, {double scale = 1, double width = 400}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      theme: AppTheme.buildTheme(
        Brightness.dark,
        Colors.teal,
        fontSizeFactor: scale,
      ),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            height: 160,
            child: VideoDebugOverlay(
              player: player,
              session: GlobalPlayerState(
                streamMimeType: 'video/mp4',
                streamLabel: List.filled(12, 'Long stream variant').join(' '),
                streamSource: 'direct',
                startupLatencyMs: 120,
                prewarmAttempted: true,
                prewarmSucceeded: false,
                prewarmLatencyMs: 80,
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets(
    'samples real metrics, handles missing properties, stops on unmount',
    (tester) async {
      final platform = DiagnosticPlatform();
      await tester.pumpWidget(panel(DiagnosticPlayer(platform)));
      await tester.pump();
      expect(find.text('h264'), findsOneWidget);
      expect(find.text('no'), findsOneWidget);
      expect(find.text('24.00 fps'), findsOneWidget);
      expect(find.text('23.98 fps'), findsOneWidget);
      expect(find.text('-12.00 ms'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('5.00 s'), findsOneWidget);
      expect(find.text('Failed · 80 ms'), findsOneWidget);
      platform.values['frame-drop-count'] = '7';
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('7'), findsOneWidget);
      final reads = platform.reads;
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      expect(platform.reads, reads);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'player replacement clears stale diagnostics and web is supported',
    (tester) async {
      await tester.pumpWidget(panel(DiagnosticPlayer(DiagnosticPlatform())));
      await tester.pump();
      expect(find.text('h264'), findsOneWidget);
      await tester.pumpWidget(panel(DiagnosticPlayer(null)));
      await tester.pump();
      expect(find.text('h264'), findsNothing);
      expect(find.text('Unavailable'), findsWidgets);
      expect(find.text('1920 × 1080'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final scale in [0.7, 1.5]) {
    for (final width in [240.0, 400.0]) {
      testWidgets('scrollable without overflow at width $width scale $scale', (
        tester,
      ) async {
        await tester.pumpWidget(
          panel(DiagnosticPlayer(null), scale: scale, width: width),
        );
        await tester.pump();
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -2000),
        );
        await tester.pump();
        final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
        scroll.position.jumpTo(scroll.position.maxScrollExtent);
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Failed · 80 ms').hitTestable(), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
