import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/studios/domain/entities/studio.dart';
import 'package:stash_app_flutter/features/studios/presentation/pages/studios_page.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_list_provider.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  const testStudio = Studio(
    id: 's1',
    name: 'Test Studio',
    sceneCount: 10,
    imageCount: 0,
    galleryCount: 0,
    performerCount: 2,
    favorite: false,
  );

  testWidgets('StudiosPage displays list of studios', (tester) async {
    final mockRepo = MockStudioRepository()..withData([testStudio]);
    
    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [studioRepositoryProvider.overrideWithValue(mockRepo)],
      child: const StudiosPage(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Test Studio'), findsOneWidget);
  });
}
