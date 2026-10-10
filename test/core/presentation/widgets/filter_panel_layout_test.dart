import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_widgets.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/gallery_filter_panel.dart';
import 'package:stash_app_flutter/features/groups/presentation/widgets/group_filter_panel.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_filter_panel.dart';
import 'package:stash_app_flutter/features/performers/presentation/widgets/performer_filter_panel.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_filter_panel.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_marker_filter_panel.dart';
import 'package:stash_app_flutter/features/studios/presentation/widgets/studio_filter_panel.dart';
import 'package:stash_app_flutter/features/tags/presentation/widgets/tag_filter_panel.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('Inter')
      ..addFont(rootBundle.load('asset/fonts/inter/Inter.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  final panels = <String, Widget>{
    'scene': const SceneFilterPanel(),
    'image': const ImageFilterPanel(),
    'gallery': const GalleryFilterPanel(),
    'performer': const PerformerFilterPanel(),
    'studio': const StudioFilterPanel(),
    'tag': const TagFilterPanel(),
    'group': const GroupFilterPanel(),
    'marker': const SceneMarkerFilterPanel(),
  };

  for (final entry in panels.entries) {
    for (final width in [360.0, 800.0]) {
      for (final scale in [0.8, 1.0, 1.5]) {
        testWidgets('${entry.key} labels and dropdowns at $width / $scale', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 1000);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          final captureKey = GlobalKey();
          await tester.pumpWidget(
            ProviderScope(
              overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
              child: MaterialApp(
                theme: AppTheme.buildTheme(
                  width == 360 ? Brightness.dark : Brightness.light,
                  const Color(0xFF0F766E),
                  fontSizeFactor: scale,
                  fontFamily: 'Inter',
                ),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: const Locale('de'),
                home: Scaffold(
                  body: RepaintBoundary(key: captureKey, child: entry.value),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final dropdowns = find.byWidgetPredicate(
            (widget) => widget is FilterDropdown,
          );
          if (dropdowns.evaluate().isNotEmpty) {
            await tester.tap(dropdowns.first);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.tapAt(Offset(width - 1, 1));
            await tester.pumpAndSettle();
          }

          // Optional renderer captures for a bounded visual inspection pass.
          final captureDir = Platform.environment['FILTER_PANEL_CAPTURE_DIR'];
          if (captureDir != null && scale == 1) {
            await tester.runAsync(() async {
              final boundary =
                  captureKey.currentContext!.findRenderObject()
                      as RenderRepaintBoundary;
              final image = await boundary.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await Directory(captureDir).create(recursive: true);
              await File(
                '$captureDir/${entry.key}-$width.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }

          for (final section
              in find.byType(FilterSection).evaluate().toList()) {
            final widget = section.widget as FilterSection;
            if (!widget.initiallyExpanded) {
              final header = find.descendant(
                of: find.byWidget(widget),
                matching: find.byType(ExpansionTile),
              );
              await tester.ensureVisible(header);
              await tester.tap(
                find
                    .descendant(of: header, matching: find.text(widget.title))
                    .first,
              );
              await tester.pumpAndSettle();
            }
            for (final fieldElement
                in find
                    .descendant(
                      of: find.byWidget(widget),
                      matching: find.byType(FilterField),
                    )
                    .evaluate()) {
              final field = find.byWidget(fieldElement.widget);
              final label = find
                  .descendant(of: field, matching: find.byType(Text))
                  .first;
              expect(tester.widget<Text>(label).textAlign, TextAlign.start);
              expect(tester.getTopLeft(label).dx, tester.getTopLeft(field).dx);
              for (final dropdown
                  in find
                      .descendant(
                        of: field,
                        matching: find.byWidgetPredicate(
                          (widget) => widget is FilterDropdown,
                        ),
                      )
                      .evaluate()) {
                final dropdownFinder = find.byWidget(dropdown.widget);
                expect(
                  tester.getSize(dropdownFinder).width,
                  tester.getSize(field).width,
                );
                expect(
                  tester.getSize(dropdownFinder).height,
                  greaterThanOrEqualTo(kMinInteractiveDimension),
                );
              }
            }
            expect(tester.takeException(), isNull);
          }
        });
      }
    }
  }
}
