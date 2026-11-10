/// Desktop window operations are unavailable on the web.
class DesktopWindow {
  DesktopWindow._();

  static final instance = DesktopWindow._();

  Future<void> initialize() async =>
      throw UnsupportedError('Desktop windows are unavailable on the web');

  Future<void> setFullScreen(bool fullscreen) async =>
      throw UnsupportedError('Desktop fullscreen is unavailable on the web');
}
