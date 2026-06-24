import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/entity_gallery_filter_scope.dart';

void main() {
  Future<({ProviderContainer container, SharedPreferences prefs})>
  createContainer(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return (container: container, prefs: prefs);
  }

  test('defaults entity image filtering to direct entity metadata', () async {
    final testContext = await createContainer({});

    expect(
      testContext.container.read(entityImageFilterMethodSettingProvider),
      EntityImageFilterMethod.directEntity,
    );
  });

  test('persists the related galleries method', () async {
    final testContext = await createContainer({});

    await testContext.container
        .read(entityImageFilterMethodSettingProvider.notifier)
        .set(EntityImageFilterMethod.relatedGalleries);

    expect(
      testContext.prefs.getString(entityImageFilterMethodPreferenceKey),
      EntityImageFilterMethod.relatedGalleries.name,
    );
  });
}
