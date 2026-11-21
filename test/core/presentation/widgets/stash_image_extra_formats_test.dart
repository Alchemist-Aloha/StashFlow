import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';

import '../../../helpers/extra_image_fixtures.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory root;
  late HttpServer server;
  late Uri base;
  late Map<String, List<int>> bodies;

  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('stashflow-extra-formats-');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pathChannel,
      (_) async => root.path,
    );
    bodies = {
      '/a.avif': avifFixture,
      '/a.jxl': jxlFixture,
      '/bad': [1, 2, 3, 4],
    };
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    base = Uri.parse('http://127.0.0.1:${server.port}');
    server.listen((request) async {
      request.response.add(bodies[request.uri.path]!);
      await request.response.close();
    });
  });

  tearDownAll(() async {
    await StashImage.cacheManager.dispose();
    await server.close(force: true);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, null);
    await root.delete(recursive: true);
  });

  Future<ImageProvider> providerFor(WidgetTester tester, String path) async {
    late ImageProvider provider;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            provider = StashImage.provider(ref, base.resolve(path).toString());
            return const SizedBox();
          },
        ),
      ),
    );
    return provider;
  }

  Future<Object> resolve(ImageProvider provider) {
    final result = Completer<Object>();
    provider
        .resolve(ImageConfiguration.empty)
        .addListener(
          ImageStreamListener(
            (info, _) => result.complete(info),
            onError: (error, _) => result.complete(error),
          ),
        );
    return result.future.timeout(const Duration(seconds: 20));
  }

  for (final path in ['/a.avif', '/a.jxl']) {
    testWidgets('provider decodes cached $path', (tester) async {
      final provider = await providerFor(tester, path);
      final info = await tester.runAsync(
        () => resolve(ResizeImage(provider, width: 8, height: 6)),
      );
      expect(info, isA<ImageInfo>());
      final image = (info! as ImageInfo).image;
      expect((image.width, image.height), (8, 6));
    });
  }

  testWidgets('provider still fails on undecodable bytes', (tester) async {
    final provider = await providerFor(tester, '/bad');
    final error = await tester.runAsync(() => resolve(provider));
    expect(error, isNot(isA<ImageInfo>()));
  });
}
