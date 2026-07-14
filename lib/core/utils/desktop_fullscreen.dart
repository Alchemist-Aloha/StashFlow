import 'package:window_manager/window_manager.dart';

class DesktopFullscreen {
  DesktopFullscreen._();

  static final instance = DesktopFullscreen._();

  Future<void> enter() => windowManager.setFullScreen(true);

  Future<void> exit() => windowManager.setFullScreen(false);
}
