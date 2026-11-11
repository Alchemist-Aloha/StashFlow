import 'dart:io';
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/utils/app_log_store.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart'
    as entity;
import 'package:stash_app_flutter/features/images/presentation/pages/image_fullscreen_page.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_browser_context.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_details_bottom_sheet.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_clip_player.dart';

import '../../../../helpers/test_helpers.dart';
import '../../../../helpers/image_clip_test_helpers.dart';
import 'image_fullscreen_page_test.mocks.dart';

class MockHttpOverrides extends HttpOverrides {
  final HttpClient client;
  MockHttpOverrides(this.client);
  @override
  HttpClient createHttpClient(SecurityContext? context) => client;
}

@GenerateNiceMocks([
  MockSpec<HttpClient>(),
  MockSpec<HttpClientRequest>(),
  MockSpec<HttpClientResponse>(),
  MockSpec<HttpHeaders>(),
])
void main() {
  late MockGraphQLImageRepository mockRepository;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockRepository = MockGraphQLImageRepository();
    mockHttpClient = MockHttpClient();
    final mockRequest = MockHttpClientRequest();
    final mockResponse = MockHttpClientResponse();
    final mockHeaders = MockHttpHeaders();

    HttpOverrides.global = MockHttpOverrides(mockHttpClient);

    when(mockHttpClient.getUrl(any)).thenAnswer((_) async => mockRequest);
    when(mockRequest.close()).thenAnswer((_) async => mockResponse);
    when(mockResponse.statusCode).thenReturn(HttpStatus.ok);
    when(mockResponse.contentLength).thenReturn(0);
    when(mockResponse.compressionState)
        .thenReturn(HttpClientResponseCompressionState.notCompressed);
    when(mockResponse.listen(any)).thenAnswer((Invocation invocation) {
      final onData =
          invocation.positionalArguments[0] as void Function(List<int>);
      return Stream<Uint8List>.fromIterable([Uint8List(0)]).listen(onData);
    });
    when(mockResponse.headers).thenReturn(mockHeaders);
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  group('ImageFullscreenPage', () {
    for (final size in [const Size(360, 800), const Size(800, 360)]) {
      for (final scale in [0.5, 2.0]) {
        for (final vertical in [true, false]) {
          testWidgets(
            'clip fills viewer and controls avoid chrome: $size scale=$scale vertical=$vertical',
            (tester) async {
              tester.view.physicalSize = size;
              tester.view.devicePixelRatio = 1;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              tester.view.padding = FakeViewPadding(
                top: 24,
                bottom: 24,
                left: size.width > size.height ? 24 : 0,
                right: size.width > size.height ? 16 : 0,
              );
              addTearDown(tester.view.resetPadding);
              SharedPreferences.setMockInitialValues({
                'image_fullscreen_vertical_swipe': vertical,
              });
              final prefs = await SharedPreferences.getInstance();
              final player = FakeClipPlayer();
              var sessions = 0;
              mockRepository.withData([
                const entity.Image(
                  id: 'clip',
                  title: 'Clip title',
                  files: [
                    entity.ImageFile(
                      width: 640,
                      height: 360,
                      path: 'clip.mp4',
                      typename: 'VideoFile',
                    ),
                  ],
                  paths: entity.ImagePaths(image: 'http://localhost/clip'),
                ),
                const entity.Image(
                  id: 'still',
                  files: [],
                  paths: entity.ImagePaths(),
                ),
              ]);
              await pumpTestWidget(
                tester,
                prefs: prefs,
                child: Theme(
                  data: AppTheme.buildTheme(
                    Brightness.dark,
                    Colors.teal,
                    fontSizeFactor: scale,
                  ),
                  child: const ImageFullscreenPage(imageId: 'clip'),
                ),
                overrides: [
                  imageRepositoryProvider.overrideWithValue(mockRepository),
                  imageClipSessionFactoryProvider.overrideWithValue(() {
                    sessions++;
                    return fakeClipSession(player);
                  }),
                ],
              );
              await tester.pumpAndSettle();
              final header = find.byKey(const Key('image_viewer_header'));
              final footer = find.byKey(const Key('image_viewer_footer'));
              final media = find.byType(Video);
              final slider = find.byType(Slider);
              final controls = find.byKey(const Key('image_clip_controls'));
              final videoRect = tester.getRect(media);
              final videoState = tester.state(media);
              expect(videoRect, Offset.zero & size);
              expect(videoRect.overlaps(tester.getRect(header)), isTrue);
              expect(videoRect.overlaps(tester.getRect(footer)), isTrue);
              expect(
                tester.getRect(controls).bottom,
                lessThan(tester.getRect(footer).top),
              );
              expect(
                tester.getRect(controls).top,
                greaterThanOrEqualTo(tester.getRect(header).bottom),
                reason:
                    'header=${tester.getRect(header)}, controls=${tester.getRect(controls)}, footer=${tester.getRect(footer)}',
              );
              final dockedControls = tester.getRect(controls);
              final rect = tester.getRect(slider);
              await tester.dragFrom(
                Offset(rect.left + 30, rect.center.dy),
                Offset(rect.width - 60, 0),
              );
              await tester.pumpAndSettle();
              expect(player.seeks, hasLength(1));
              expect(header, findsOneWidget);
              expect(footer, findsOneWidget);
              expect(find.text('1 / 2'), findsOneWidget);
              final videoTap = Offset(
                dockedControls.right + 1,
                size.height / 2,
              );
              await tester.tapAt(videoTap);
              await tester.pumpAndSettle();
              expect(header, findsNothing);
              expect(footer, findsNothing);
              expect(tester.getRect(media), videoRect);
              expect(tester.state(media), same(videoState));
              expect(
                tester.getRect(controls).top,
                greaterThan(dockedControls.top),
              );
              expect(
                tester.getRect(controls).bottom,
                lessThanOrEqualTo(size.height - 24),
              );
              expect(sessions, 1);
              await tester.tap(find.byKey(const Key('image_clip_play_pause')));
              await tester.pumpAndSettle();
              expect(player.playing, isFalse);
              expect(header, findsNothing);
              await tester.tapAt(videoTap);
              await tester.pumpAndSettle();
              expect(header, findsOneWidget);
              expect(footer, findsOneWidget);
              expect(tester.getRect(media), videoRect);
              expect(tester.getRect(controls), dockedControls);
              expect(tester.state(media), same(videoState));
              expect(sessions, 1);
              mockRepository.withEmpty();
              await tester.flingFrom(
                videoTap,
                vertical
                    ? Offset(
                        0,
                        -tester
                                .getSize(
                                  find.byKey(const Key('image_viewer_media')),
                                )
                                .height *
                            0.8,
                      )
                    : Offset(-size.width * 0.8, 0),
                1500,
              );
              await tester.pumpAndSettle();
              expect(find.byType(ImageClipPlayer), findsNothing);
              expect(find.text('2 / 2'), findsOneWidget);
              expect(player.disposeCalls, 1);
              expect(tester.takeException(), isNull);
              await tester.pumpWidget(const SizedBox());
              await tester.pumpAndSettle();
              expect(player.disposeCalls, 1);
            },
          );
        }
      }
    }

    testWidgets(
      'clip clearance tracks rotation, scale, theme and system insets without restarting',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetPadding);
        final theme = ValueNotifier(
          AppTheme.buildTheme(Brightness.dark, Colors.teal),
        );
        addTearDown(theme.dispose);
        final player = FakeClipPlayer();
        var sessions = 0;
        mockRepository.withData([
          const entity.Image(
            id: 'clip',
            title: 'Clip title',
            files: [
              entity.ImageFile(
                width: 640,
                height: 360,
                path: 'clip.mp4',
                typename: 'VideoFile',
              ),
            ],
            paths: entity.ImagePaths(image: 'http://localhost/clip'),
          ),
        ]);
        await pumpTestWidget(
          tester,
          child: ValueListenableBuilder<ThemeData>(
            valueListenable: theme,
            builder: (context, value, child) =>
                Theme(data: value, child: child!),
            child: const ImageFullscreenPage(imageId: 'clip'),
          ),
          overrides: [
            imageRepositoryProvider.overrideWithValue(mockRepository),
            imageClipSessionFactoryProvider.overrideWithValue(() {
              sessions++;
              return fakeClipSession(player);
            }),
          ],
        );
        await tester.pumpAndSettle();
        final media = find.byType(Video);
        final videoState = tester.state(media);
        for (final (size, scale, brightness, bottomInset) in [
          (const Size(360, 800), 0.5, Brightness.dark, 24.0),
          (const Size(800, 360), 2.0, Brightness.light, 24.0),
          (const Size(800, 360), 1.5, Brightness.dark, 16.0),
          (const Size(360, 800), 1.0, Brightness.light, 48.0),
        ]) {
          tester.view.physicalSize = size;
          tester.view.padding = FakeViewPadding(top: 24, bottom: bottomInset);
          theme.value = AppTheme.buildTheme(
            brightness,
            Colors.teal,
            fontSizeFactor: scale,
          );
          await tester.pumpAndSettle();
          final controls = tester.getRect(
            find.byKey(const Key('image_clip_controls')),
          );
          expect(tester.getRect(media), Offset.zero & size);
          expect(tester.state(media), same(videoState));
          expect(
            controls.top,
            greaterThanOrEqualTo(
              tester
                  .getRect(find.byKey(const Key('image_viewer_header')))
                  .bottom,
            ),
          );
          expect(
            controls.bottom,
            lessThanOrEqualTo(
              tester.getRect(find.byKey(const Key('image_viewer_footer'))).top,
            ),
          );
          final playTarget = tester.getSize(
            find.byKey(const Key('image_clip_play_pause')),
          );
          expect(
            playTarget.width,
            greaterThanOrEqualTo(kMinInteractiveDimension),
          );
          expect(
            playTarget.height,
            greaterThanOrEqualTo(kMinInteractiveDimension),
          );
          expect(sessions, 1);
          expect(player.playing, isTrue);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(player.disposeCalls, 1);
      },
    );

    testWidgets('GIFs use the image decoder without creating a clip session', (
      tester,
    ) async {
      mockRepository.withData([
        const entity.Image(
          id: 'gif',
          files: [
            entity.ImageFile(
              width: 320,
              height: 240,
              path: '/images/animation',
              format: 'gif',
              typename: 'VideoFile',
            ),
          ],
          paths: entity.ImagePaths(image: 'http://localhost/gif'),
        ),
      ]);
      var sessions = 0;
      await pumpTestWidget(
        tester,
        child: const ImageFullscreenPage(imageId: 'gif'),
        overrides: [
          imageRepositoryProvider.overrideWithValue(mockRepository),
          imageClipSessionFactoryProvider.overrideWithValue(() {
            sessions++;
            return fakeClipSession(FakeClipPlayer());
          }),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ExtendedImage), findsOneWidget);
      expect(find.byType(ImageClipPlayer), findsNothing);
      expect(find.byType(Video), findsNothing);
      expect(find.byKey(const Key('image_clip_controls')), findsNothing);
      expect(sessions, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('adjacent clips are not decoded or prefetched as images', (
      tester,
    ) async {
      mockRepository.withData([
        const entity.Image(id: 'still', files: [], paths: entity.ImagePaths()),
        const entity.Image(
          id: 'clip',
          files: [
            entity.ImageFile(
              width: 320,
              height: 240,
              path: 'clip.mp4',
              typename: 'VideoFile',
            ),
          ],
          paths: entity.ImagePaths(image: 'http://localhost/clip'),
        ),
      ]);
      await pumpTestWidget(
        tester,
        child: const ImageFullscreenPage(imageId: 'still'),
        overrides: [imageRepositoryProvider.overrideWithValue(mockRepository)],
      );
      await tester.pumpAndSettle();
      expect(find.byType(ImageClipPlayer), findsNothing);
      verifyNever(mockHttpClient.getUrl(Uri.parse('http://localhost/clip')));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'selected clip uses video and handles unavailable native playback',
      (tester) async {
        mockRepository.withData([
          const entity.Image(
            id: 'clip',
            files: [
              entity.ImageFile(
                width: 320,
                height: 240,
                path: 'clip.mp4',
                typename: 'VideoFile',
              ),
            ],
            paths: entity.ImagePaths(image: 'http://localhost/clip'),
          ),
        ]);
        await pumpTestWidget(
          tester,
          child: const ImageFullscreenPage(imageId: 'clip'),
          overrides: [
            imageRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        await tester.pumpAndSettle();
        expect(find.byType(ImageClipPlayer), findsOneWidget);
        expect(find.byType(ExtendedImage), findsNothing);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'library deep link resolves its image instead of the first result',
      (tester) async {
        mockRepository.withData([
          const entity.Image(
            id: 'first',
            title: 'Wrong image',
            files: [],
            paths: entity.ImagePaths(),
          ),
        ]);
        await pumpTestWidget(
          tester,
          child: const ImageFullscreenPage(imageId: 'requested'),
          overrides: [
            imageRepositoryProvider.overrideWithValue(mockRepository),
            imageByIdProvider('requested').overrideWith(
              (ref) async => const entity.Image(
                id: 'requested',
                title: 'Requested image',
                files: [],
                paths: entity.ImagePaths(),
              ),
            ),
          ],
        );
        await tester.pumpAndSettle();
        expect(find.text('Requested image'), findsOneWidget);
        expect(find.text('Wrong image'), findsNothing);
        expect(_currentImageId(tester), 'requested');
      },
    );

    testWidgets(
      'scoped missing image never substitutes another gallery image',
      (tester) async {
        mockRepository.withData([
          const entity.Image(
            id: 'first',
            title: 'Wrong image',
            files: [],
            paths: entity.ImagePaths(),
          ),
        ]);
        await pumpTestWidget(
          tester,
          child: const ImageFullscreenPage(imageId: 'missing'),
          overrides: [
            imageRepositoryProvider.overrideWithValue(mockRepository),
            imageBrowserContextProvider.overrideWithValue(
              const ImageBrowserContext.gallery(
                'gallery',
                path: '/gallery/gallery',
              ),
            ),
          ],
        );
        await tester.pumpAndSettle();
        expect(find.text('Wrong image'), findsNothing);
        expect(find.byType(CloseButton), findsOneWidget);
        expect(find.textContaining('not found'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'removing the current image does not index outside a changed list',
      (tester) async {
        mockRepository.withData([
          const entity.Image(
            id: 'first',
            files: [],
            paths: entity.ImagePaths(),
          ),
          const entity.Image(
            id: 'selected',
            files: [],
            paths: entity.ImagePaths(),
          ),
        ]);
        await pumpTestWidget(
          tester,
          child: const ImageFullscreenPage(imageId: 'selected'),
          overrides: [
            imageRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ImageFullscreenPage)),
        );
        mockRepository.withData([
          const entity.Image(
            id: 'other',
            files: [],
            paths: entity.ImagePaths(),
          ),
        ]);
        await container.read(imageListProvider.notifier).refresh();
        await tester.pumpAndSettle();
        expect(find.textContaining('not found'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    test('warms adjacent files without decoding them', () {
      final source = File(
        'lib/features/images/presentation/pages/image_fullscreen_page.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('_warmAdjacentFiles(items, _currentIndex, headers);'),
      );
      expect(source, contains('.getNetworkImageData().ignore()'));
      expect(source, isNot(contains('precacheImage(')));
    });

    test('delegates desktop fullscreen transitions to DesktopFullscreen', () {
      final source = File(
        'lib/features/images/presentation/pages/image_fullscreen_page.dart',
      ).readAsStringSync();

      expect(source, contains('if (mounted) unawaited(_enterFullScreen())'));
      expect(source, contains('await DesktopFullscreen.instance.enter()'));
      expect(source, contains('DesktopFullscreen.instance.exit()'));
      expect(source, isNot(contains('windowManager.unmaximize()')));
      expect(source, isNot(contains('windowManager.maximize()')));
    });

    testWidgets('logs native exit failures during disposal', (tester) async {
      const nativeFullscreenChannel = MethodChannel(
        'stash_app_flutter/fullscreen',
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      AppLogStore.instance
        ..isEnabled = true
        ..clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(nativeFullscreenChannel, (call) async {
            if (call.method == 'setFullScreen' && call.arguments == false) {
              throw PlatformException(
                code: 'fullscreen_error',
                message: 'restore failed',
              );
            }
            return null;
          });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            SystemChannels.platform,
            (call) async => null,
          );

      try {
        final image = entity.Image(
          id: 'fullscreen-exit-test',
          title: 'Fullscreen Exit Test',
          files: [],
          paths: const entity.ImagePaths(image: 'http://test.com/image.jpg'),
        );
        mockRepository.withData([image]);
        await pumpTestWidget(
          tester,
          child: const ImageFullscreenPage(imageId: 'fullscreen-exit-test'),
          overrides: [
            imageRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        await tester.pump();

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await tester.pump();

        expect(
          AppLogStore.instance.entries.any(
            (entry) => entry.message.contains(
              'ImageFullscreenPage: error exiting fullscreen',
            ),
          ),
          isTrue,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
        AppLogStore.instance
          ..clear()
          ..isEnabled = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(nativeFullscreenChannel, null);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      }
    });

    testWidgets('attempts native exit when system UI restoration fails', (
      tester,
    ) async {
      const nativeFullscreenChannel = MethodChannel(
        'stash_app_flutter/fullscreen',
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      var nativeExitInvoked = false;
      AppLogStore.instance
        ..isEnabled = true
        ..clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(nativeFullscreenChannel, (call) async {
            if (call.method == 'setFullScreen' && call.arguments == false) {
              nativeExitInvoked = true;
            }
            return null;
          });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'SystemChrome.setEnabledSystemUIMode') {
              throw PlatformException(
                code: 'system_ui_error',
                message: 'system UI restore failed',
              );
            }
            return null;
          });

      try {
        final image = entity.Image(
          id: 'system-ui-exit-test',
          title: 'System UI Exit Test',
          files: [],
          paths: const entity.ImagePaths(image: 'http://test.com/image.jpg'),
        );
        mockRepository.withData([image]);
        await pumpTestWidget(
          tester,
          child: const ImageFullscreenPage(imageId: 'system-ui-exit-test'),
          overrides: [
            imageRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        await tester.pump();

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await tester.pump();

        expect(nativeExitInvoked, isTrue);
        expect(
          AppLogStore.instance.entries.any(
            (entry) => entry.message.contains(
              'ImageFullscreenPage: error restoring system UI',
            ),
          ),
          isTrue,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
        AppLogStore.instance
          ..clear()
          ..isEnabled = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(nativeFullscreenChannel, null);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      }
    });

    testWidgets('displays images and allows vertical navigation', (
      tester,
    ) async {
      final images = [
        entity.Image(
          id: '1',
          title: 'Image 1',
          files: [],
          paths: const entity.ImagePaths(image: 'http://test.com/img1.jpg'),
        ),
        entity.Image(
          id: '2',
          title: 'Image 2',
          files: [],
          paths: const entity.ImagePaths(image: 'http://test.com/img2.jpg'),
        ),
      ];
      mockRepository.withData(images);

      await pumpTestWidget(
        tester,
        child: const ImageFullscreenPage(imageId: '1'),
        overrides: [imageRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1 / 2'), findsOneWidget);

      final keyboardFocus = tester.widget<Focus>(
        find.byKey(const Key('image_keyboard_shortcuts')),
      );
      keyboardFocus.focusNode!.requestFocus();
      await tester.pump();
      expect(keyboardFocus.focusNode!.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(find.text('Image 2'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ImageFullscreenPage)),
      );
      expect(container.read(imageFullscreenCurrentIdProvider), '2');

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(find.text('Image 1'), findsOneWidget);

      await tester.drag(
        find.byType(ExtendedImageGesturePageView),
        const Offset(0, -1000),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets(
      'unzoomed images let off-axis swipes page; zoomed images keep panning',
      (tester) async {
        late Uint8List png;
        await tester.runAsync(() async {
          final recorder = ui.PictureRecorder();
          Canvas(recorder).drawRect(
            const Rect.fromLTWH(0, 0, 40, 80),
            Paint()..color = Colors.red,
          );
          final image = await recorder.endRecording().toImage(40, 80);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          png = data!.buffer.asUint8List();
        });
        final request = MockHttpClientRequest();
        final response = MockHttpClientResponse();
        when(mockHttpClient.getUrl(any)).thenAnswer((_) async => request);
        when(request.close()).thenAnswer((_) async => response);
        when(response.statusCode).thenReturn(HttpStatus.ok);
        when(response.contentLength).thenReturn(png.length);
        when(response.compressionState)
            .thenReturn(HttpClientResponseCompressionState.notCompressed);
        when(response.headers).thenReturn(MockHttpHeaders());
        when(
          response.listen(
            any,
            onError: anyNamed('onError'),
            onDone: anyNamed('onDone'),
            cancelOnError: anyNamed('cancelOnError'),
          ),
        ).thenAnswer((invocation) {
          return Stream<Uint8List>.fromIterable([png]).listen(
            invocation.positionalArguments[0] as void Function(List<int>),
            onError: invocation.namedArguments[#onError] as Function?,
            onDone: invocation.namedArguments[#onDone] as void Function()?,
            cancelOnError: invocation.namedArguments[#cancelOnError] as bool?,
          );
        });
        mockRepository.withData([
          for (final id in ['1', '2', '3'])
            entity.Image(
              id: id,
              title: 'Image $id',
              files: const [],
              paths: entity.ImagePaths(image: 'http://stash.test/$id.png'),
            ),
        ]);
        await pumpTestWidget(
          tester,
          child: const ImageFullscreenPage(imageId: '1'),
          overrides: [
            imageRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        await _loadImages(tester);
        mockRepository.withEmpty();
        expect(find.byType(ExtendedImageGesture), findsWidgets);
        final media = tester.getCenter(
          find.byKey(const Key('image_viewer_media')),
        );

        // Vertical paging (default): a swipe 65 degrees off that axis used to
        // be claimed by the image's pan recognizer and dropped.
        await tester.flingFrom(media, const Offset(-181, -85), 1000);
        await _pumpFrames(tester);
        expect(_currentImageId(tester), '2');
        await _loadImages(tester);

        // Once zoomed, one-finger drags pan the image instead of paging.
        await tester.tapAt(media);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tapAt(media);
        await _pumpFrames(tester);
        final gesture = tester.state<ExtendedImageGestureState>(
          find.byType(ExtendedImageGesture),
        );
        expect(gesture.gestureDetails!.totalScale, greaterThan(1));
        final offset = gesture.gestureDetails!.offset;
        final pan = await tester.startGesture(media);
        for (var i = 0; i < 6; i++) {
          await pan.moveBy(const Offset(-10, -20));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await pan.up();
        await _pumpFrames(tester);
        expect(gesture.gestureDetails!.offset, isNot(offset));
        expect(_currentImageId(tester), '2');
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('keyboard navigation moves promptly and settles quickly', (
      tester,
    ) async {
      await _pumpKeyboardGallery(tester, mockRepository, count: 3);
      final focus = _keyboardFocus(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The eased transition should already have crossed its midpoint.
      expect(_currentImageId(tester), '2');
      await tester.pump(const Duration(milliseconds: 100));
      expect(_currentImageId(tester), '2');
      expect(
        tester
            .widget<ExtendedImageGesturePageView>(
              find.byType(ExtendedImageGesturePageView),
            )
            .controller
            .page,
        closeTo(1, 0.01),
      );
      expect(focus.focusNode!.hasFocus, isTrue);
    });

    testWidgets('rapid arrow presses advance once per input', (tester) async {
      await _pumpKeyboardGallery(tester, mockRepository, count: 5);

      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pump(const Duration(milliseconds: 200));
      expect(_currentImageId(tester), '4');
    });

    testWidgets('slideshow ticks do not cancel rapid manual navigation', (
      tester,
    ) async {
      await _pumpKeyboardGallery(tester, mockRepository, count: 5);

      await tester.tap(find.byKey(const Key('image_slideshow_button')));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slider).first, const Offset(-1000, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 850));
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 25));
      }
      // Cross the 1 second slideshow interval while keyboard motion is active.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      expect(_currentImageId(tester), '4');
      await tester.tap(find.byKey(const Key('image_slideshow_button')));
      await tester.pump();
    });

    testWidgets('held arrow repeats advance and clamp at loaded endpoints', (
      tester,
    ) async {
      await _pumpKeyboardGallery(tester, mockRepository, count: 3);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));
      }
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump(const Duration(milliseconds: 200));
      expect(_currentImageId(tester), '3');

      for (var i = 0; i < 5; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));
      }
      await tester.pump(const Duration(milliseconds: 200));
      expect(_currentImageId(tester), '1');
    });

    testWidgets('opposite arrow before midpoint reverses to prior image', (
      tester,
    ) async {
      await _pumpKeyboardGallery(tester, mockRepository, count: 3);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));

      expect(_currentImageId(tester), '1');
    });

    testWidgets(
      'Home and End interrupt transitions and keep later arrows in sync',
      (tester) async {
        await _pumpKeyboardGallery(tester, mockRepository, count: 4);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 30));
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 220));
        expect(_currentImageId(tester), '4');

        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 220));
        expect(_currentImageId(tester), '1');

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 220));
        expect(_currentImageId(tester), '2');
      },
    );

    testWidgets('touch swipe synchronizes later keyboard navigation', (
      tester,
    ) async {
      await _pumpKeyboardGallery(tester, mockRepository, count: 4);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      await tester.drag(
        find.byType(ExtendedImageGesturePageView),
        const Offset(1000, 0),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(_currentImageId(tester), '1');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      expect(_currentImageId(tester), '2');
    });

    testWidgets('ImageFullscreenPage shows title in header', (tester) async {
      final image = entity.Image(
        id: '1',
        title: 'Detailed Image',
        date: '2023-01-01',
        rating100: 100,
        files: [],
        paths: const entity.ImagePaths(image: 'http://test.com/img1.jpg'),
      );
      mockRepository.withData([image]);

      await pumpTestWidget(
        tester,
        child: const ImageFullscreenPage(imageId: '1'),
        overrides: [imageRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Overlays are shown by default
      expect(find.text('Detailed Image'), findsOneWidget);
    });

    testWidgets(
      'places actions above progress and opens metadata from header',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final image = entity.Image(
          id: 'details-image',
          title: 'Detailed Image',
          date: '2023-01-01',
          rating100: 80,
          urls: const ['https://example.com/image'],
          studioId: 'studio-1',
          studioName: 'Studio One',
          performerIds: const ['performer-1'],
          performerNames: const ['Performer One'],
          performerImagePaths: const [null],
          files: const [
            entity.ImageFile(
              width: 1920,
              height: 1080,
              path: '/images/detail.jpg',
            ),
          ],
          paths: const entity.ImagePaths(image: 'http://test.com/detail.jpg'),
        );
        mockRepository.withData([image]);

        await pumpTestWidget(
          tester,
          child: const ImageFullscreenPage(imageId: 'details-image'),
          overrides: [
            imageRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final rateButton = find.byKey(const Key('image_rate_button'));
        final progressBar = find.byKey(const Key('image_progress_bar'));
        expect(find.byKey(const Key('image_info_button')), findsOneWidget);
        expect(rateButton, findsOneWidget);
        expect(find.byKey(const Key('image_download_button')), findsOneWidget);
        expect(find.byKey(const Key('image_slideshow_button')), findsOneWidget);
        expect(progressBar, findsOneWidget);
        expect(
          tester.getTopLeft(progressBar).dy,
          greaterThan(tester.getCenter(rateButton).dy),
        );

        await tester.tap(find.byKey(const Key('image_info_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(ImageDetailsBottomSheet), findsOneWidget);
        expect(find.text('Image Details'), findsOneWidget);
        expect(find.text('/images/detail.jpg'), findsOneWidget);
        final detailsSheet = find.byType(ImageDetailsBottomSheet);
        expect(
          find.descendant(of: detailsSheet, matching: find.text('Studio One')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: detailsSheet,
            matching: find.text('Performer One'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: detailsSheet,
            matching: find.byIcon(Icons.star_rate_rounded),
          ),
          findsNothing,
        );
      },
    );

    testWidgets('falls back to file path in header if title is missing', (
      tester,
    ) async {
      final image = entity.Image(
        id: '1',
        title: null,
        files: [
          const entity.ImageFile(
            width: 100,
            height: 100,
            path: '/path/to/image.jpg',
          ),
        ],
        paths: const entity.ImagePaths(image: 'http://test.com/img1.jpg'),
      );
      mockRepository.withData([image]);

      await pumpTestWidget(
        tester,
        child: const ImageFullscreenPage(imageId: '1'),
        overrides: [imageRepositoryProvider.overrideWithValue(mockRepository)],
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Falls back to filename (image.jpg) because of the new logic
      expect(find.text('image.jpg'), findsOneWidget);
    });
  });
}

Future<void> _pumpKeyboardGallery(
  WidgetTester tester,
  MockGraphQLImageRepository repository, {
  required int count,
}) async {
  final images = List.generate(
    count,
    (index) => entity.Image(
      id: '${index + 1}',
      title: 'Image ${index + 1}',
      files: const [],
      paths: const entity.ImagePaths(image: ''),
    ),
  );
  repository.withData(images);

  await pumpTestWidget(
    tester,
    child: const ImageFullscreenPage(imageId: '1'),
    overrides: [imageRepositoryProvider.overrideWithValue(repository)],
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  _keyboardFocus(tester).focusNode!.requestFocus();
  await tester.pump();
  // Keep automatic near-end pagination from appending the mock page again.
  repository.withEmpty();
}

/// Lets real image fetch and decode finish, which fake async cannot advance.
Future<void> _loadImages(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
}

/// Steps frame by frame; a spinning loader keeps pumpAndSettle from settling.
Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Focus _keyboardFocus(WidgetTester tester) =>
    tester.widget<Focus>(find.byKey(const Key('image_keyboard_shortcuts')));

String? _currentImageId(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ImageFullscreenPage)))
        .read(imageFullscreenCurrentIdProvider);
