import 'package:material_ui/material_ui.dart';

/// Android predictive-back transitions that ignore Back while the route's
/// shell branch is hidden.
///
/// Flutter commits a predictive back gesture on every route detector that
/// accepts it. Each [StatefulShellRoute] branch keeps its own Navigator, so the
/// top page of a hidden branch is still `isCurrent` and would be popped behind
/// go_router's back, leaving the branch's restored location pointing at a page
/// that no longer exists. Hidden branches are wrapped in a disabled
/// [TickerMode]; blocking pops there makes `popGestureEnabled` false for them.
/// The [PopScope] is always present so toggling it never remounts the page.
class BranchAwarePredictiveBackPageTransitionsBuilder
    extends PageTransitionsBuilder {
  const BranchAwarePredictiveBackPageTransitionsBuilder();

  static const _delegate = PredictiveBackPageTransitionsBuilder();

  @override
  Duration get transitionDuration => _delegate.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _delegate.reverseTransitionDuration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      _delegate.delegatedTransition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return PopScope<T>(
      canPop: TickerMode.valuesOf(context).enabled,
      child: _delegate.buildTransitions(
        route,
        context,
        animation,
        secondaryAnimation,
        child,
      ),
    );
  }
}
