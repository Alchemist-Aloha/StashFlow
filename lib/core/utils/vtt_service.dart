import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../features/scenes/domain/entities/sprite_info.dart';
import '../data/graphql/url_resolver.dart';
import '../data/graphql/graphql_client.dart';
import 'app_log_store.dart';

final vttServiceProvider = Provider<VttService>((ref) {
  final apiKey = ref.watch(serverApiKeyProvider);
  return VttService(apiKey: apiKey);
});

class VttService {
  VttService({this.apiKey});

  final String? apiKey;
  final Map<String, List<SpriteInfo>> _cache = {};

  Future<List<SpriteInfo>?> fetchSpriteInfo(
    String vttUrl,
    Map<String, String>? headers,
  ) async {
    var effectiveUrl = vttUrl;
    if (apiKey != null && apiKey!.isNotEmpty) {
      effectiveUrl = appendApiKey(vttUrl, apiKey!);
    }

    if (_cache.containsKey(effectiveUrl)) {
      return _cache[effectiveUrl];
    }

    AppLogStore.instance.add(
      'Fetching VTT: $effectiveUrl',
      source: 'VttService',
    );

    try {
      final response = await http.get(
        Uri.parse(effectiveUrl),
        headers: headers,
      );
      if (response.statusCode != 200) {
        if (response.statusCode != 404) {
          AppLogStore.instance.add(
            'Failed to fetch VTT: ${response.statusCode}',
            source: 'VttService',
          );
        }
        // Cache the failure so we don't spam 404s
        _cache[effectiveUrl] = [];
        return [];
      }

      final spriteInfoList = _parseVtt(response.body, effectiveUrl);
      AppLogStore.instance.add(
        'Parsed ${spriteInfoList.length} sprites from VTT',
        source: 'VttService',
      );
      _cache[effectiveUrl] = spriteInfoList;
      return spriteInfoList;
    } catch (e) {
      AppLogStore.instance.add('Error fetching VTT: $e', source: 'VttService');
      return null;
    }
  }

  List<SpriteInfo> _parseVtt(String vttBody, String vttUrl) {
    final List<SpriteInfo> sprites = [];
    final lines = vttBody.split('\n');

    final spriteRegExp = RegExp(
      r'^([^#]*)#xywh=(\d+),(\d+),(\d+),(\d+)$',
      caseSensitive: false,
    );

    // Robust VTT parser for Stash sprite format
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.contains('-->')) {
        final times = line.split('-->');
        if (times.length == 2) {
          final start = _parseTimestamp(times[0].trim());
          final end = _parseTimestamp(times[1].trim());

          // Look for the next non-empty line
          String? spriteLine;
          for (int j = i + 1; j < lines.length; j++) {
            final nextLine = lines[j].trim();
            if (nextLine.isNotEmpty) {
              spriteLine = nextLine;
              i = j; // Skip parsed lines in the outer loop
              break;
            }
          }

          if (spriteLine != null) {
            final match = spriteRegExp.firstMatch(spriteLine);
            if (match != null) {
              final spriteFile = match.group(1) ?? '';
              final x = double.parse(match.group(2)!);
              final y = double.parse(match.group(3)!);
              final w = double.parse(match.group(4)!);
              final h = double.parse(match.group(5)!);

              // Resolve relative sprite URL
              final vttUri = Uri.parse(vttUrl);
              var spriteUrl = vttUri.resolve(spriteFile).toString();

              if (apiKey != null && apiKey!.isNotEmpty) {
                spriteUrl = appendApiKey(spriteUrl, apiKey!);
              }

              sprites.add(
                SpriteInfo(
                  url: spriteUrl,
                  start: start,
                  end: end,
                  x: x,
                  y: y,
                  w: w,
                  h: h,
                ),
              );
            }
          }
        }
      }
    }

    return sprites;
  }

  double _parseTimestamp(String timestamp) {
    final parts = timestamp.split(':');
    if (parts.length == 3) {
      final hours = double.parse(parts[0]);
      final minutes = double.parse(parts[1]);
      final seconds = double.parse(parts[2]);
      return hours * 3600 + minutes * 60 + seconds;
    } else if (parts.length == 2) {
      final minutes = double.parse(parts[0]);
      final seconds = double.parse(parts[1]);
      return minutes * 60 + seconds;
    }
    return 0.0;
  }
}
