import 'dart:async';
import 'dart:io';

import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/data/services/cast_service.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stopping the player ends an active cast session', () async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
    );
    addTearDown(container.dispose);

    final session = _FakeCastSession();
    await container
        .read(castServiceProvider.notifier)
        .setActiveSession(session);

    container.read(playerStateProvider.notifier).stop();
    await Future<void>.delayed(Duration.zero);

    expect(session.disconnectCalls, 1);
    expect(container.read(castServiceProvider).isCasting, isFalse);
  });

  test('stopping the player preserves miniplayer video preference', () async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(playerStateProvider.notifier);
    notifier.setUseActualSceneVideoInMiniPlayer(true);

    notifier.stop();
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(playerStateProvider).useActualSceneVideoInMiniPlayer,
      isTrue,
    );
  });
}

class _FakeCastSession extends dc.CastSession {
  _FakeCastSession()
    : super(
        dc.CastDevice(
          id: 'fake',
          name: 'Fake Cast',
          protocol: dc.CastProtocol.chromecast,
          address: InternetAddress.loopbackIPv4,
          port: 8009,
        ),
      );

  final _positionController = StreamController<Duration>.broadcast();
  int disconnectCalls = 0;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
  }

  @override
  Future<void> loadMedia(dc.CastMedia media) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setSubtitle(dc.CastSubtitle? subtitle) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {}
}
