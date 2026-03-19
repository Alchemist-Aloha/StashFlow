import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../providers/performer_media_provider.dart';
import '../providers/performer_details_provider.dart';

class PerformerDetailsPage extends ConsumerWidget {
  final String performerId;
  const PerformerDetailsPage({required this.performerId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performerAsync = ref.watch(performerDetailsProvider(performerId));
    final mediaAsync = ref.watch(performerMediaProvider(performerId));
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Performer Details')),
      body: performerAsync.when(
        data: (performer) => SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: performer.imagePath != null
                      ? DecorationImage(
                          image: NetworkImage(
                            performer.imagePath!,
                            headers: mediaHeaders,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[900],
                ),
                child: performer.imagePath == null
                    ? const Icon(Icons.person, size: 100, color: Colors.white54)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performer.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (performer.disambiguation != null)
                      Text(
                        performer.disambiguation!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Gender', performer.gender),
                    _buildInfoRow('Birthdate', performer.birthdate),
                    _buildInfoRow('Country', performer.country),
                    _buildInfoRow('Ethnicity', performer.ethnicity),
                    _buildInfoRow('Height', '${performer.heightCm ?? "-"} cm'),
                    _buildInfoRow('Eye Color', performer.eyeColor),
                    _buildInfoRow('Hair Color', performer.hairColor),
                    const Divider(height: 32, color: Colors.grey),
                    const Text(
                      'Media',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    mediaAsync.when(
                      data: (mediaItems) {
                        if (mediaItems.isEmpty) {
                          return const Text(
                            'No media available.',
                            style: TextStyle(color: Colors.white70),
                          );
                        }

                        return SizedBox(
                          height: 138,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: mediaItems.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final item = mediaItems[index];
                              return InkWell(
                                onTap: () => context.push('/scene/${item.sceneId}'),
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 200,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          item.thumbnailUrl,
                                          headers: mediaHeaders,
                                          width: 200,
                                          height: 112,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            width: 200,
                                            height: 112,
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.movie,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const SizedBox(
                        height: 60,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => Text(
                        'Failed to load media: $err',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    const Divider(height: 32, color: Colors.grey),
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      performer.details ?? 'No details available.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty || value == '- cm') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
