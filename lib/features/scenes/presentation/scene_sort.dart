import 'package:flutter/material.dart';

import '../../../core/utils/l10n_extensions.dart';

/// Shared scene sort catalogue for the library and entity-scoped media pages.
enum SceneSortField {
  organized('organized'),
  date('date'),
  productionDate('production_date'),
  rating('rating'),
  playCount('play_count'),
  title('title'),
  duration('duration'),
  bitrate('bitrate'),
  framerate('framerate'),
  updatedAt('updated_at'),
  createdAt('created_at'),
  random('random'),
  fileCount('file_count'),
  filesize('filesize'),
  resolution('resolution'),
  lastPlayedAt('last_played_at'),
  resumeTime('resume_time'),
  playDuration('play_duration'),
  interactive('interactive'),
  interactiveSpeed('interactive_speed'),
  perceptualSimilarity('perceptual_similarity'),
  performerAge('performer_age'),
  studio('studio'),
  path('path'),
  fileModTime('file_mod_time'),
  tagCount('tag_count'),
  performerCount('performer_count'),
  oCounter('o_counter'),
  lastOAt('last_o_at'),
  groupSceneNumber('group_scene_number'),
  code('code');

  const SceneSortField(this.key);

  /// Server sort key, also used by saved defaults and presets.
  final String key;

  /// Frequently used choices shown before the advanced section.
  static const commonOptions = [
    date,
    title,
    rating,
    duration,
    random,
    updatedAt,
    lastPlayedAt,
  ];

  /// Restores a persisted key, falling back to the scene default.
  static SceneSortField fromKey(String? key) =>
      values.firstWhere((field) => field.key == key, orElse: () => date);

  /// Localized label shared by every scene sort sheet.
  String label(BuildContext context) {
    return switch (this) {
      SceneSortField.organized => context.l10n.common_organized,
      SceneSortField.date => context.l10n.common_date,
      SceneSortField.productionDate =>
        context.l10n.scenes_field_production_date,
      SceneSortField.rating => context.l10n.common_rating,
      SceneSortField.playCount => context.l10n.performers_play_count,
      SceneSortField.title => context.l10n.common_title,
      SceneSortField.duration => context.l10n.scenes_sort_duration,
      SceneSortField.bitrate => context.l10n.scenes_sort_bitrate,
      SceneSortField.framerate => context.l10n.scenes_sort_framerate,
      SceneSortField.updatedAt => context.l10n.sort_updated_at,
      SceneSortField.createdAt => context.l10n.sort_created_at,
      SceneSortField.random => context.l10n.sort_random,
      SceneSortField.fileCount => context.l10n.scenes_sort_file_count,
      SceneSortField.filesize => context.l10n.scenes_sort_filesize,
      SceneSortField.resolution => context.l10n.scenes_sort_resolution,
      SceneSortField.lastPlayedAt => context.l10n.scenes_sort_last_played_at,
      SceneSortField.resumeTime => context.l10n.scenes_sort_resume_time,
      SceneSortField.playDuration => context.l10n.scenes_sort_play_duration,
      SceneSortField.interactive => context.l10n.scenes_sort_interactive,
      SceneSortField.interactiveSpeed =>
        context.l10n.scenes_sort_interactive_speed,
      SceneSortField.perceptualSimilarity =>
        context.l10n.scenes_sort_perceptual_similarity,
      SceneSortField.performerAge => context.l10n.scenes_sort_performer_age,
      SceneSortField.studio => context.l10n.scenes_sort_studio,
      SceneSortField.path => context.l10n.scenes_sort_path,
      SceneSortField.fileModTime => context.l10n.scenes_sort_file_mod_time,
      SceneSortField.tagCount => context.l10n.scenes_sort_tag_count,
      SceneSortField.performerCount => context.l10n.scenes_sort_performer_count,
      SceneSortField.oCounter => context.l10n.scenes_sort_o_counter,
      SceneSortField.lastOAt => context.l10n.scenes_sort_last_o_at,
      SceneSortField.groupSceneNumber =>
        context.l10n.scenes_sort_group_scene_number,
      SceneSortField.code => context.l10n.scenes_sort_code,
    };
  }
}
