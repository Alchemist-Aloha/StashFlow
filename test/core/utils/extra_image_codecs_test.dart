import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/utils/extra_image_codecs.dart';

import '../../helpers/extra_image_fixtures.dart';

Future<(int, int, Uint8List)> _firstFrame(ui.Codec codec) async {
  final image = (await codec.getNextFrame()).image;
  final data = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  return (image.width, image.height, data!.buffer.asUint8List());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sniffs AVIF and JPEG XL signatures only', () {
    expect(sniffExtraImageFormat(avifFixture), ExtraImageFormat.avif);
    expect(sniffExtraImageFormat(jxlFixture), ExtraImageFormat.jxl);
    final container = Uint8List.fromList([
      0,
      0,
      0,
      0x0C,
      ...'JXL '.codeUnits,
      0x0D,
      0x0A,
      0x87,
      0x0A,
    ]);
    expect(sniffExtraImageFormat(container), ExtraImageFormat.jxl);
    // HEIC shares the ftyp box but must stay with the engine codec.
    final heic = Uint8List.fromList([
      0,
      0,
      0,
      0x18,
      ...'ftypheic'.codeUnits,
      0,
      0,
      0,
      0,
      ...'mif1heic'.codeUnits,
    ]);
    expect(sniffExtraImageFormat(heic), isNull);
    expect(
      sniffExtraImageFormat(Uint8List.fromList([0xFF, 0xD8, 0xFF])),
      isNull,
    );
  });

  for (final (name, bytes) in [
    ('AVIF', avifFixture),
    ('JPEG XL', jxlFixture),
  ]) {
    test('transcodes $name with alpha to an engine-decodable image', () async {
      final bmp = await transcodeExtraImageFormat(bytes);
      final codec = await ui.instantiateImageCodec(bmp!);
      final (w, h, rgba) = await _firstFrame(codec);
      expect((w, h), (16, 12));
      expect(rgba[0], greaterThan(235));
      expect(rgba[1], lessThan(20));
      expect(rgba[3], inInclusiveRange(118, 138));
    });
  }

  test('returns null for formats the engine handles', () async {
    expect(
      await transcodeExtraImageFormat(Uint8List.fromList([0xFF, 0xD8])),
      isNull,
    );
  });
}
