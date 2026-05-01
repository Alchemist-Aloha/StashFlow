import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';

String? _normalizeDate(DateTime? date) {
  if (date == null) return null;
  // GraphQL expects YYYY-MM-DD
  return date.toIso8601String().split('T').first;
}

final _dateRegExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');

String? _cleanUrl(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  final parsed = Uri.tryParse(trimmed);
  if (parsed == null) return null;
  if (parsed.scheme.isEmpty) {
    // assume http if missing scheme
    return 'http://$trimmed';
  }
  return trimmed;
}

Map<String, dynamic> buildSceneUpdateInputFromScraped(ScrapedScene s) {
  final input = <String, dynamic>{};

  if (s.title != null && s.title!.trim().isNotEmpty) {
    input['title'] = s.title!.trim();
  }
  if (s.details != null && s.details!.trim().isNotEmpty) {
    input['details'] = s.details!.trim();
  }

  final cleanedUrls = s.urls.map(_cleanUrl).whereType<String>().toList();
  if (cleanedUrls.isNotEmpty) input['urls'] = cleanedUrls;

  final date = _normalizeDate(s.date);
  if (date != null) input['date'] = date;

  if (s.image != null) {
    // Stash expects the image data, usually as a data URL or just base64 depending on version
    // Standard schema says "base64 encoded data URL"
    if (!s.image!.startsWith('data:')) {
      input['cover_image'] = 'data:image/jpeg;base64,${s.image}';
    } else {
      input['cover_image'] = s.image;
    }
  }

  if (s.studioId != null) {
    input['studio_id'] = s.studioId;
  }

  // Note: performers and tags should be reconciled to IDs before being added to this input
  return input;
}

void validateSceneUpdateInput(Map<String, dynamic> input) {
  // Basic validation: must contain at least one writable field
  final allowedKeys = {
    'title',
    'details',
    'urls',
    'date',
    'cover_image',
    'tag_ids',
    'performer_ids',
    'studio_id',
  };

  if (input.keys.toSet().intersection(allowedKeys).isEmpty) {
    throw ArgumentError('No valid fields to update after normalization');
  }

  if (input.containsKey('date')) {
    final d = input['date'];
    if (d is! String || !_dateRegExp.hasMatch(d)) {
      throw ArgumentError('Invalid date format (expected YYYY-MM-DD): $d');
    }
  }

  if (input.containsKey('urls')) {
    final urls = input['urls'] as List<dynamic>;
    if (urls.isEmpty) throw ArgumentError('urls cannot be empty');
    for (var raw in urls) {
      final u = raw as String;
      final parsed = Uri.tryParse(u);
      if (parsed == null ||
          (parsed.scheme != 'http' && parsed.scheme != 'https')) {
        throw ArgumentError('Invalid URL: $u');
      }
    }
  }
}
