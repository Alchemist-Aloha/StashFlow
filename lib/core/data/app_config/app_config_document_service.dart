import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Presents platform-appropriate import and export surfaces.
final class AppConfigDocumentService {
  const AppConfigDocumentService();

  static const extension = 'stashflow-config.json';
  static const _types = <XTypeGroup>[
    XTypeGroup(
      label: 'StashFlow configuration',
      extensions: ['json'],
      mimeTypes: ['application/json'],
      uniformTypeIdentifiers: ['public.json'],
    ),
  ];

  Future<Uint8List?> pickForImport() async {
    final file = await openFile(acceptedTypeGroups: _types);
    if (file == null) return null;
    return file.readAsBytes();
  }

  Future<bool> export(
    Uint8List bytes, {
    required String fileName,
    Rect? sharePositionOrigin,
  }) async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows)) {
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: _types,
      );
      if (location == null) return false;
      await XFile.fromData(
        bytes,
        mimeType: 'application/json',
        name: fileName,
      ).saveTo(location.path);
      return true;
    }

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'application/json', name: fileName),
        ],
        sharePositionOrigin: sharePositionOrigin,
        downloadFallbackEnabled: true,
      ),
    );
    return true;
  }
}
