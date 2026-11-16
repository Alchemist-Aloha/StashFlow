import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// First-run dialogs that each appear at most once per install.
///
/// Saving the first server profile arms every tip (`true`). A screen consumes
/// its tip before showing the dialog (`false`), so dismissal, a crash, or a
/// rebuild never shows it twice. An absent key means the install predates the
/// tips or has no server yet, and nothing is shown. The Develop settings page
/// re-arms all tips for testing.
enum OneTimeTip {
  sceneViewMode('scene_view_mode_prompt_pending'),
  sceneGrid('tip_scene_grid_pending'),
  sceneFeed('tip_scene_feed_pending'),
  sceneDetails('tip_scene_details_pending'),
  imageViewer('tip_image_viewer_pending');

  const OneTimeTip(this.key);

  /// Preference key holding this tip's pending state.
  final String key;

  bool isPending(SharedPreferences prefs) => prefs.getBool(key) == true;

  /// Marks the tip shown and returns whether it was pending.
  ///
  /// The in-memory preference updates synchronously, so later rebuilds in the
  /// same frame already see the tip as consumed.
  bool consume(SharedPreferences prefs) {
    if (!isPending(prefs)) return false;
    unawaited(prefs.setBool(key, false));
    return true;
  }

  /// Arms every tip; without [force], only on installs that never armed them.
  static Future<void> armAll(
    SharedPreferences prefs, {
    bool force = false,
  }) async {
    for (final tip in values) {
      if (force || !prefs.containsKey(tip.key)) {
        await prefs.setBool(tip.key, true);
      }
    }
  }
}
