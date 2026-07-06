import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_marker.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_marker_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_markers_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_marker_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_marker_card.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  testWidgets('renders scene marker cards from the repository', (tester) async {
    final repository = _FakeGraphQLSceneMarkerRepository([
      _marker(
        title: 'Opening beat',
        seconds: 65,
        endSeconds: 95,
        primaryTagName: 'Intro',
      ),
    ]);

    await _pumpPage(tester, repository);

    expect(find.text('Markers'), findsOneWidget);
    expect(find.text('Opening beat'), findsOneWidget);
    expect(find.text('01:05 - 01:35'), findsOneWidget);
    expect(find.text('Test Scene'), findsOneWidget);
    expect(find.text('Intro'), findsOneWidget);
  });

  testWidgets('sort sheet forwards marker sort to repository', (tester) async {
    final repository = _FakeGraphQLSceneMarkerRepository([_marker()]);

    await _pumpPage(tester, repository);

    await tester.tap(find.byTooltip('Sort'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marker time'));
    await tester.tap(find.text('Ascending'));
    await tester.tap(find.text('Apply Sort'));
    await tester.pumpAndSettle();

    expect(repository.calls.last.sort, 'seconds');
    expect(repository.calls.last.descending, isFalse);
  });

  testWidgets('sort sheet exposes scene-style save default action', (
    tester,
  ) async {
    final repository = _FakeGraphQLSceneMarkerRepository([_marker()]);

    await _pumpPage(tester, repository);

    await tester.tap(find.byTooltip('Sort'));
    await tester.pumpAndSettle();

    expect(find.text('Apply Sort'), findsOneWidget);
    expect(find.text('Save as Default'), findsOneWidget);
  });

  testWidgets('filter panel uses page filter design and applies criteria', (
    tester,
  ) async {
    final repository = _FakeGraphQLSceneMarkerRepository([_marker()]);

    await _pumpPage(tester, repository);

    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();

    expect(find.text('Filter markers'), findsOneWidget);
    expect(find.text('Marker'), findsAtLeastNWidgets(1));
    expect(find.text('Scene'), findsAtLeastNWidgets(1));
    expect(find.text('Dates'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '30');
    await tester.ensureVisible(find.text('Dates'));
    await tester.tap(find.text('Dates'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '2024-01-01');
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    expect(repository.calls.last.filter.duration?.value, 30);
    expect(repository.calls.last.filter.createdAt?.value, '2024-01-01');
  });

  testWidgets('filter panel exposes scene-style save default action', (
    tester,
  ) async {
    final repository = _FakeGraphQLSceneMarkerRepository([_marker()]);

    await _pumpPage(tester, repository);

    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();

    expect(find.text('Apply Filters'), findsOneWidget);
    expect(find.text('Save as Default'), findsOneWidget);
  });

  testWidgets('marker list exposes saved presets action', (tester) async {
    final repository = _FakeGraphQLSceneMarkerRepository([_marker()]);

    await _pumpPage(tester, repository);

    expect(find.byTooltip('Saved filters'), findsOneWidget);
  });

  testWidgets('respects persisted list layout preference', (tester) async {
    SharedPreferences.setMockInitialValues({'scene_marker_grid_layout': false});
    final prefs = await SharedPreferences.getInstance();
    final repository = _FakeGraphQLSceneMarkerRepository([_marker()]);

    await _pumpPage(tester, repository, prefs: prefs);

    expect(
      tester.widget<SceneMarkerCard>(find.byType(SceneMarkerCard)).isGrid,
      isFalse,
    );
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  _FakeGraphQLSceneMarkerRepository repository, {
  SharedPreferences? prefs,
}) async {
  await pumpTestWidget(
    tester,
    prefs: prefs,
    overrides: [sceneMarkerRepositoryProvider.overrideWithValue(repository)],
    child: const SceneMarkersPage(),
  );
  await tester.pumpAndSettle();
}

SceneMarkerSummary _marker({
  String id = 'marker-1',
  String title = 'Marker',
  double seconds = 10,
  double? endSeconds,
  String? primaryTagName,
}) {
  return SceneMarkerSummary(
    id: id,
    title: title,
    seconds: seconds,
    endSeconds: endSeconds,
    screenshot: null,
    preview: null,
    stream: null,
    primaryTagName: primaryTagName,
    tagNames: primaryTagName == null ? const [] : [primaryTagName],
    sceneId: 'scene-1',
    sceneTitle: 'Test Scene',
    performerNames: const ['Performer'],
  );
}

class _FakeGraphQLSceneMarkerRepository
    implements GraphQLSceneMarkerRepository {
  _FakeGraphQLSceneMarkerRepository(this.markers);

  final List<SceneMarkerSummary> markers;
  final List<
    ({
      int? page,
      int? perPage,
      String? searchQuery,
      String? sort,
      bool descending,
      SceneMarkerFilter filter,
    })
  >
  calls = [];

  @override
  Future<List<SceneMarkerSummary>> findSceneMarkers({
    int? page,
    int? perPage,
    String? searchQuery,
    String? sort,
    bool descending = true,
    SceneMarkerFilter filter = const SceneMarkerFilter(),
  }) async {
    calls.add((
      page: page,
      perPage: perPage,
      searchQuery: searchQuery,
      sort: sort,
      descending: descending,
      filter: filter,
    ));
    return markers;
  }
}
