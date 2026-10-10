class Gallery {
  final String id;
  final String title;
  final String? date;
  final int? rating100;
  final int? imageCount;
  final String? details;
  final String? code;
  final List<String> urls;
  final String? photographer;
  final bool? organized;
  final String? createdAt;
  final String? updatedAt;
  final String? path;
  final List<String> filePaths;
  final String? coverPath;
  final int? coverWidth;
  final int? coverHeight;
  final String? studioId;
  final String? studioName;
  final List<String> performerIds;
  final List<String> performerNames;
  final List<String?> performerImagePaths;
  final List<String> tagIds;
  final List<String> tagNames;
  final List<GalleryChapter> chapters;

  static final _separatorRegExp = RegExp(r'[_\.]+');

  const Gallery({
    required this.id,
    required this.title,
    this.date,
    this.rating100,
    this.imageCount,
    this.details,
    this.code,
    this.urls = const [],
    this.photographer,
    this.organized,
    this.createdAt,
    this.updatedAt,
    this.path,
    this.filePaths = const [],
    this.coverPath,
    this.coverWidth,
    this.coverHeight,
    this.studioId,
    this.studioName,
    this.performerIds = const [],
    this.performerNames = const [],
    this.performerImagePaths = const [],
    this.tagIds = const [],
    this.tagNames = const [],
    this.chapters = const [],
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
      final filename = segments.lastWhere(
        (s) => s.isNotEmpty,
        orElse: () => '',
      );
      if (filename.isNotEmpty) {
        final dotIndex = filename.lastIndexOf('.');
        final stem = dotIndex > 0 ? filename.substring(0, dotIndex) : filename;
        final cleaned = stem.replaceAll(_separatorRegExp, ' ').trim();
        if (cleaned.isNotEmpty) return cleaned;
      }
    }

    return 'Untitled gallery';
  }

  factory Gallery.fromJson(Map<String, dynamic> json) {
    String? path;
    final files = json['files'] as List<dynamic>?;
    if (files != null && files.isNotEmpty) {
      path = (files.first as Map<String, dynamic>)['path']?.toString();
    }

    final paths = json['paths'] as Map<String, dynamic>?;
    final coverPath = paths?['cover']?.toString();

    int? coverWidth;
    int? coverHeight;
    final cover = json['cover'] as Map<String, dynamic>?;
    if (cover != null) {
      final visualFiles = cover['visual_files'] as List<dynamic>?;
      if (visualFiles != null && visualFiles.isNotEmpty) {
        final file = visualFiles.first as Map<String, dynamic>;
        coverWidth = file['width'] as int?;
        coverHeight = file['height'] as int?;
      }
    }

    final studio = json['studio'] as Map<String, dynamic>?;
    final performers = (json['performers'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final tags = (json['tags'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final chapters = (json['chapters'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(GalleryChapter.fromJson)
        .toList();
    final filePaths = (files ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((file) => file['path']?.toString() ?? '')
        .where((filePath) => filePath.isNotEmpty)
        .toList();

    return Gallery(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString(),
      rating100: json['rating100'] as int?,
      imageCount: json['image_count'] as int?,
      details: json['details']?.toString(),
      code: json['code']?.toString(),
      urls: (json['urls'] as List<dynamic>? ?? const [])
          .map((url) => url.toString())
          .toList(),
      photographer: json['photographer']?.toString(),
      organized: json['organized'] as bool?,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      path: path,
      filePaths: filePaths,
      coverPath: coverPath,
      coverWidth: coverWidth,
      coverHeight: coverHeight,
      studioId: studio?['id']?.toString(),
      studioName: studio?['name']?.toString(),
      performerIds: performers
          .map((performer) => performer['id']?.toString() ?? '')
          .toList(),
      performerNames: performers
          .map((performer) => performer['name']?.toString() ?? '')
          .toList(),
      performerImagePaths: performers
          .map((performer) => performer['image_path']?.toString())
          .toList(),
      tagIds: tags.map((tag) => tag['id']?.toString() ?? '').toList(),
      tagNames: tags.map((tag) => tag['name']?.toString() ?? '').toList(),
      chapters: chapters,
    );
  }
}

/// A named image position within a gallery.
class GalleryChapter {
  const GalleryChapter({
    required this.id,
    required this.title,
    required this.imageIndex,
  });

  final String id;
  final String title;
  final int imageIndex;

  factory GalleryChapter.fromJson(Map<String, dynamic> json) => GalleryChapter(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    imageIndex: json['image_index'] as int? ?? 0,
  );
}
