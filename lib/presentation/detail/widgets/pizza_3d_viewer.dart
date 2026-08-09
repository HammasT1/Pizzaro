import 'package:flutter/material.dart';

import '../../../core/constants/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/pizza_model.dart';

/// Fakes a 3D pizza using only a 2D image: a perspective [Matrix4] rotates
/// it in response to drag, a slow idle "breathing" loop keeps it from ever
/// looking static, a spring-back animation returns it to rest after a drag,
/// and a ground shadow scales/dims to sell depth. Sizes (small/medium/large)
/// animate through the same [Matrix4] scale with an elastic curve.
///
/// Three independent animations are merged into a single [AnimatedBuilder]
/// scoped to just this widget's subtree so a drag or a breathing tick never
/// rebuilds the rest of the detail screen.
class Pizza3DViewer extends StatefulWidget {
  const Pizza3DViewer({super.key, required this.pizza, required this.sizeScale});

  final PizzaModel pizza;
  final double sizeScale;

  @override
  State<Pizza3DViewer> createState() => _Pizza3DViewerState();
}

class _Pizza3DViewerState extends State<Pizza3DViewer>
    with TickerProviderStateMixin {
  static const double _maxRotationY = 0.55;
  static const double _maxRotationX = 0.32;
  static const double _dragRangeX = 130;
  static const double _dragRangeY = 90;

  late final AnimationController _breathingController;
  late final AnimationController _springController;
  late final AnimationController _sizeController;

  final ValueNotifier<Offset> _dragOffset = ValueNotifier(Offset.zero);
  Animation<Offset>? _springAnimation;
  late Animation<double> _sizeAnimation;
  double _settledSizeScale = 1;

  @override
  void initState() {
    super.initState();
    _settledSizeScale = widget.sizeScale;

    _breathingController = AnimationController(
      vsync: this,
      duration: AppDurations.breathingCycle,
    )..repeat(reverse: true);

    _springController = AnimationController(
      vsync: this,
      duration: AppDurations.dragSpringBack,
    )..addListener(() {
        final animation = _springAnimation;
        if (animation != null) _dragOffset.value = animation.value;
      });

    _sizeController = AnimationController(
      vsync: this,
      duration: AppDurations.sizeChange,
    );
    _sizeAnimation = AlwaysStoppedAnimation(widget.sizeScale);
  }

  @override
  void didUpdateWidget(covariant Pizza3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sizeScale != widget.sizeScale) {
      _sizeAnimation = Tween<double>(
        begin: _settledSizeScale,
        end: widget.sizeScale,
      ).animate(CurvedAnimation(parent: _sizeController, curve: AppCurves.sizeChange));
      _sizeController.forward(from: 0).whenComplete(() {
        _settledSizeScale = widget.sizeScale;
      });
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _springController.dispose();
    _sizeController.dispose();
    _dragOffset.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_springController.isAnimating) _springController.stop();
    final next = _dragOffset.value + Offset(details.delta.dx, details.delta.dy);
    _dragOffset.value = Offset(
      next.dx.clamp(-_dragRangeX, _dragRangeX),
      next.dy.clamp(-_dragRangeY, _dragRangeY),
    );
  }

  void _onPanEnd(DragEndDetails details) {
    _springAnimation = Tween<Offset>(
      begin: _dragOffset.value,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _springController, curve: AppCurves.dragSpringBack));
    _springController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: () => _onPanEnd(DragEndDetails()),
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathingController, _dragOffset, _sizeController]),
        builder: (context, child) {
          final breathe = Curves.easeInOutSine.transform(_breathingController.value);
          final breatheScale = 1 + breathe * 0.03;
          final breatheRotateZ = (breathe - 0.5) * 0.018;

          final rotateY = (_dragOffset.value.dx / _dragRangeX) * _maxRotationY;
          final rotateX = -(_dragOffset.value.dy / _dragRangeY) * _maxRotationX;
          final sizeScale = _sizeAnimation.value;

          final tiltMagnitude =
              (rotateX.abs() / _maxRotationX + rotateY.abs() / _maxRotationY) / 2;

          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0014)
            ..rotateX(rotateX)
            ..rotateY(rotateY)
            ..rotateZ(breatheRotateZ)
            ..scaleByDouble(
              breatheScale * sizeScale,
              breatheScale * sizeScale,
              breatheScale * sizeScale,
              1,
            );

          return Stack(
            alignment: Alignment.center,
            children: [
              _GroundShadow(
                sizeScale: sizeScale,
                breathe: breathe,
                tiltMagnitude: tiltMagnitude,
                tiltOffsetX: rotateY,
              ),
              Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!widget.pizza.hasTransparentBackground) const _BackingDisc(),
                    child!,
                    _SpecularHighlight(rotateX: rotateX, rotateY: rotateY),
                  ],
                ),
              ),
            ],
          );
        },
        child: Hero(
          tag: 'pizza-image-${widget.pizza.id}',
          child: Image.asset(
            widget.pizza.imagePath,
            fit: BoxFit.contain,
            width: 240,
            height: 240,
          ),
        ),
      ),
    );
  }
}

class _GroundShadow extends StatelessWidget {
  const _GroundShadow({
    required this.sizeScale,
    required this.breathe,
    required this.tiltMagnitude,
    required this.tiltOffsetX,
  });

  final double sizeScale;
  final double breathe;
  final double tiltMagnitude;
  final double tiltOffsetX;

  @override
  Widget build(BuildContext context) {
    final width = 190.0 * sizeScale;
    final height = 30.0 * sizeScale;
    final opacity = (0.30 - breathe * 0.08 - tiltMagnitude * 0.10).clamp(0.05, 0.30);

    return Padding(
      padding: const EdgeInsets.only(top: 170),
      child: Transform.translate(
        offset: Offset(tiltOffsetX * 14, 0),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.elliptical(width / 2, height / 2)),
            color: AppColors.shadow.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}

/// Rendered behind pizzas whose image has no alpha channel, so a soft disc
/// keeps its square edges from reading as a visual glitch next to the
/// other, transparent pizza images.
class _BackingDisc extends StatelessWidget {
  const _BackingDisc();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [AppColors.surface, AppColors.surface.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _SpecularHighlight extends StatelessWidget {
  const _SpecularHighlight({required this.rotateX, required this.rotateY});

  final double rotateX;
  final double rotateY;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment(
          (rotateY / 0.55).clamp(-1.0, 1.0) * -0.6,
          (rotateX / 0.32).clamp(-1.0, 1.0) * 0.6 - 0.3,
        ),
        child: Opacity(
          opacity: 0.12,
          child: Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Colors.white, Colors.transparent]),
            ),
          ),
        ),
      ),
    );
  }
}

