import 'scene.dart';

const Set<String> kGenericSceneFallbackNames = {
  'stream',
  'preview',
  'screenshot',
  'video',
  'play',
  'media',
};

String buildSceneDisplayTitle({
  required String? title,
  String? filePath,
  String? streamPath,
  String fallback = 'Untitled Scene',
}) {
  final trimmed = title?.trim() ?? '';
  if (trimmed.isNotEmpty) return trimmed;

  final fromPath = getFilestem(filePath) ?? getFilestem(streamPath);
  return (fromPath == null || fromPath.isEmpty) ? fallback : fromPath;
}

final _separatorRegExp = RegExp(r'[_\.]+');

String? getFilestem(String? rawPath) {
  if (rawPath == null || rawPath.trim().isEmpty) return null;

  final normalized = rawPath.replaceAll('\\', '/');
  final parsed = Uri.tryParse(normalized);
  final pathPart = (parsed?.hasScheme ?? false)
      ? (parsed?.path ?? normalized)
      : normalized;

  final segments = pathPart
      .split('/')
      .where((part) => part.isNotEmpty)
      .toList();
  final lastSegment = segments.isEmpty ? '' : segments.last;
  if (lastSegment.isEmpty) return null;

  final decoded = _safeDecodeComponent(lastSegment);
  final dotIndex = decoded.lastIndexOf('.');
  final withoutExt = dotIndex > 0 ? decoded.substring(0, dotIndex) : decoded;
  final cleaned = withoutExt.replaceAll(_separatorRegExp, ' ').trim();
  if (cleaned.isEmpty) return null;

  final lower = cleaned.toLowerCase();
  if (kGenericSceneFallbackNames.contains(lower)) return null;
  return cleaned;
}

String _safeDecodeComponent(String value) {
  try {
    return Uri.decodeComponent(value);
  } catch (_) {
    return value;
  }
}

extension SceneDisplayTitleX on Scene {
  String get displayTitle => buildSceneDisplayTitle(
    title: title,
    filePath: path,
    streamPath: paths.stream,
  );
}
