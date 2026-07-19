import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/fullscreen_controller.dart';

void main() {
  test('exit request preserves fullscreen presentation until completion', () {
    const controller = FullscreenController();

    final exiting = controller.requestExitFullscreen();

    expect(exiting.isFullScreen, isTrue);
    expect(exiting.viewModeName, 'fullscreen');
    expect(exiting.fullscreenPhase, FullscreenPhase.exiting);

    final exited = controller.markExited();
    expect(exited.isFullScreen, isFalse);
    expect(exited.viewModeName, 'inline');
    expect(exited.fullscreenPhase, FullscreenPhase.inline);
  });

  test('failed native exit restores retryable fullscreen state', () {
    const controller = FullscreenController();

    final restored = controller.restoreAfterFailedExit();

    expect(restored.isFullScreen, isTrue);
    expect(restored.viewModeName, 'fullscreen');
    expect(restored.fullscreenPhase, FullscreenPhase.fullscreen);
  });
}
