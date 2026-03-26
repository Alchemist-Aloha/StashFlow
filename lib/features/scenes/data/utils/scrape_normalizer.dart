import '../../domain/models/scraped_scene.dart';

String? _normalizeDate(DateTime? date) {
  if (date == null) return null;
  // GraphQL expects YYYY-MM-DD
  return date.toIso8601String().split('T').first;
}

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

List<String> _normalizeTags(List<String> tags) {
  final seen = <String>{};
  final out = <String>[];
  for (var t in tags) {
    final cleaned = t.trim().toLowerCase();
    if (cleaned.isEmpty) continue;
    if (seen.add(cleaned)) out.add(cleaned);
  }
  return out;
}

Map<String, dynamic> buildSceneUpdateInputFromScraped(ScrapedScene s) {
  final input = <String, dynamic>{};

  if (s.title != null && s.title!.trim().isNotEmpty) input['title'] = s.title!.trim();
  if (s.details != null && s.details!.trim().isNotEmpty) input['details'] = s.details!.trim();

  final url = _cleanUrl(s.url);
  if (url != null) input['urls'] = [url];

  final date = _normalizeDate(s.date);
  if (date != null) input['date'] = date;

  if (s.imageUrl != null && _cleanUrl(s.imageUrl) != null) input['cover_image'] = _cleanUrl(s.imageUrl);

  final tags = _normalizeTags(s.tags);
  if (tags.isNotEmpty) input['tag_names'] = tags;

  // Note: performer reconciliation should be handled separately; here we only prepare basic fields
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
    'tag_names',
  };

  if (input.keys.toSet().intersection(allowedKeys).isEmpty) {
    throw ArgumentError('No valid fields to update after normalization');
  }

  if (input.containsKey('date')) {
    final d = input['date'];
    if (d is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}\$').hasMatch(d)) {
      throw ArgumentError('Invalid date format (expected YYYY-MM-DD): $d');
    }
  }

  if (input.containsKey('urls')) {
    final urls = input['urls'] as List<dynamic>;
    if (urls.isEmpty) throw ArgumentError('urls cannot be empty');
    for (var raw in urls) {
      final u = raw as String;
      final parsed = Uri.tryParse(u);
      if (parsed == null || (parsed.scheme != 'http' && parsed.scheme != 'https')) {
        throw ArgumentError('Invalid URL: $u');
      }
    }
  }
}
