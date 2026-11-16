import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/preview_video_controls_theme.dart';

void main() {
  testWidgets('preview control insets follow live UI scale on both platforms', (
    tester,
  ) async {
    final scale = ValueNotifier(0.8);
    addTearDown(scale.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<double>(
          valueListenable: scale,
          child: const PreviewVideoControlsTheme(child: SizedBox()),
          builder: (context, factor, child) => Theme(
            data: AppTheme.buildTheme(
              Brightness.dark,
              Colors.teal,
              fontSizeFactor: factor,
            ),
            child: child!,
          ),
        ),
      ),
    );

    for (final factor in [0.8, 1.0, 1.5]) {
      scale.value = factor;
      await tester.pump();
      final mobile = tester.widget<MaterialVideoControlsTheme>(
        find.byType(MaterialVideoControlsTheme),
      );
      final desktop = tester.widget<MaterialDesktopVideoControlsTheme>(
        find.byType(MaterialDesktopVideoControlsTheme),
      );
      final seekMargin = EdgeInsets.fromLTRB(
        12 * factor,
        0,
        12 * factor,
        8 * factor,
      );
      expect(
        mobile.normal.bottomButtonBarMargin,
        seekMargin.copyWith(right: 4 * factor),
      );
      expect(mobile.normal.seekBarMargin, seekMargin);
      expect(desktop.normal.bottomButtonBarMargin, seekMargin);
      expect(desktop.normal.seekBarMargin, seekMargin);
      expect(mobile.fullscreen, same(mobile.normal));
      expect(desktop.fullscreen, same(desktop.normal));
      expect(tester.takeException(), isNull);
    }
  });
}
