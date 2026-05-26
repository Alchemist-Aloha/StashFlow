import 'dart:async';

import 'package:flutter/foundation.dart';

typedef ResumePositionProvider = Duration Function();

class PlaybackActivityTracker {
  PlaybackActivityTracker({
    required DateTime Function() now,
    required bool Function() isMounted,
    required Future<void> Function(String sceneId) incrementPlayCount,
    required Future<void> Function(
      String sceneId,
      double resumeTime,
      double playDuration,
    )
    saveSceneActivity,
    required void Function(String sceneId) refreshSceneDetails,
    required void Function(String message) log,
  }) : _now = now,
       _isMounted = isMounted,
       _incrementPlayCount = incrementPlayCount,
       _saveSceneActivity = saveSceneActivity,
       _refreshSceneDetails = refreshSceneDetails,
       _log = log;

  final DateTime Function() _now;
  final bool Function() _isMounted;
  final Future<void> Function(String sceneId) _incrementPlayCount;
  final Future<void> Function(
    String sceneId,
    double resumeTime,
    double playDuration,
  )
  _saveSceneActivity;
  final void Function(String sceneId) _refreshSceneDetails;
  final void Function(String message) _log;

  Timer? _playCountTimer;
  Timer? _periodicSaveTimer;
  bool _playCountIncremented = false;
  DateTime? _playStartTime;
  double _accumulatedDuration = 0;
  String? _activeSceneId;
  ResumePositionProvider? _resumePositionProvider;

  void resetForSceneChange() {
    _playCountIncremented = false;
    _accumulatedDuration = 0;
    _playStartTime = null;
    _activeSceneId = null;
    _resumePositionProvider = null;
  }

  void start({
    required String sceneId,
    required ResumePositionProvider resumePositionProvider,
  }) {
    if (_playStartTime != null) return;

    _activeSceneId = sceneId;
    _resumePositionProvider = resumePositionProvider;
    _log('PlayerState _startActivityTracking for scene=$sceneId');

    if (!_playCountIncremented) {
      _playCountTimer?.cancel();
      _playCountTimer = Timer(const Duration(seconds: 5), () async {
        if (!_isMounted() || _playCountIncremented) return;
        try {
          await _incrementPlayCount(sceneId);
          _playCountIncremented = true;
          if (_isMounted()) {
            _refreshSceneDetails(sceneId);
          }
          _log('PlayerState play count incremented for scene=$sceneId');
        } catch (e) {
          debugPrint('Failed to increment play count: $e');
        }
      });
    }

    _playStartTime = _now();
    _periodicSaveTimer?.cancel();
    _periodicSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveActivity(),
    );
  }

  Future<void> stop({
    String? sceneId,
    ResumePositionProvider? resumePositionProvider,
  }) async {
    _playCountTimer?.cancel();
    _playCountTimer = null;
    _periodicSaveTimer?.cancel();
    _periodicSaveTimer = null;

    if (_playStartTime != null) {
      final now = _now();
      _accumulatedDuration +=
          now.difference(_playStartTime!).inMilliseconds / 1000.0;
      _playStartTime = null;
    }

    if (_accumulatedDuration > 0) {
      await _saveActivity(
        sceneId: sceneId,
        resumePositionProvider: resumePositionProvider,
      );
    }
  }

  void dispose() {
    _playCountTimer?.cancel();
    _playCountTimer = null;
    _periodicSaveTimer?.cancel();
    _periodicSaveTimer = null;
  }

  Future<void> _saveActivity({
    String? sceneId,
    ResumePositionProvider? resumePositionProvider,
  }) async {
    final effectiveSceneId = sceneId ?? _activeSceneId;
    final effectiveResumeProvider =
        resumePositionProvider ?? _resumePositionProvider;
    if (effectiveSceneId == null || effectiveResumeProvider == null) {
      return;
    }

    double durationToSave = _accumulatedDuration;
    if (_playStartTime != null) {
      final now = _now();
      durationToSave += now.difference(_playStartTime!).inMilliseconds / 1000.0;
      _playStartTime = now;
    }

    final resumePosition = effectiveResumeProvider();
    if (durationToSave < 0.1 && resumePosition == Duration.zero) {
      return;
    }

    final resumeTime = resumePosition.inMilliseconds / 1000.0;
    _accumulatedDuration = 0;

    _log(
      'PlayerState _saveActivity scene=$effectiveSceneId duration=${durationToSave.toStringAsFixed(1)}s resume=${resumeTime.toStringAsFixed(1)}s',
    );

    try {
      await _saveSceneActivity(effectiveSceneId, resumeTime, durationToSave);
      if (_isMounted()) {
        _refreshSceneDetails(effectiveSceneId);
      }
    } catch (e) {
      debugPrint('Failed to save scene activity: $e');
    }
  }
}
