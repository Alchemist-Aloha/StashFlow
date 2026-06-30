import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';

void main() {
  group('entity scroll controller providers', () {
    test(
      'image scroll controller remains stable without active listeners',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          imageScrollControllerProvider,
          (_, _) {},
          fireImmediately: true,
        );
        final firstController = subscription.read();

        subscription.close();
        await container.pump();

        expect(
          container.read(imageScrollControllerProvider),
          same(firstController),
        );
      },
    );

    test(
      'gallery scroll controller remains stable without active listeners',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          galleryScrollControllerProvider,
          (_, _) {},
          fireImmediately: true,
        );
        final firstController = subscription.read();

        subscription.close();
        await container.pump();

        expect(
          container.read(galleryScrollControllerProvider),
          same(firstController),
        );
      },
    );
  });
}
