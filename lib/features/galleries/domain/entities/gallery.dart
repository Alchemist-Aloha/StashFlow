class Gallery {
  final String id;
  final String title;
  final String? date;
  final int? rating100;
  final int? imageCount;
  final String? details;
  final String? path;

  const Gallery({
    required this.id,
    required this.title,
    this.date,
    this.rating100,
    this.imageCount,
    this.details,
    this.path,
  });

  /// The display title of the gallery.
  ///
  /// Returns [title] if it is not empty, otherwise returns the filestem
  /// from [path], and finally 'Untitled gallery' if neither is available.
  String get displayName {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isNotEmpty) return trimmedTitle;

    if (path != null && path!.isNotEmpty) {
      final normalized = path!.replaceAll('\\', '/');
      final segments = normalized.split('/');
      final filename = segments.lastWhere((s) => s.isNotEmpty, orElse: () => '');
      if (filename.isNotEmpty) {
        final dotIndex = filename.lastIndexOf('.');
        final stem = dotIndex > 0 ? filename.substring(0, dotIndex) : filename;
        final cleaned = stem.replaceAll(RegExp(r'[_\.]+'), ' ').trim();
        if (cleaned.isNotEmpty) return cleaned;
      }
    }

    return 'Untitled gallery';
  }

  factory Gallery.fromJson(Map<String, dynamic> json) {
    String? path;
    final files = json['files'] as List<dynamic>?;
    if (files != null && files.isNotEmpty) {
      path = files.first['path']?.toString();
    }

    return Gallery(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString(),
      rating100: json['rating100'] as int?,
      imageCount: json['image_count'] as int?,
      details: json['details']?.toString(),
      path: path,
    );
  }
}
