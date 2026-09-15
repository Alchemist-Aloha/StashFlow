import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:stash_app_flutter/features/scenes/data/repositories/preview_availability_service.dart';

void main() {
  PreviewAvailabilityService serviceReturning(int statusCode) =>
      PreviewAvailabilityService(
        client: MockClient((request) async => http.Response('', statusCode)),
      );

  test('404 and 410 mark the preview unavailable', () async {
    expect(
      await serviceReturning(404).isAvailable('http://host/preview'),
      isFalse,
    );
    expect(
      await serviceReturning(410).isAvailable('http://host/preview'),
      isFalse,
    );
  });

  test('other statuses keep the preview available', () async {
    expect(
      await serviceReturning(200).isAvailable('http://host/preview'),
      isTrue,
    );
    // Stash may reject non-GET probes; that must not hide a valid preview.
    expect(
      await serviceReturning(405).isAvailable('http://host/preview'),
      isTrue,
    );
  });

  test('probe failures stay optimistic', () async {
    final service = PreviewAvailabilityService(
      client: MockClient((request) async => throw Exception('offline')),
    );
    expect(await service.isAvailable('http://host/preview'), isTrue);
  });
}
