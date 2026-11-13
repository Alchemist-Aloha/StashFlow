import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

const Set<PointerDeviceKind> _kPinchDevices = {
  PointerDeviceKind.touch,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.unknown,
};

/// Pinch, double-tap, and mouse-wheel zoom for one page of an image pager.
///
/// Panning is bounded by the fitted image, not the letterboxed viewport. A
/// zoomed image pans until its edge along [axis]; further one-finger drags
/// that way move [pageController], so a parent [PageView] should be locked
/// (see [onZoomChanged]) while zoomed. Unzoomed, one-finger drags are left
/// to the pager at any angle, and only pinch or wheel input starts a zoom.
class ZoomableImage extends StatefulWidget {
  const ZoomableImage({
    required this.child,
    required this.pageController,
    required this.axis,
    this.contentSize,
    this.onZoomChanged,
    super.key,
  });

  /// Content painted to fill this widget, typically with [BoxFit.contain].
  final Widget child;

  /// Pager that receives drags once the zoomed image reaches its edge.
  final PageController pageController;

  /// Paging axis of [pageController].
  final Axis axis;

  /// Intrinsic content size; null treats the whole viewport as content.
  final Size? contentSize;

  /// Reports crossing into or out of a zoomed (> 1x) state.
  final ValueChanged<bool>? onZoomChanged;

  static const double maxScale = 5;
  static const double doubleTapScale = 3;

  @override
  State<ZoomableImage> createState() => ZoomableImageState();
}

/// Public for tests that assert the current transform.
class ZoomableImageState extends State<ZoomableImage>
    with SingleTickerProviderStateMixin {
  // Gestures may overshoot the limits and spring back when released.
  static const double _minGestureScale = 0.8;
  static const double _maxGestureScale = ZoomableImage.maxScale * 1.2;

  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..addListener(_onAnimationTick);
  double _fromScale = 1;
  double _toScale = 1;
  Offset _fromOffset = Offset.zero;
  Offset _toOffset = Offset.zero;

  double _scale = 1;
  Offset _offset = Offset.zero;
  double _gestureStartScale = 1;
  Offset _lastFocal = Offset.zero;
  Offset _doubleTapPosition = Offset.zero;
  Size _viewport = Size.zero;
  Drag? _pageDrag;
  bool _reportedZoomed = false;

  @visibleForTesting
  double get scale => _scale;

  @visibleForTesting
  Offset get offset => _offset;

  bool get _zoomed => _scale > 1.001;

  @override
  void dispose() {
    _pageDrag?.cancel();
    _animation.dispose();
    super.dispose();
  }

  /// Fitted content rect at 1x, inside the viewport.
  Rect get _baseRect {
    final viewportRect = Offset.zero & _viewport;
    final size = widget.contentSize;
    if (size == null || size.isEmpty) return viewportRect;
    final fitted = applyBoxFit(BoxFit.contain, size, _viewport).destination;
    return Alignment.center.inscribe(fitted, viewportRect);
  }

  /// Centers content smaller than the viewport and keeps larger content
  /// covering it, per axis.
  Offset _clamp(Offset offset, double scale) {
    final base = _baseRect;
    double clampAxis(double value, double start, double extent, double view) {
      final pos = start * scale;
      final size = extent * scale;
      if (size <= view) return (view - size) / 2 - pos;
      return value.clamp(view - size - pos, -pos);
    }

    return Offset(
      clampAxis(offset.dx, base.left, base.width, _viewport.width),
      clampAxis(offset.dy, base.top, base.height, _viewport.height),
    );
  }

  /// Offset that keeps [focal] over the same content point at [scale].
  Offset _offsetForScaleAt(Offset focal, double scale) =>
      focal - (focal - _offset) * (scale / _scale);

  void _setTransform(double scale, Offset offset) {
    setState(() {
      _scale = scale;
      _offset = offset;
    });
    final zoomed = _zoomed;
    if (zoomed != _reportedZoomed) {
      _reportedZoomed = zoomed;
      widget.onZoomChanged?.call(zoomed);
    }
  }

  void _animateTo(double scale, Offset offset) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
      _setTransform(scale, offset);
      return;
    }
    _fromScale = _scale;
    _fromOffset = _offset;
    _toScale = scale;
    _toOffset = offset;
    _animation.forward(from: 0);
  }

  void _onAnimationTick() {
    final t = Curves.easeOutCubic.transform(_animation.value);
    _setTransform(
      _fromScale + (_toScale - _fromScale) * t,
      Offset.lerp(_fromOffset, _toOffset, t)!,
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _animation.stop();
    _gestureStartScale = _scale;
    _lastFocal = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_pageDrag != null) {
      _updatePageDrag(details.focalPoint, details.focalPointDelta);
      return;
    }
    // Local delta: a forwarded pinch may run while the page still settles.
    final focal = details.localFocalPoint;
    final delta = focal - _lastFocal;
    _lastFocal = focal;
    if (details.pointerCount == 1 && _zoomed && _isPastEdge(delta)) {
      _pageDrag = widget.pageController.position.drag(
        DragStartDetails(
          globalPosition: details.focalPoint,
          localPosition: details.localFocalPoint,
        ),
        () => _pageDrag = null,
      );
      _updatePageDrag(details.focalPoint, details.focalPointDelta);
      return;
    }

    final scale = (_gestureStartScale * details.scale).clamp(
      _minGestureScale,
      _maxGestureScale,
    );
    final panned = _offset + delta;
    _setTransform(
      scale,
      _clamp(focal - (focal - panned) * (scale / _scale), scale),
    );
  }

  Offset _toLocal(Offset global) =>
      (context.findRenderObject()! as RenderBox).globalToLocal(global);

  /// Drives a pinch claimed by [ZoomablePagerPinch] in global coordinates.
  void handleScaleStart(ScaleStartDetails details) => _onScaleStart(
    ScaleStartDetails(
      focalPoint: details.focalPoint,
      localFocalPoint: _toLocal(details.focalPoint),
      pointerCount: details.pointerCount,
    ),
  );

  /// See [handleScaleStart].
  void handleScaleUpdate(ScaleUpdateDetails details) => _onScaleUpdate(
    ScaleUpdateDetails(
      focalPoint: details.focalPoint,
      localFocalPoint: _toLocal(details.focalPoint),
      scale: details.scale,
      horizontalScale: details.horizontalScale,
      verticalScale: details.verticalScale,
      rotation: details.rotation,
      pointerCount: details.pointerCount,
      focalPointDelta: details.focalPointDelta,
    ),
  );

  /// See [handleScaleStart].
  void handleScaleEnd(ScaleEndDetails details) => _onScaleEnd(details);

  /// Whether a drag mostly along [ZoomableImage.axis] cannot pan any further.
  bool _isPastEdge(Offset delta) {
    final horizontal = widget.axis == Axis.horizontal;
    final along = horizontal ? delta.dx : delta.dy;
    final across = horizontal ? delta.dy : delta.dx;
    if (along == 0 || along.abs() <= across.abs()) return false;
    final moved = _clamp(_offset + delta, _scale) - _offset;
    return (horizontal ? moved.dx : moved.dy).abs() < 0.5;
  }

  void _updatePageDrag(Offset globalPosition, Offset delta) {
    final along = widget.axis == Axis.horizontal ? delta.dx : delta.dy;
    _pageDrag?.update(
      DragUpdateDetails(
        globalPosition: globalPosition,
        delta: widget.axis == Axis.horizontal
            ? Offset(along, 0)
            : Offset(0, along),
        primaryDelta: along,
      ),
    );
  }

  void _onScaleEnd(ScaleEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final pageDrag = _pageDrag;
    if (pageDrag != null) {
      final along = widget.axis == Axis.horizontal ? velocity.dx : velocity.dy;
      pageDrag.end(
        DragEndDetails(
          velocity: Velocity(
            pixelsPerSecond: widget.axis == Axis.horizontal
                ? Offset(along, 0)
                : Offset(0, along),
          ),
          primaryVelocity: along,
        ),
      );
      _pageDrag = null;
      return;
    }

    if (_scale < 1) {
      _animateTo(1, _clamp(Offset.zero, 1));
    } else if (_scale > ZoomableImage.maxScale) {
      const scale = ZoomableImage.maxScale;
      _animateTo(scale, _clamp(_offsetForScaleAt(_lastFocal, scale), scale));
    } else if (_zoomed && velocity.distance >= kMinFlingVelocity) {
      // Short inertial glide, bounded by the image edges.
      _animateTo(_scale, _clamp(_offset + velocity * 0.2, _scale));
    }
  }

  void _onDoubleTap() {
    final scale = _zoomed ? 1.0 : ZoomableImage.doubleTapScale;
    _animateTo(
      scale,
      _clamp(_offsetForScaleAt(_doubleTapPosition, scale), scale),
    );
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || event.kind != PointerDeviceKind.mouse) {
      return;
    }
    // Claim the wheel so the pager does not also scroll.
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      final dy = (event as PointerScrollEvent).scrollDelta.dy;
      _animation.stop();
      final scale = (_scale * math.pow(2, -dy / 400)).clamp(
        1.0,
        ZoomableImage.maxScale,
      );
      _setTransform(
        scale,
        _clamp(_offsetForScaleAt(event.localPosition, scale), scale),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final zoomed = _zoomed;
    final deviceSettings = MediaQuery.maybeGestureSettingsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.biggest;
        if (viewport != _viewport) {
          _viewport = viewport;
          _offset = _clamp(_offset, _scale);
        }
        return Listener(
          onPointerSignal: _onPointerSignal,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              ScaleGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
                    () => ScaleGestureRecognizer(debugOwner: this),
                    (recognizer) => recognizer
                      ..dragStartBehavior = DragStartBehavior.down
                      // Unzoomed there is nothing to pan; an unreachable pan
                      // slop leaves one-finger drags to the pager while pinch
                      // still starts through the separate scale slop.
                      ..gestureSettings = zoomed
                          ? deviceSettings
                          : const DeviceGestureSettings(
                              touchSlop: double.infinity,
                            )
                      ..supportedDevices = zoomed ? null : _kPinchDevices
                      ..onStart = _onScaleStart
                      ..onUpdate = _onScaleUpdate
                      ..onEnd = _onScaleEnd,
                  ),
              DoubleTapGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    DoubleTapGestureRecognizer
                  >(
                    () => DoubleTapGestureRecognizer(debugOwner: this),
                    (recognizer) => recognizer
                      ..onDoubleTapDown = (details) {
                        _doubleTapPosition = details.localPosition;
                      }
                      ..onDoubleTap = _onDoubleTap,
                  ),
            },
            child: ClipRect(
              child: Transform(
                transform: Matrix4.diagonal3Values(_scale, _scale, 1)
                  ..setTranslationRaw(_offset.dx, _offset.dy, 0),
                child: SizedBox.fromSize(size: viewport, child: widget.child),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pinch-to-zoom for a pager of [ZoomableImage]s that also works mid-animation.
///
/// While a [PageView] animates, its [Scrollable] ignores pointers for the
/// pages, so a pinch's first finger never reaches the page's own recognizer.
/// This sits above the pager, sees every finger, and forwards the pinch to
/// the page nearest the viewport center, which is where the pager settles.
/// It can never claim a one-finger drag, so scrolling is unaffected; when
/// both recognizers see the pinch, the page's deeper one wins.
///
/// A pinch's fingers rarely move apart evenly, so the pager's axis drag (about
/// 8px on Android) would usually beat the 18px scale slop. This therefore
/// claims the gesture as soon as a second finger lands, unless a one-finger
/// swipe has already won.
class ZoomablePagerPinch extends StatefulWidget {
  const ZoomablePagerPinch({required this.child, super.key});

  final Widget child;

  @override
  State<ZoomablePagerPinch> createState() => _ZoomablePagerPinchState();
}

class _ZoomablePagerPinchState extends State<ZoomablePagerPinch> {
  ZoomableImageState? _target;
  ZoomableImageState? _nearestPage() {
    final box = context.findRenderObject()! as RenderBox;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    ZoomableImageState? best;
    var bestDistance = double.infinity;
    void visit(Element element) {
      if (element is StatefulElement && element.state is ZoomableImageState) {
        final page = element.renderObject! as RenderBox;
        final distance =
            (page.localToGlobal(page.size.center(Offset.zero)) - center)
                .distance;
        // Only the page in view; a clip page must not zoom a neighbor.
        if (distance < bestDistance && distance < box.size.longestSide / 2) {
          bestDistance = distance;
          best = element.state as ZoomableImageState;
        }
        return;
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        _EagerPinchGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_EagerPinchGestureRecognizer>(
              () => _EagerPinchGestureRecognizer(debugOwner: this),
              (recognizer) => recognizer
                ..dragStartBehavior = DragStartBehavior.down
                // Unreachable pan slop: only a span change can accept.
                ..gestureSettings = const DeviceGestureSettings(
                  touchSlop: double.infinity,
                )
                ..onStart = (details) {
                  _target = _nearestPage()?..handleScaleStart(details);
                }
                ..onUpdate = (details) {
                  _target?.handleScaleUpdate(details);
                }
                ..onEnd = (details) {
                  _target?.handleScaleEnd(details);
                  _target = null;
                },
            ),
      },
      child: widget.child,
    );
  }
}

/// Accepts as soon as it tracks two pointers, before any movement.
class _EagerPinchGestureRecognizer extends ScaleGestureRecognizer {
  _EagerPinchGestureRecognizer({super.debugOwner})
    : super(supportedDevices: _kPinchDevices);

  final Set<int> _tracked = {};

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _tracked.add(event.pointer);
    if (_tracked.length >= 2) resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _tracked.remove(event.pointer);
    }
    super.handleEvent(event);
  }

  @override
  void rejectGesture(int pointer) {
    // A pointer an axis swipe already won no longer counts toward a pinch.
    _tracked.remove(pointer);
    super.rejectGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _tracked.clear();
    super.didStopTrackingLastPointer(pointer);
  }
}
