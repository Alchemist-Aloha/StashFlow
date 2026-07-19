import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';

part 'stream_resolver.g.dart';

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

/// Resolves Stash's direct file stream for a [Scene].
@riverpod
class StreamResolver extends _$StreamResolver {
  @override
  void build() {}

  /// Returns `null` when Stash did not provide a direct stream path.
  Future<StreamChoice?> resolvePreferredStream(Scene scene) async {
    final url = scene.paths.stream?.trim();
    if (url == null || url.isEmpty) return null;
    return StreamChoice(url: url, mimeType: 'video/mp4', label: 'Direct');
  }
}
