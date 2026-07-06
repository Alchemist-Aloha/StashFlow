import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/providers/list_scroll_controller_provider.dart';

void main() {
  group('entity scroll controller providers', () {
    for (final target in [ListScrollTarget.image, ListScrollTarget.gallery]) {
      test(
        '$target scroll controller remains stable without active listeners',
        () async {
          final container = ProviderContainer();
          addTearDown(container.dispose);
          final provider = listScrollControllerProvider(target);

          final subscription = container.listen(
            provider,
            (_, _) {},
            fireImmediately: true,
          );
          final firstController = subscription.read();

          subscription.close();
          await container.pump();

          expect(container.read(provider), same(firstController));
        },
      );
    }
  });
}
