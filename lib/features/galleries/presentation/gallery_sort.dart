import 'package:flutter/material.dart';

import '../../../core/utils/l10n_extensions.dart';

/// Shared gallery sort catalogue for the library and entity gallery pages.
enum GallerySortOption {
  date('date'),
  title('title'),
  path('path'),
  rating('rating'),
  fileModTime('file_mod_time'),
  tagCount('tag_count'),
  performerCount('performer_count'),
  performerAge('performer_age'),
  random('random'),
  imageCount('images_count'),
  fileCount('file_count'),
  createdAt('created_at'),
  updatedAt('updated_at');

  const GallerySortOption(this.key);

  /// Server sort key, also used by saved defaults and presets.
  final String key;

  /// Frequently used choices shown before the advanced section.
  static const commonOptions = [
    date,
    title,
    path,
    rating,
    imageCount,
    random,
    updatedAt,
  ];

  /// Restores canonical and legacy preset keys without changing the default.
  static GallerySortOption fromKey(String? key) {
    final canonicalKey = switch (key) {
      'rating100' => 'rating',
      'image_count' => 'images_count',
      'zip_file_count' => 'file_count',
      _ => key,
    };
    return values.firstWhere(
      (option) => option.key == canonicalKey,
      orElse: () => path,
    );
  }

  /// Localized label shared by every gallery sort sheet.
  String label(BuildContext context) {
    return switch (this) {
      GallerySortOption.date => context.l10n.common_date,
      GallerySortOption.title => context.l10n.common_title,
      GallerySortOption.path => context.l10n.common_filepath,
      GallerySortOption.rating => context.l10n.common_rating,
      GallerySortOption.fileModTime => context.l10n.sort_file_mod_time,
      GallerySortOption.tagCount => context.l10n.sort_tag_count,
      GallerySortOption.performerCount => context.l10n.sort_performers_count,
      GallerySortOption.performerAge => context.l10n.scenes_sort_performer_age,
      GallerySortOption.random => context.l10n.common_random,
      GallerySortOption.imageCount => context.l10n.common_image_count,
      GallerySortOption.fileCount => context.l10n.sort_zip_file_count,
      GallerySortOption.createdAt => context.l10n.sort_created_at,
      GallerySortOption.updatedAt => context.l10n.sort_updated_at,
    };
  }
}
