import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

void runRootApp(Widget app) {
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    runMultiApp(home: (context, viewId) => app);
    return;
  }
  runApp(app);
}
