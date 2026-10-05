import 'package:flutter/widgets.dart';

import 'root_app_runner_web.dart'
    if (dart.library.io) 'root_app_runner_native.dart'
    as platform;

/// Runs the root app with the desktop multi-view shell on native platforms.
void runRootApp(Widget app) => platform.runRootApp(app);
