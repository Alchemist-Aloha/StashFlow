import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class DesktopFullscreen {
  DesktopFullscreen._();

  static final instance = DesktopFullscreen._();

  static const _windowsChannel = MethodChannel(
    'stash_app_flutter/window_fullscreen',
  );

  Future<void> enter() {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return _windowsChannel.invokeMethod<void>('enter');
    }
    return windowManager.setFullScreen(true);
  }

  Future<void> exit() {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return _windowsChannel.invokeMethod<void>('exit');
    }
    return windowManager.setFullScreen(false);
  }
}
