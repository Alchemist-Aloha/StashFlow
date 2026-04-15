import 'dart:js_interop';

@JS('document')
external _Document get _document;

extension type _Document(JSObject _) implements JSObject {
  external _Element? get documentElement;
  external _Element? get fullscreenElement;
  external void exitFullscreen();
}

extension type _Element(JSObject _) implements JSObject {
  external void requestFullscreen();
}

Future<void> enterWebFullScreen() async {
  final element = _document.documentElement;
  if (element != null) {
    try {
      element.requestFullscreen();
    } catch (_) {}
  }
}

Future<void> exitWebFullScreen() async {
  if (_document.fullscreenElement != null) {
    try {
      _document.exitFullscreen();
    } catch (_) {}
  }
}
