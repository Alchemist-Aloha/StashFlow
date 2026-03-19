import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../domain/entities/performer.dart';

class PerformerCard extends ConsumerWidget {
  final Performer performer;
  final VoidCallback? onTap;

  const PerformerCard({required this.performer, this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ClipOval(
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  performer.imagePath ?? '',
                  headers: mediaHeaders,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            performer.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${performer.sceneCount} scenes',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
