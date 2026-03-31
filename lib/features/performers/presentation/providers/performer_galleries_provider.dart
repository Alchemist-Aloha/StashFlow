import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';

part 'performer_galleries_provider.g.dart';

class PerformerGalleryItem {
  const PerformerGalleryItem({
    required this.galleryId,
    required this.title,
    required this.thumbnailUrl,
  });

  final String galleryId;
  final String title;
  final String thumbnailUrl;
}

@riverpod
FutureOr<List<PerformerGalleryItem>> performerGalleries(
  Ref ref,
  String performerId,
) async {
  ref.keepAlive();
  final repository = ref.read(galleryRepositoryProvider);

  final galleries = await repository.findGalleries(
    perPage: 24,
    performerId: performerId,
  );

  final prefs = ref.read(sharedPreferencesProvider);
  final storedServerUrl = prefs.getString('server_base_url')?.trim() ?? '';
  final normalizedServerUrl = normalizeGraphqlServerUrl(storedServerUrl);
  final endpoint = Uri.parse(
    normalizedServerUrl.isEmpty
        ? 'http://localhost:9999/graphql'
        : normalizedServerUrl,
  );

  return galleries
      .map(
        (gallery) => PerformerGalleryItem(
          galleryId: gallery.id,
          title: gallery.displayName,
          thumbnailUrl: resolveGraphqlMediaUrl(
            rawUrl: '/gallery/${gallery.id}/thumbnail', // Standard Stash thumbnail path
            graphqlEndpoint: endpoint,
          ),
        ),
      )
      .toList();
}
