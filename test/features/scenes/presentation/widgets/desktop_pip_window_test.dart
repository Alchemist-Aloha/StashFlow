import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mockito/mockito.dart';
import 'package:multiview_desktop/multiview_desktop.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/desktop_pip_window.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/utils/pip_mode.dart';

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

class _FakePipWindow extends Mock implements MultiViewDesktop {
  Size size = const Size(300, 533);
  Size minimum = const Size(120, 214);
  Size maximum = const Size(50000, 50000);
  Size? requestedSize;
  double ratio = 9 / 16;

  @override
  Size getSize() => size;

  @override
  Size getMaximumSize() => maximum;

  @override
  bool setMinimumSize(Size value) {
    assert(ratio == 0, 'size constraints require an unlocked ratio');
    minimum = value;
    return true;
  }

  @override
  bool setMaximumSize(Size value) {
    assert(ratio == 0, 'size constraints require an unlocked ratio');
    maximum = value;
    return true;
  }

  @override
  Future<bool> setAspectRatio(double value) async {
    ratio = value;
    return true;
  }

  @override
  Future<bool> setSize(Size value, {AnimationSettings? animation}) async {
    requestedSize = value;
    // Wayland confirms the actual size later through a metrics event.
    return true;
  }
}

void main() {
  testWidgets('Wayland PiP waits for resize then restores resizable bounds', (
    tester,
  ) async {
    final window = _FakePipWindow();
    final update = applyDesktopPipWindowAspectRatio(
      window,
      16 / 9,
      isWayland: true,
    );
    await tester.pump();
    expect(window.requestedSize, const Size(948, 533));
    expect(window.minimum, window.requestedSize);
    expect(window.maximum, window.requestedSize);
    expect(window.ratio, 0);

    window.size = window.requestedSize!;
    tester.binding.handleMetricsChanged();
    await update;
    expect(window.minimum, desktopPipMinimumSize(16 / 9));
    expect(window.maximum, const Size(50000, 50000));
    expect(window.ratio, 16 / 9);
  });

  testWidgets('Wayland timeout restores resizing and ratio lock', (
    tester,
  ) async {
    final window = _FakePipWindow();
    final update = applyDesktopPipWindowAspectRatio(window, 1, isWayland: true);
    final failure = expectLater(update, throwsA(isA<TimeoutException>()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await failure;
    expect(window.minimum, desktopPipMinimumSize(1));
    expect(window.maximum, const Size(50000, 50000));
    expect(window.ratio, 1);
  });

  test('PiP integer sizing avoids truncating portrait width', () {
    expect(
      desktopPipResizeSize(const Size(168.75, 300), 9 / 16),
      const Size(169, 300),
    );
    expect(
      desktopPipResizeSize(const Size(169, 300), 16 / 9),
      const Size(533, 300),
    );
    expect(
      desktopPipResizeSize(const Size(1, 1), 9 / 16),
      const Size(120, 214),
    );
  });
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

  test('PiP follows decoder display dimensions rather than encoded pixels', () {
    expect(
      pipDisplayAspectRatio(
        const mk.VideoParams(w: 720, h: 480, dw: 853, dh: 480),
      ),
      closeTo(853 / 480, 0.001),
    );
    expect(pipDisplayAspectRatio(const mk.VideoParams(dw: 1080, dh: 1080)), 1);
    expect(
      pipDisplayAspectRatio(
        const mk.VideoParams(dw: 1920, dh: 1080, rotate: 90),
      ),
      9 / 16,
    );
    expect(
      pipDisplayAspectRatio(
        const mk.VideoParams(dw: 1920, dh: 1080, rotate: 270),
      ),
      9 / 16,
    );
    expect(
      pipDisplayAspectRatio(
        const mk.VideoParams(dw: 1920, dh: 1080, rotate: 180),
      ),
      16 / 9,
    );
    expect(pipDisplayAspectRatio(const mk.VideoParams(aspect: 4 / 3)), 4 / 3);
  });

  test(
    'PiP ignores unavailable display metadata instead of locking to a fallback',
    () {
      for (final params in [
        const mk.VideoParams(),
        const mk.VideoParams(dw: 0, dh: 1080),
        const mk.VideoParams(dw: 1080, dh: 0),
        const mk.VideoParams(aspect: double.nan),
        const mk.VideoParams(aspect: double.infinity),
        const mk.VideoParams(aspect: -1),
      ]) {
        expect(pipDisplayAspectRatio(params), isNull);
      }
    },
  );

  test('PiP title is stable for compositor window rules', () {
    expect(kDesktopPipWindowTitle, startsWith('Picture-in-Picture'));
  });
}
