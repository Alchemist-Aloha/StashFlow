import 'dart:io';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';
import 'package:stash_app_flutter/features/performers/presentation/widgets/performer_placeholder.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  test('rotates through existing assets by id and gender', () {
    final female = {
      for (var i = 0; i < 60; i++) performerPlaceholderAsset('$i', 'FEMALE'),
    };
    final male = {
      for (var i = 0; i < 10; i++) performerPlaceholderAsset('$i', 'MALE'),
    };
    expect(female, hasLength(30));
    expect(male, hasLength(5));
    for (final path in [...female, ...male]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
    expect(
      performerPlaceholderAsset('7', null),
      isNot(performerPlaceholderAsset('8', null)),
    );
    expect(performerPlaceholderAsset('abc', null), contains('/female/'));
  });

  testWidgets('Stash SVG defaults show the bundled placeholder', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      child: StashImage(
        imageUrl: 'http://h/performer/49/image?t=1&default=true',
        placeholderAsset: performerPlaceholderAsset('2', 'MALE'),
      ),
    );
    await tester.pump();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });
}
