import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scene.dart';

/// Represents a potential video stream candidate for a scene.
class StreamChoice {
  const StreamChoice({required this.url, required this.mimeType, this.label});

  /// The absolute URL to the video stream.
  final String url;

  /// The MIME type of the stream (e.g., 'video/mp4', 'application/vnd.apple.mpegurl').
  final String mimeType;

  /// A human-readable label from the server (e.g., 'Direct', 'HLS').
  final String? label;
}

typedef StreamResolver = Future<StreamChoice?> Function(Scene scene);

final streamResolverProvider = Provider<StreamResolver>(
  (ref) => resolvePreferredStream,
);

/// Resolves Stash's direct file stream, or `null` when no path is available.
Future<StreamChoice?> resolvePreferredStream(Scene scene) async {
  final url = scene.paths.stream?.trim();
  if (url == null || url.isEmpty) return null;
  return StreamChoice(url: url, mimeType: 'video/mp4', label: 'Direct');
}
