import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/core/utils/app_log_store.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart'
    as entity;
import 'package:stash_app_flutter/features/images/presentation/pages/image_fullscreen_page.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/widgets/image_details_bottom_sheet.dart';

import '../../../../helpers/test_helpers.dart';
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
    when(
      mockResponse.compressionState,
    ).thenReturn(HttpClientResponseCompressionState.notCompressed);
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

    testWidgets('logs window_manager exit failures during disposal', (
      tester,
    ) async {
      const windowManagerChannel = MethodChannel('window_manager');
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      AppLogStore.instance
        ..isEnabled = true
        ..clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowManagerChannel, (call) async {
            if (call.method == 'isMaximized') return false;
            if (call.method == 'setFullScreen' &&
                (call.arguments as Map<Object?, Object?>)['isFullScreen'] ==
                    false) {
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
            .setMockMethodCallHandler(windowManagerChannel, null);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      }
    });

    testWidgets(
      'attempts window_manager exit when system UI restoration fails',
      (tester) async {
        const windowManagerChannel = MethodChannel('window_manager');
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        var windowManagerExitInvoked = false;
        AppLogStore.instance
          ..isEnabled = true
          ..clear();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(windowManagerChannel, (call) async {
              if (call.method == 'isMaximized') return false;
              if (call.method == 'setFullScreen' &&
                  (call.arguments as Map<Object?, Object?>)['isFullScreen'] ==
                      false) {
                windowManagerExitInvoked = true;
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

          expect(windowManagerExitInvoked, isTrue);
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
              .setMockMethodCallHandler(windowManagerChannel, null);
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null);
        }
      },
    );

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

Focus _keyboardFocus(WidgetTester tester) =>
    tester.widget<Focus>(find.byKey(const Key('image_keyboard_shortcuts')));

String? _currentImageId(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(ImageFullscreenPage)),
).read(imageFullscreenCurrentIdProvider);
