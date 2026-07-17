import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/fullscreen_controller.dart';

void main() {
  test('failed native exit restores retryable fullscreen state', () {
    const controller = FullscreenController();

    final restored = controller.restoreAfterFailedExit();

    expect(restored.isFullScreen, isTrue);
    expect(restored.viewModeName, 'fullscreen');
    expect(restored.fullscreenPhase, FullscreenPhase.fullscreen);
  });
}
