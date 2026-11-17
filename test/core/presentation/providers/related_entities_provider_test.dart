import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/providers/related_entities_provider.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer_filter.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';

import '../../../helpers/test_helpers.dart';

class _RecordingPerformerRepository extends MockGraphQLPerformerRepository {
  PerformerFilter? lastFilter;

  @override
  Future<List<Performer>> findPerformers({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    PerformerFilter? performerFilter,
  }) async {
    lastFilter = performerFilter;
    return data;
  }
}

Performer _performer(String id) => Performer(
  id: id,
  name: 'Performer $id',
  urls: const [],
  birthdate: null,
  aliasList: const [],
  favorite: false,
  imagePath: null,
  sceneCount: 0,
  imageCount: 0,
  galleryCount: 0,
  groupCount: 0,
  tagIds: const [],
  tagNames: const [],
);

void main() {
  test('appears-with lists co-performers, never the performer', () async {
    final repository = _RecordingPerformerRepository()
      ..setData([_performer('1'), _performer('2')]);
    final container = ProviderContainer(
      overrides: [performerRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final related = await container.read(
      relatedEntitiesProvider((
        kind: RelatedEntityKind.performers,
        owner: RelatedEntityOwner.performer,
        id: '1',
      )).future,
    );

    expect(repository.lastFilter?.performers?.value, ['1']);
    expect(related.map((entity) => entity.id), ['2']);
    expect(related.single.route, '/performers/performer/2');
  });
}
