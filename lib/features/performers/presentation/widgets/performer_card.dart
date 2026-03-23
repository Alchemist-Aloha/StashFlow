import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../domain/entities/performer.dart';
import '../../../../core/presentation/theme/app_theme.dart';

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
                    color: context.colors.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            performer.name,
            style: TextStyle(
              color: context.colors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${performer.sceneCount} scenes',
            style: TextStyle(
              color: context.colors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
