import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../setup/presentation/providers/navigation_tabs_provider.dart';

/// Location of gallery details, opened from the shell branch active at [context].
///
/// The Galleries branch uses `/galleries/gallery/:id`. Other branches borrow a
/// per-branch copy (`/galleries/from/<tab>/:id`) because each scoped gallery
/// route owns a nested Navigator whose GlobalKey may exist only once: reusing
/// the Galleries branch route while that tab keeps a gallery open duplicates it.
String galleryLocation(BuildContext context, String galleryId) {
  final id = Uri.encodeComponent(galleryId);
  final index = StatefulNavigationShell.maybeOf(context)?.currentIndex;
  if (index == null || index == NavigationTabType.galleries.index) {
    return '/galleries/gallery/$id';
  }
  return '/galleries/from/${NavigationTabType.values[index].name}/$id';
}
