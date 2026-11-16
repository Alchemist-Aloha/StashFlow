import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final desktopCapabilitiesProvider = Provider<bool>((ref) {
  if (kIsWeb) return true;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
});
