import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'local_caption_model.dart';

/// Atomic model installation. Only verified, revision-matching directories are usable.
class CaptionModelStore {
  CaptionModelStore(this.root, this.dio);
  final Directory root;
  final Dio dio;

  Directory directory(LocalCaptionModel model) =>
      Directory(p.join(root.path, model.id));

  Future<bool> isInstalled(LocalCaptionModel model) async {
    final dir = directory(model);
    final marker = File(p.join(dir.path, '.verified'));
    if (!await marker.exists() ||
        await marker.readAsString() != model.revision) {
      return false;
    }
    for (final file in model.files) {
      final local = File(p.join(dir.path, file.name));
      if (!await local.exists() || await local.length() != file.bytes) {
        return false;
      }
    }
    return true;
  }

  /// Restores downloaded snapshots without contacting the Hub. Older installs
  /// lacking a manifest keep their original pinned migration snapshot.
  Future<List<LocalCaptionModel>> readInstalled() async {
    final models = <String, LocalCaptionModel>{};
    if (await root.exists()) {
      await for (final entity in root.list(followLinks: false)) {
        if (entity is! Directory) continue;
        final manifest = File(p.join(entity.path, '.manifest.json'));
        if (!await manifest.exists() || await manifest.length() > 1000000) {
          continue;
        }
        try {
          final model = LocalCaptionModel.fromJson(
            (jsonDecode(await manifest.readAsString()) as Map)
                .cast<String, dynamic>(),
          );
          if (p.basename(entity.path) == model.id && await isInstalled(model)) {
            models[model.id] = model;
          }
        } on Object {
          /* Ignore incomplete or invalid snapshots. */
        }
      }
    }
    for (final model in LocalCaptionModel.catalog) {
      if (!models.containsKey(model.id) && await isInstalled(model)) {
        models[model.id] = model;
      }
    }
    return models.values.toList();
  }

  Future<void> install(
    LocalCaptionModel model, {
    required CancelToken cancel,
    required void Function(double) onProgress,
  }) async {
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(model.id) ||
        model.files.any((f) => p.basename(f.name) != f.name || f.bytes <= 0)) {
      throw const FormatException('Invalid model manifest');
    }
    await root.create(recursive: true);
    if (await isInstalled(model)) return;
    final staging = await root.createTemp('.download-');
    try {
      var completed = 0;
      for (final file in model.files) {
        if (cancel.isCancelled) {
          throw cancel.cancelError!;
        }
        final path = p.join(staging.path, file.name);
        await dio.download(
          model.url(file),
          path,
          cancelToken: cancel,
          options: Options(receiveTimeout: const Duration(minutes: 5)),
          onReceiveProgress: (received, _) {
            if (received > file.bytes) cancel.cancel('Unexpected model size');
            onProgress(((completed + received) / model.bytes).clamp(0, 1));
          },
        );
        if (cancel.isCancelled) {
          throw cancel.cancelError!;
        }
        final local = File(path);
        if (await local.length() != file.bytes ||
            (await sha256.bind(local.openRead()).first).toString() !=
                file.sha256) {
          throw const FormatException('Model integrity check failed');
        }
        completed += file.bytes;
      }
      if (cancel.isCancelled) {
        throw cancel.cancelError!;
      }
      await File(
        p.join(staging.path, '.manifest.json'),
      ).writeAsString(jsonEncode(model.toJson()));
      await File(
        p.join(staging.path, '.verified'),
      ).writeAsString(model.revision);
      final destination = directory(model);
      if (await destination.exists()) await destination.delete(recursive: true);
      await staging.rename(destination.path);
    } finally {
      if (await staging.exists()) await staging.delete(recursive: true);
    }
  }

  Future<void> delete(LocalCaptionModel model) async {
    final dir = directory(model);
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
