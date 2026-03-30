import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late MockImageRepository mockRepository;
  late ProviderContainer container;

  setUp(() async {
    mockRepository = MockImageRepository();
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        imageRepositoryProvider.overrideWithValue(mockRepository),
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ImageListProvider', () {
    test('initial state is loading and then data', () async {
      final image = Image(
        id: '1',
        title: 'Test',
        files: [],
        paths: const ImagePaths(image: 'test.jpg'),
      );
      mockRepository.withData([image]);

      final state = container.read(imageListProvider);
      expect(state, const AsyncValue<List<Image>>.loading());

      final result = await container.read(imageListProvider.future);
      expect(result, [image]);
    });

    test('MediaViewToggle persists state', () async {
      final toggle = container.read(mediaViewToggleProvider.notifier);
      expect(container.read(mediaViewToggleProvider), MediaViewType.images);

      await toggle.toggle();
      expect(container.read(mediaViewToggleProvider), MediaViewType.galleries);

      // Create new container to check persistence
      final sharedPrefs = await SharedPreferences.getInstance();
      final newContainer = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      );
      expect(
        newContainer.read(mediaViewToggleProvider),
        MediaViewType.galleries,
      );
    });

    test('ImageSort persists state', () async {
      final sort = container.read(imageSortProvider.notifier);
      sort.setSort(sort: 'rating', descending: false);
      await sort.saveAsDefault();

      // Create new container to check persistence
      final sharedPrefs = await SharedPreferences.getInstance();
      final newContainer = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      );
      final sortState = newContainer.read(imageSortProvider);
      expect(sortState.sort, 'rating');
      expect(sortState.descending, false);
    });
  });
}
