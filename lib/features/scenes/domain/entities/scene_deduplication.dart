class SceneDuplicateFile {
  const SceneDuplicateFile({
    required this.id,
    required this.path,
    required this.size,
    required this.width,
    required this.height,
    required this.bitRate,
    required this.duration,
    required this.videoCodec,
    required this.modTime,
  });

  final String id;
  final String path;
  final int size;
  final int width;
  final int height;
  final int bitRate;
  final double duration;
  final String? videoCodec;
  final DateTime? modTime;

  int get resolutionPixels => width * height;
}

class SceneDuplicateScene {
  const SceneDuplicateScene({
    required this.id,
    required this.title,
    required this.path,
    required this.spritePath,
    required this.organized,
    required this.oCounter,
    required this.tagCount,
    required this.performerCount,
    required this.groupCount,
    required this.markerCount,
    required this.galleryCount,
    required this.fileCount,
    required this.files,
  });

  final String id;
  final String title;
  final String? path;
  final String? spritePath;
  final bool organized;
  final int oCounter;
  final int tagCount;
  final int performerCount;
  final int groupCount;
  final int markerCount;
  final int galleryCount;
  final int fileCount;
  final List<SceneDuplicateFile> files;

  SceneDuplicateFile? get primaryFile => files.isEmpty ? null : files.first;

  int get totalFileSize => files.fold(0, (total, file) => total + file.size);

  int get largestFileSize => files.fold(
    0,
    (largest, file) => file.size > largest ? file.size : largest,
  );

  int get largestResolutionPixels => files.fold(
    0,
    (largest, file) =>
        file.resolutionPixels > largest ? file.resolutionPixels : largest,
  );
}

class SceneDuplicateGroup {
  const SceneDuplicateGroup({required this.scenes});

  final List<SceneDuplicateScene> scenes;

  int get totalFileSize =>
      scenes.fold(0, (total, scene) => total + scene.totalFileSize);
}

enum DuplicateSelectionMode {
  allButLargestFile,
  allButLargestResolution,
  allButOldest,
  allButYoungest,
}

List<SceneDuplicateGroup> sortDuplicateGroupsBySize(
  List<SceneDuplicateGroup> groups,
) {
  return [...groups]
    ..sort((a, b) => b.totalFileSize.compareTo(a.totalFileSize));
}

Set<String> selectDuplicateScenes({
  required List<SceneDuplicateGroup> groups,
  required DuplicateSelectionMode mode,
  required bool safeSelect,
}) {
  final selected = <String>{};

  for (final group in groups) {
    if (group.scenes.isEmpty) continue;
    if (safeSelect && !_sameCodec(group.scenes)) continue;

    final keep = switch (mode) {
      DuplicateSelectionMode.allButLargestFile => _largestFileScene(
        group.scenes,
      ),
      DuplicateSelectionMode.allButLargestResolution => _largestResolutionScene(
        group.scenes,
      ),
      DuplicateSelectionMode.allButOldest => _sceneByAge(
        group.scenes,
        oldest: true,
      ),
      DuplicateSelectionMode.allButYoungest => _sceneByAge(
        group.scenes,
        oldest: false,
      ),
    };

    if (keep == null) continue;
    if (mode == DuplicateSelectionMode.allButLargestResolution &&
        _sameResolution(group.scenes)) {
      continue;
    }

    for (final scene in group.scenes) {
      if (scene.id != keep.id) selected.add(scene.id);
    }
  }

  return selected;
}

bool _sameCodec(List<SceneDuplicateScene> scenes) {
  return scenes.map((scene) => scene.primaryFile?.videoCodec).toSet().length ==
      1;
}

bool _sameResolution(List<SceneDuplicateScene> scenes) {
  return scenes
          .map((scene) => scene.primaryFile?.resolutionPixels ?? 0)
          .toSet()
          .length ==
      1;
}

SceneDuplicateScene _largestFileScene(List<SceneDuplicateScene> scenes) {
  return scenes.reduce(
    (largest, scene) =>
        scene.largestFileSize > largest.largestFileSize ? scene : largest,
  );
}

SceneDuplicateScene _largestResolutionScene(List<SceneDuplicateScene> scenes) {
  return scenes.reduce(
    (largest, scene) =>
        scene.largestResolutionPixels > largest.largestResolutionPixels
        ? scene
        : largest,
  );
}

SceneDuplicateScene? _sceneByAge(
  List<SceneDuplicateScene> scenes, {
  required bool oldest,
}) {
  SceneDuplicateFile? selectedFile;

  for (final file in scenes.expand((scene) => scene.files)) {
    final modTime = file.modTime;
    if (modTime == null) continue;
    final selectedTime = selectedFile?.modTime;
    if (selectedTime == null ||
        (oldest
            ? modTime.isBefore(selectedTime)
            : modTime.isAfter(selectedTime))) {
      selectedFile = file;
    }
  }

  if (selectedFile == null) return null;
  final selectedFileId = selectedFile.id;
  for (final scene in scenes) {
    if (scene.files.any((file) => file.id == selectedFileId)) {
      return scene;
    }
  }
  return null;
}
