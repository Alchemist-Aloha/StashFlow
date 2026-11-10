import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart';

void main() {
  for (final (typename, format, path, isGif, isClip) in [
    ('ImageFile', 'mjpeg', '/images/still.jpg', false, false),
    ('ImageFile', 'gif', '/images/animation.gif', true, false),
    ('VideoFile', 'gif', '/images/animation', true, false),
    ('VideoFile', 'GIF', '/images/animation.dat', true, false),
    ('VideoFile', null, r'C:\images\ANIMATION.GiF', true, false),
    ('VideoFile', null, '/gallery.zip/images/animation.gif', true, false),
    ('VideoFile', 'matroska,webm', '/images/clip.webm', false, true),
    ('VideoFile', null, '/images/clip', false, true),
    ('ImageFile', null, '/images/unknown', false, false),
  ]) {
    test('$typename format=$format path=$path chooses the correct decoder', () {
      final image = Image(
        id: 'image',
        files: [
          ImageFile(
            width: 320,
            height: 240,
            path: path,
            typename: typename,
            format: format,
          ),
        ],
        paths: const ImagePaths(),
      );
      expect(image.isGif, isGif);
      expect(image.isClip, isClip);
      final restored = Image.fromJson(image.toJson());
      expect(restored.isGif, isGif);
      expect(restored.isClip, isClip);
    });
  }

  test('missing files do not select a decoder', () {
    const image = Image(id: 'empty', files: [], paths: ImagePaths());
    expect(image.isGif, isFalse);
    expect(image.isClip, isFalse);
  });

  test('only the primary file determines the decoder', () {
    const image = Image(
      id: 'clip',
      files: [
        ImageFile(
          width: 320,
          height: 240,
          path: 'clip.mp4',
          typename: 'VideoFile',
        ),
        ImageFile(
          width: 320,
          height: 240,
          path: 'animation.gif',
          format: 'gif',
        ),
      ],
      paths: ImagePaths(),
    );
    expect(image.isGif, isFalse);
    expect(image.isClip, isTrue);
  });
}
