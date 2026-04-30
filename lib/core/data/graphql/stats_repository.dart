import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/data/graphql/base_repository.dart';

class StatsResult {
  final int sceneCount;
  final double scenesSize;
  final double scenesDuration;
  final int imageCount;
  final double imagesSize;
  final int galleryCount;
  final int performerCount;
  final int studioCount;
  final int groupCount;
  final int tagCount;
  final int totalOCount;
  final double totalPlayDuration;
  final int totalPlayCount;
  final int scenesPlayed;

  StatsResult({
    required this.sceneCount,
    required this.scenesSize,
    required this.scenesDuration,
    required this.imageCount,
    required this.imagesSize,
    required this.galleryCount,
    required this.performerCount,
    required this.studioCount,
    required this.groupCount,
    required this.tagCount,
    required this.totalOCount,
    required this.totalPlayDuration,
    required this.totalPlayCount,
    required this.scenesPlayed,
  });

  factory StatsResult.fromJson(Map<String, dynamic> json) {
    return StatsResult(
      sceneCount: json['scene_count'] ?? 0,
      scenesSize: (json['scenes_size'] ?? 0).toDouble(),
      scenesDuration: (json['scenes_duration'] ?? 0).toDouble(),
      imageCount: json['image_count'] ?? 0,
      imagesSize: (json['images_size'] ?? 0).toDouble(),
      galleryCount: json['gallery_count'] ?? 0,
      performerCount: json['performer_count'] ?? 0,
      studioCount: json['studio_count'] ?? 0,
      groupCount: json['group_count'] ?? 0,
      tagCount: json['tag_count'] ?? 0,
      totalOCount: json['total_o_count'] ?? 0,
      totalPlayDuration: (json['total_play_duration'] ?? 0).toDouble(),
      totalPlayCount: json['total_play_count'] ?? 0,
      scenesPlayed: json['scenes_played'] ?? 0,
    );
  }
}

class StatsRepository extends BaseRepository {
  final GraphQLClient client;

  StatsRepository(this.client);

  static const String getStatsQuery = r'''
    query GetStats {
      stats {
        scene_count
        scenes_size
        scenes_duration
        image_count
        images_size
        gallery_count
        performer_count
        studio_count
        group_count
        tag_count
        total_o_count
        total_play_duration
        total_play_count
        scenes_played
      }
    }
  ''';

  Future<StatsResult> getStats() async {
    final result = await client.query(
      QueryOptions(
        document: gql(getStatsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    BaseRepository.validateResult(result);
    
    final data = result.data?['stats'];
    if (data == null) {
      throw Exception('Failed to fetch stats: data is null');
    }

    return StatsResult.fromJson(data);
  }
}
