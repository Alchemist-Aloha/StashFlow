import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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
  late MockImageRepository mockRepository;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockRepository = MockImageRepository();
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

      await tester.drag(find.byType(PageView), const Offset(0, -1000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('shows info bottom sheet', (tester) async {
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

      // Tap info button
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Detailed Image'), findsOneWidget);
      expect(find.text('Date: 2023-01-01'), findsOneWidget);
      expect(find.text('Rating: 5.0 Stars'), findsOneWidget);
    });
  });
}
