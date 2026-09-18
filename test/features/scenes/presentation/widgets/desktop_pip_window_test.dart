import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/desktop_pip_window.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

class _FakeVideoController extends Mock implements VideoController {
  _FakeVideoController(this.fakePlayer);

  final _FakePlayer fakePlayer;

  @override
  mk.Player get player => fakePlayer;
}

class _FakePlayer extends Mock implements mk.Player {
  @override
  mk.PlayerStream get stream => _FakePlayerStream();

  @override
  mk.PlayerState get state => const mk.PlayerState(
    position: Duration(seconds: 20),
    duration: Duration(seconds: 100),
  );
}

class _FakePlayerStream extends Fake implements mk.PlayerStream {
  @override
  Stream<bool> get playing => const Stream<bool>.empty();

  @override
  Stream<Duration> get position => const Stream<Duration>.empty();

  @override
  Stream<Duration> get duration => const Stream<Duration>.empty();
}

void main() {
  testWidgets('PiP transport seeks and exposes previous and next actions', (
    tester,
  ) async {
    final controller = _FakeVideoController(_FakePlayer());
    Duration? seekTarget;
    var previousCalls = 0;
    var nextCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(
          child: DesktopPipTransportControls(
            controller: controller,
            canPlayPrevious: true,
            canPlayNext: true,
            onTogglePlayback: () {},
            onSeek: (position) async => seekTarget = position,
            onPrevious: () async => previousCalls++,
            onNext: () async => nextCalls++,
          ),
        ),
      ),
    );

    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChangeEnd!(42000);
    await tester.tap(find.byIcon(Icons.skip_previous_rounded));
    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester.pump();

    expect(seekTarget, const Duration(seconds: 42));
    expect(previousCalls, 1);
    expect(nextCalls, 1);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('PiP transport disables unavailable queue directions', (
    tester,
  ) async {
    final controller = _FakeVideoController(_FakePlayer());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(
          child: DesktopPipTransportControls(
            controller: controller,
            canPlayPrevious: false,
            canPlayNext: false,
            onTogglePlayback: () {},
            onSeek: (_) async {},
            onPrevious: () async {},
            onNext: () async {},
          ),
        ),
      ),
    );

    final previous = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.skip_previous_rounded),
        matching: find.byType(IconButton),
      ),
    );
    final next = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.skip_next_rounded),
        matching: find.byType(IconButton),
      ),
    );

    expect(previous.onPressed, isNull);
    expect(next.onPressed, isNull);
  });

  test('PiP title is stable for compositor window rules', () {
    expect(kDesktopPipWindowTitle, startsWith('Picture-in-Picture'));
  });
}
