import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_performer_title.dart';

void main() {
  group('ageAtSceneYear', () {
    test('uses the exact birthday when available', () {
      expect(
        ageAtSceneYear(
          sceneDate: DateTime(2020, 1, 1),
          birthdate: '2000-12-31',
        ),
        19,
      );
      expect(
        ageAtSceneYear(sceneDate: DateTime(2020, 6, 1), birthdate: '2000'),
        20,
      );
    });

    test('omits missing invalid and future birthdates', () {
      final sceneDate = DateTime(2020, 6, 1);
      expect(ageAtSceneYear(sceneDate: sceneDate, birthdate: null), isNull);
      expect(ageAtSceneYear(sceneDate: sceneDate, birthdate: ''), isNull);
      expect(
        ageAtSceneYear(sceneDate: sceneDate, birthdate: 'unknown'),
        isNull,
      );
      expect(
        ageAtSceneYear(sceneDate: sceneDate, birthdate: '2021-01-01'),
        isNull,
      );
      expect(
        ageAtSceneYear(sceneDate: sceneDate, birthdate: '2000-02-30'),
        isNull,
      );
    });
  });

  testWidgets('renders age after name with muted theme color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: ScenePerformerTitle(
            performerName: 'Alice',
            sceneDate: DateTime(2020, 1, 1),
            birthdate: '2000-12-31',
          ),
        ),
      ),
    );

    expect(find.text('Alice (19)', findRichText: true), findsOneWidget);
    final text = tester.widget<Text>(find.byType(Text));
    final rootSpan = text.textSpan! as TextSpan;
    final ageSpan = rootSpan.children![1] as TextSpan;
    final context = tester.element(find.byType(ScenePerformerTitle));
    expect(ageSpan.text, ' (19)');
    expect(
      ageSpan.style?.color,
      Theme.of(context).colorScheme.onSurfaceVariant,
    );
  });

  testWidgets('renders only the name when age is unavailable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: ScenePerformerTitle(
            performerName: 'Alice',
            sceneDate: DateTime(2020, 1, 1),
          ),
        ),
      ),
    );

    expect(find.text('Alice', findRichText: true), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'\(\d+\)'), findRichText: true),
      findsNothing,
    );
  });
}
