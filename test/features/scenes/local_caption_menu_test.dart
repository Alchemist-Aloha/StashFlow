import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_caption_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/local_captions_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/local_caption_overlay.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/subtitle_presentation.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/video_controls/scene_subtitle_menu.dart';
import '../../helpers/test_helpers.dart';

class _Scene extends Fake implements Scene {
  @override
  String get id => 'scene';
  @override
  List<VideoCaption> get captions => const [];
}

class _Player extends Fake implements mk.Player {}

class _Controller extends Fake implements VideoController {
  _Controller(this.player);
  @override
  final mk.Player player;
}

class _Playback extends PlayerState {
  _Playback(this.player, this.scene);
  final mk.Player player;
  final Scene scene;
  bool exited = false, synchronized = false;
  @override
  GlobalPlayerState build() =>
      GlobalPlayerState(player: player, activeScene: scene, isFullScreen: true);
  @override
  void requestExitFullscreen() {
    exited = true;
  }

  @override
  void syncBackgroundToActiveScene(BuildContext context) {
    synchronized = true;
  }
}

class _Models extends LocalCaptionSettingsNotifier {
  _Models(this.downloaded);
  final bool downloaded;
  @override
  LocalCaptionSettings build() => LocalCaptionSettings(
    loading: false,
    installed: downloaded ? {'zipformer-en', 'marian-en-zh'} : {},
    selected: 'zipformer-en',
    translation: 'marian-en-zh',
  );
}

class _Captions extends LocalCaptionsNotifier {
  _Captions(this.player);
  final mk.Player player;
  LocalCaptionMode get mode => state.mode;
  @override
  LocalCaptions build() => const LocalCaptions();
  @override
  Future<void> setMode(LocalCaptionMode mode) async {
    state = LocalCaptions(
      mode: mode,
      player: player,
      frame: const CaptionFrame(CaptionStatus.ready, 'generated phrase'),
    );
  }

  @override
  Future<void> stop() async {
    state = const LocalCaptions();
  }
}

void main() {
  testWidgets(
    'one transcription action offers optional translation and None stops both',
    (tester) async {
      final player = _Player(), scene = _Scene();
      final captions = _Captions(player);
      final selected = <String?>[];
      await pumpTestWidget(
        tester,
        overrides: [
          playerStateProvider.overrideWith(() => _Playback(player, scene)),
          localCaptionSettingsProvider.overrideWith(() => _Models(true)),
          localCaptionsProvider.overrideWith(() => captions),
        ],
        child: Scaffold(
          body: Stack(
            children: [
              SceneSubtitleMenu(
                controller: _Controller(player),
                scene: scene,
                onSubtitleSelected: selected.add,
              ),
              GeneratedCaptionOverlay(player: player),
              GeneratedCaptionOverlay(player: _Player()),
            ],
          ),
        ),
      );
      await tester.tap(find.byTooltip('Select subtitle'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.ancestor(
          of: find.text('Transcribe audio'),
          matching: find.byType(CheckedPopupMenuItem<String>),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
      await tester.pumpAndSettle();
      expect(find.text('generated phrase'), findsOneWidget);
      final cue = tester.widget<Text>(find.text('generated phrase'));
      final presentation = subtitlePresentation(
        tester.element(find.text('generated phrase')),
        fontSize: 18,
        textAlign: TextAlign.center,
        bottomPadding: 0,
      );
      expect(cue.style, presentation.style);
      expect(cue.textAlign, presentation.textAlign);
      expect(cue.style!.fontSize, 18);
      expect(captions.mode, LocalCaptionMode.transcribe);
      await tester.tap(find.byTooltip('Select subtitle'));
      await tester.pumpAndSettle();
      expect(find.text('Translate audio'), findsNothing);
      expect(find.text('Manage subtitle models'), findsNothing);
      final action = tester.widget<CheckedPopupMenuItem<String>>(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Transcribe audio'),
      );
      expect(action.checked, isTrue);
      await tester.tap(
        find.ancestor(
          of: find.text('Transcribe audio'),
          matching: find.byType(CheckedPopupMenuItem<String>),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      final translate = find.widgetWithText(SwitchListTile, 'Translate audio');
      await tester.ensureVisible(translate);
      await tester.tap(translate);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
      await tester.pumpAndSettle();
      expect(captions.mode, LocalCaptionMode.translate);
      expect(find.text('generated phrase'), findsOneWidget);
      await tester.tap(find.byTooltip('Select subtitle'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CheckedPopupMenuItem<String>>(
              find.widgetWithText(
                CheckedPopupMenuItem<String>,
                'Transcribe audio',
              ),
            )
            .checked,
        isTrue,
      );
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Transcribe audio'),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(translate).value, isTrue);
      await tester.ensureVisible(translate);
      await tester.tap(translate);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(captions.mode, LocalCaptionMode.translate);
      await tester.tap(find.byTooltip('Select subtitle'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.ancestor(
          of: find.text('None'),
          matching: find.byType(CheckedPopupMenuItem<String>),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('generated phrase'), findsNothing);
      expect(selected, ['none']);
    },
  );

  testWidgets(
    'missing weights allow dialog recovery; model settings exit fullscreen first',
    (tester) async {
      final player = _Player(), scene = _Scene();
      final playback = _Playback(player, scene);
      await pumpTestWidget(
        tester,
        overrides: [
          playerStateProvider.overrideWith(() => playback),
          localCaptionSettingsProvider.overrideWith(() => _Models(false)),
          localCaptionsProvider.overrideWith(() => _Captions(player)),
        ],
        routes: [
          GoRoute(
            path: '/settings/playback',
            builder: (_, _) => const Text('Model settings route'),
          ),
        ],
        child: Scaffold(
          body: SceneSubtitleMenu(
            controller: _Controller(player),
            scene: scene,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Select subtitle'));
      await tester.pumpAndSettle();
      final disabled = tester.widget<CheckedPopupMenuItem<String>>(
        find.ancestor(
          of: find.text('Transcribe audio'),
          matching: find.byType(CheckedPopupMenuItem<String>),
        ),
      );
      expect(disabled.enabled, isTrue);
      expect(find.text('Manage subtitle models'), findsNothing);
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Transcribe audio'),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Apply'))
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Manage subtitle models'));
      await tester.pumpAndSettle();
      expect(playback.synchronized, isTrue);
      expect(playback.exited, isTrue);
      expect(find.text('Model settings route'), findsOneWidget);
    },
  );
}
