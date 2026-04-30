import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../domain/entities/performer.dart';
import '../../../../core/presentation/theme/app_theme.dart';

class PerformerCard extends ConsumerWidget {
  const PerformerCard.skeleton({
    this.onTap,
    this.memCacheWidth,
    super.key,
  }) : performer = const Performer(
         id: 'skeleton',
         name: 'Loading',
         disambiguation: null,
         urls: [],
         gender: null,
         birthdate: null,
         ethnicity: null,
         country: null,
         eyeColor: null,
         heightCm: null,
         measurements: null,
         fakeTits: null,
         penisLength: null,
         circumcised: null,
         careerStart: null,
         careerEnd: null,
         tattoos: null,
         piercings: null,
         aliasList: [],
         favorite: false,
         imagePath: null,
         sceneCount: 0,
         imageCount: 0,
         galleryCount: 0,
         groupCount: 0,
         rating100: null,
         details: null,
         deathDate: null,
         hairColor: null,
         weight: null,
         tagIds: [],
         tagNames: [],
       ),
       skeletonize = true;

  final Performer performer;
  final VoidCallback? onTap;
  final int? memCacheWidth;
  final bool skeletonize;

  const PerformerCard({
    required this.performer,
    this.onTap,
    this.memCacheWidth,
    this.skeletonize = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Skeletonizer(
      enabled: skeletonize,
      effect: const ShimmerEffect(duration: Duration(seconds: 2)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(context.dimensions.spacingSmall / 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;
                    return Center(
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: ClipOval(
                          child: StashImage(
                            imageUrl: performer.imagePath ?? '',
                            fit: BoxFit.cover,
                            memCacheWidth: memCacheWidth ?? 300,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: context.dimensions.spacingSmall),
              Text(
                performer.name,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: context.dimensions.cardTitleFontSize *
                      context.dimensions.fontSizeFactor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
