import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/graphql/stats_repository.dart';

void main() {
  group('StatsResult.fromJson', () {
    test('parses full payload with numeric coercion', () {
      final json = {
        'scene_count': 10,
        'scenes_size': 2048,
        'scenes_duration': 3600,
        'image_count': 20,
        'images_size': 1024.5,
        'gallery_count': 5,
        'performer_count': 7,
        'studio_count': 3,
        'group_count': 2,
        'tag_count': 11,
        'total_o_count': 99,
        'total_play_duration': 1234,
        'total_play_count': 45,
        'scenes_played': 8,
      };

      final result = StatsResult.fromJson(json);

      expect(result.sceneCount, 10);
      expect(result.scenesSize, 2048.0);
      expect(result.scenesDuration, 3600.0);
      expect(result.imageCount, 20);
      expect(result.imagesSize, 1024.5);
      expect(result.totalPlayDuration, 1234.0);
      expect(result.totalPlayCount, 45);
      expect(result.scenesPlayed, 8);
    });

    test('defaults missing fields to zero', () {
      final result = StatsResult.fromJson({});

      expect(result.sceneCount, 0);
      expect(result.scenesSize, 0.0);
      expect(result.scenesDuration, 0.0);
      expect(result.imageCount, 0);
      expect(result.imagesSize, 0.0);
      expect(result.galleryCount, 0);
      expect(result.performerCount, 0);
      expect(result.studioCount, 0);
      expect(result.groupCount, 0);
      expect(result.tagCount, 0);
      expect(result.totalOCount, 0);
      expect(result.totalPlayDuration, 0.0);
      expect(result.totalPlayCount, 0);
      expect(result.scenesPlayed, 0);
    });

    test('handles explicit null fields as zero', () {
      final result = StatsResult.fromJson({
        'scene_count': null,
        'scenes_size': null,
        'scenes_duration': null,
        'image_count': null,
        'images_size': null,
        'gallery_count': null,
        'performer_count': null,
        'studio_count': null,
        'group_count': null,
        'tag_count': null,
        'total_o_count': null,
        'total_play_duration': null,
        'total_play_count': null,
        'scenes_played': null,
      });

      expect(result.sceneCount, 0);
      expect(result.scenesSize, 0.0);
      expect(result.scenesDuration, 0.0);
      expect(result.imageCount, 0);
      expect(result.imagesSize, 0.0);
      expect(result.galleryCount, 0);
      expect(result.performerCount, 0);
      expect(result.studioCount, 0);
      expect(result.groupCount, 0);
      expect(result.tagCount, 0);
      expect(result.totalOCount, 0);
      expect(result.totalPlayDuration, 0.0);
      expect(result.totalPlayCount, 0);
      expect(result.scenesPlayed, 0);
    });
  });
}
