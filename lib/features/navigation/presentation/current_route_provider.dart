import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Committed top-route URI, including system Back and pushed replacements.
/// Parent GoRouterState and browser route information can retain the base URI.
final currentRouteUriProvider = Provider.autoDispose.family<Uri, GoRouter>((
  ref,
  router,
) {
  final delegate = router.routerDelegate;
  delegate.addListener(ref.invalidateSelf);
  ref.onDispose(() => delegate.removeListener(ref.invalidateSelf));
  return delegate.state.uri;
});
