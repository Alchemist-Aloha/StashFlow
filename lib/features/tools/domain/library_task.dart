/// Library-wide operations supported by the server's Tasks screen.
enum LibraryTask { scan, generate }

const scanOptionKeys = [
  'scanGenerateCovers',
  'scanGeneratePreviews',
  'scanGenerateImagePreviews',
  'scanGenerateSprites',
  'scanGeneratePhashes',
  'scanGenerateThumbnails',
  'scanGenerateImagePhashes',
  'scanGenerateClipPreviews',
  'rescan',
];

const generateOptionKeys = [
  'covers',
  'previews',
  'imagePreviews',
  'sprites',
  'markers',
  'markerImagePreviews',
  'markerScreenshots',
  'transcodes',
  'phashes',
  'interactiveHeatmapsSpeeds',
  'clipPreviews',
  'imageThumbnails',
  'imagePhashes',
  'overwrite',
];

Map<String, dynamic> _object(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};

/// Effective task defaults, library roots and current server preview settings.
/// UI task defaults take precedence over legacy configuration.defaults.
class LibraryTaskSettings {
  LibraryTaskSettings.fromJson(Map<String, dynamic> configuration) {
    final defaults = _object(configuration['defaults']);
    final tasks = _object(_object(configuration['ui'])['taskDefaults']);
    final general = _object(configuration['general']);
    scan = _options(tasks['scan'] ?? defaults['scan'], scanOptionKeys, const {
      'scanGenerateCovers',
    });
    generate = _options(
      tasks['generate'] ?? defaults['generate'],
      generateOptionKeys,
      const {'covers', 'sprites', 'phashes', 'previews', 'markers'},
    );
    previewOptions = {
      ..._object(
        _object(tasks['generate'] ?? defaults['generate'])['previewOptions'],
      ),
      for (final key in const [
        'previewSegments',
        'previewSegmentDuration',
        'previewExcludeStart',
        'previewExcludeEnd',
        'previewPreset',
      ])
        if (general[key] != null) key: general[key],
    }..remove('__typename');
    libraryPaths = [
      for (final stash in general['stashes'] as List? ?? const [])
        if (_object(stash)['path'] case final String path) path,
    ];
  }

  late final Map<String, bool> scan;
  late final Map<String, bool> generate;
  late final Map<String, dynamic> previewOptions;
  late final List<String> libraryPaths;

  Map<String, bool> options(LibraryTask task) =>
      task == LibraryTask.scan ? scan : generate;

  static Map<String, bool> _options(
    Object? source,
    List<String> keys,
    Set<String> enabledFallback,
  ) {
    final values = _object(source);
    return {
      for (final key in keys)
        key: source == null
            ? enabledFallback.contains(key)
            : values[key] == true,
    };
  }
}

/// A server directory, never a path on the device running StashFlow.
class ServerDirectory {
  const ServerDirectory({
    required this.path,
    this.parent,
    required this.children,
  });
  final String path;
  final String? parent;
  final List<String> children;
}

/// Server-provided queue entry; descriptions and subtasks are remote content.
class LibraryJob {
  const LibraryJob({
    required this.id,
    required this.status,
    required this.description,
    this.progress,
    this.subTasks = const [],
    this.error,
    this.startTime,
  });
  final String id;
  final String status;
  final String description;
  final double? progress;
  final List<String> subTasks;
  final String? error;
  final DateTime? startTime;
  bool get canStop => status == 'READY' || status == 'RUNNING';
}
