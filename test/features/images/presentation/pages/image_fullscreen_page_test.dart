import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/core/utils/app_log_store.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart'
    as entity;
import 'package:stash_app_flutter/features/images/presentation/pages/image_fullscreen_page.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';

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
      final void Function(List<int>) onData = invocation.positionalArguments[0];
      return Stream<Uint8List>.fromIterable([Uint8List(0)]).listen(onData);
    });
    when(mockResponse.headers).thenReturn(mockHeaders);
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  group('ImageFullscreenPage', () {
    test('guards initial post-frame prefetch after dispose', () {
      final source = File(
        'lib/features/images/presentation/pages/image_fullscreen_page.dart',
      ).readAsStringSync();

      expect(
        source,
        contains(
          'WidgetsBinding.instance.addPostFrameCallback((_) {\n'
          '            if (!mounted) return;\n'
          '            _prefetchAdjacent(items, _currentIndex, headers);\n'
          '          });',
        ),
      );
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
            if (call.method == 'setFullScreen' &&
                (call.arguments
                    as Map<Object?, Object?>)['isFullScreen'] == false) {
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

    testWidgets('attempts window_manager exit when system UI restoration fails', (
      tester,
    ) async {
      const windowManagerChannel = MethodChannel('window_manager');
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      var windowManagerExitInvoked = false;
      AppLogStore.instance
        ..isEnabled = true
        ..clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowManagerChannel, (call) async {
            if (call.method == 'setFullScreen' &&
                (call.arguments
                    as Map<Object?, Object?>)['isFullScreen'] == false) {
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

