import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/gallery_strip.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_strip.dart';

import '../../../helpers/test_helpers.dart';

const _title = 'Fablegrove Field Notes — Portfolio A, Extended Edition';
const _studio = 'Silverlake Lantern Studio';

final _scene = Scene(
  id: 's1',
  title: _title,
  date: DateTime(2024),
  rating100: null,
  oCounter: 0,
  organized: false,
  interactive: false,
  resumeTime: null,
  playCount: 0,
  playDuration: 0,
  files: const [],
  paths: const ScenePaths(screenshot: null, preview: null, stream: null),
  urls: const [],
  studioId: 'st1',
  studioName: _studio,
  studioImagePath: null,
  performerIds: const ['p1'],
  performerNames: const ['Remy Silverlake'],
  performerImagePaths: const [null],
  tagIds: const [],
  tagNames: const [],
);

const _gallery = Gallery(
  id: 'g1',
  title: _title,
  studioName: _studio,
  performerIds: ['p1'],
  performerNames: ['Remy Silverlake'],
  performerImagePaths: [null],
);

void main() {
  final strips = <String, Widget Function()>{
    'scene': () => SceneStrip(scenes: [_scene]),
    'gallery': () => const GalleryStrip(galleries: [_gallery]),
  };

  for (final MapEntry(key: name, value: strip) in strips.entries) {
    for (final scale in [0.8, 1.0, 1.5]) {
      for (final textScale in [1.0, 1.3]) {
        testWidgets('$name strip fits its card ($scale, text $textScale)', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(tester.view.reset);
          await pumpTestWidget(
            tester,
            child: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: Theme(
                  data: AppTheme.buildTheme(
                    Brightness.light,
                    Colors.teal,
                    fontSizeFactor: scale,
                  ),
                  child: Scaffold(body: Center(child: strip())),
                ),
              ),
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
          final row = tester.getRect(find.byType(ListView));
          final subtitle = tester.getRect(find.text(_studio));
          // Only the card's 4px bottom padding (plus rounding) remains, and
          // for scenes the reserved resume-bar room.
          final reserve = name == 'scene'
              ? tester.element(find.byType(ListView)).dimensions.spacingSmall /
                    2
              : 0;
          expect(
            row.bottom - subtitle.bottom,
            inInclusiveRange(0, 5 + reserve),
          );
        });
      }
    }
  }
}
