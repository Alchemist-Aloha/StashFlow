import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  test('GroupMediaProvider filters scenes by selected group id', () async {
    final repository = MockGraphQLSceneRepository();
    final container = ProviderContainer(
      overrides: [sceneRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(
      entityMediaPreviewProvider(EntityMediaFilterKind.group, 'group-1').future,
    );

    expect(repository.lastFindScenesPage, 1);
    expect(repository.lastFindScenesPerPage, 24);
    expect(repository.lastFindScenesSceneFilter?.groups?.value, ['group-1']);
  });
}
