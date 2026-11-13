import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setup/presentation/providers/server_profiles_provider.dart';
import '../providers/image_browser_context.dart';

/// Owns transient browsing state for a grid and its fullscreen child route.
/// Popping the route (or switching servers) disposes the entire query session.
class ImageBrowserScope extends ConsumerWidget {
  const ImageBrowserScope({
    required this.browser,
    required this.child,
    super.key,
  });

  final ImageBrowserContext browser;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileId = ref.watch(activeServerProfileIdProvider);
    return ProviderScope(
      key: ValueKey((browser.path, profileId)),
      overrides: [imageBrowserContextProvider.overrideWithValue(browser)],
      child: child,
    );
  }
}
