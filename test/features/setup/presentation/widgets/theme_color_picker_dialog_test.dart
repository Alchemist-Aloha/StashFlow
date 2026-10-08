import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/theme_color_picker_dialog.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Inter')
      ..addFont(rootBundle.load('asset/fonts/inter/Inter.ttf'));
    await font.load();
  });

  Future<void> openPicker(
    WidgetTester tester, {
    Color initialColor = const Color(0xFF0F766E),
    ValueChanged<Color?>? onClosed,
    double scale = 1,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('color-picker-capture'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildTheme(
            brightness,
            const Color(0xFF0F766E),
            fontSizeFactor: scale,
            fontFamily: 'Inter',
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final color = await showDialog<Color>(
                    context: context,
                    builder: (_) =>
                        ThemeColorPickerDialog(initialColor: initialColor),
                  );
                  onClosed?.call(color);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Color preview(WidgetTester tester) =>
      (tester
                  .widget<Container>(
                    find.byKey(const Key('theme-color-preview')),
                  )
                  .decoration!
              as BoxDecoration)
          .color!;

  testWidgets('RGB hex synchronizes preview and HSV controls and applies', (
    tester,
  ) async {
    Color? result;
    await openPicker(tester, onClosed: (color) => result = color);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'FF0F766E',
    );
    await tester.enterText(find.byType(TextField), '#00ff00');
    await tester.pump();
    expect(preview(tester), const Color(0xFF00FF00));
    final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
    expect(sliders[0].value, closeTo(1 / 3, 0.001));
    expect(sliders[1].value, 1);
    expect(sliders[2].value, 1);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(result, const Color(0xFF00FF00));
  });

  testWidgets('invalid hex cannot apply and cancel returns no color', (
    tester,
  ) async {
    Color? result;
    await openPicker(tester, onClosed: (color) => result = color);
    for (final input in ['GG00FF', '12345', '100000000', '-123456', '']) {
      await tester.enterText(find.byType(TextField), input);
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration!.errorText,
        isNotNull,
      );
    }
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets('visual controls update hex and preserve entered alpha', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.enterText(find.byType(TextField), '8000FF00');
    await tester.pump();
    tester.widget<Slider>(find.byType(Slider).first).onChanged!(2 / 3);
    await tester.pump();
    expect(preview(tester), const Color(0x800000FF));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '800000FF',
    );
    tester.widget<Slider>(find.byType(Slider).at(1)).onChanged!(0);
    await tester.pump();
    expect(preview(tester), const Color(0x80FFFFFF));
    tester.widget<Slider>(find.byType(Slider).last).onChanged!(0);
    await tester.pump();
    expect(preview(tester), const Color(0x80000000));
  });

  testWidgets('color sliders can be adjusted with the keyboard', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final previous = tester.widget<Slider>(find.byType(Slider).first).value;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(
      tester.widget<Slider>(find.byType(Slider).first).value,
      greaterThan(previous),
    );
  });

  for (final size in [const Size(360, 700), const Size(800, 500)]) {
    for (final scale in [0.8, 1.5]) {
      testWidgets('picker fits $size at scale $scale with keyboard', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetViewInsets);
        await openPicker(
          tester,
          scale: scale,
          brightness: size.width == 360 ? Brightness.dark : Brightness.light,
        );
        expect(tester.takeException(), isNull);
        final directory = Platform.environment['COLOR_PICKER_CAPTURE_DIR'];
        if (directory != null) {
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const Key('color-picker-capture')),
            );
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory(directory).create(recursive: true);
            await File(
              '$directory/${size.width}-$scale.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        tester.view.viewInsets = const FakeViewPadding(bottom: 180);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(EditableText));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(EditableText));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .focusNode
              .hasFocus,
          true,
        );
        await tester.enterText(find.byType(TextField), '112233');
        await tester.pump();
        expect(preview(tester), const Color(0xFF112233));
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(find.byType(ThemeColorPickerDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
