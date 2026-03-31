import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/tiktok_scenes_view.dart';

void main() {
  group('FullScreenMode', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is false', () {
      final isFullScreen = container.read(fullScreenModeProvider);
      expect(isFullScreen, isFalse);
    });

    test('toggle changes state', () {
      final isFullScreenInitial = container.read(fullScreenModeProvider);
      expect(isFullScreenInitial, isFalse);

      container.read(fullScreenModeProvider.notifier).toggle();
      final isFullScreenAfterToggle = container.read(fullScreenModeProvider);
      expect(isFullScreenAfterToggle, isTrue);

      container.read(fullScreenModeProvider.notifier).toggle();
      final isFullScreenAfterSecondToggle = container.read(
        fullScreenModeProvider,
      );
      expect(isFullScreenAfterSecondToggle, isFalse);
    });

    test('set updates state to specific value', () {
      final isFullScreenInitial = container.read(fullScreenModeProvider);
      expect(isFullScreenInitial, isFalse);

      container.read(fullScreenModeProvider.notifier).set(true);
      final isFullScreenAfterSetTrue = container.read(fullScreenModeProvider);
      expect(isFullScreenAfterSetTrue, isTrue);

      container.read(fullScreenModeProvider.notifier).set(false);
      final isFullScreenAfterSetFalse = container.read(fullScreenModeProvider);
      expect(isFullScreenAfterSetFalse, isFalse);
    });
  });
}
