import 'dart:ui' show ViewFocusDirection, ViewFocusEvent, ViewFocusState;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

void runRootApp(Widget app) {
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    runMultiApp(
      home: (context, viewId) => app,
      config: MultiAppConfig(
        observers: [
          if (defaultTargetPlatform == TargetPlatform.linux)
            LinuxWindowFocusObserver(
              (id) => MultiViewDesktop.fromId(id).internalViewId,
            ),
        ],
      ),
    );
    return;
  }
  runApp(app);
}

/// Bridges GTK window activation to Flutter's per-view keyboard focus.
///
/// The Linux embedder does not currently emit view-focus events itself.
class LinuxWindowFocusObserver extends WindowObserver {
  /// Resolves plugin public IDs to Flutter view IDs (which shift on restart).
  LinuxWindowFocusObserver(this.resolveViewId);

  final int Function(int publicViewId) resolveViewId;

  @override
  void onWindowEvent(int viewId, String eventName) {
    if (eventName != 'focus' && eventName != 'blur') return;
    final event = ViewFocusEvent(
      viewId: resolveViewId(viewId),
      state: eventName == 'focus'
          ? ViewFocusState.focused
          : ViewFocusState.unfocused,
      direction: ViewFocusDirection.undefined,
    );
    final binding = WidgetsBinding.instance;
    // GTK can activate a new window before its Flutter View is mounted.
    binding.addPostFrameCallback((_) => binding.handleViewFocusChanged(event));
    binding.ensureVisualUpdate();
  }

  @override
  void onDialogEvent(int viewId, String eventName) =>
      onWindowEvent(viewId, eventName);
}
