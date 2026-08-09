import 'package:flutter/material.dart';

import '../../../core/constants/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Counts from the previous [price] to the new one whenever it changes.
///
/// Uses an explicit [AnimationController] instead of a bare
/// `TweenAnimationBuilder(begin: price, end: price)` — with the same value
/// on both ends, that pattern has no guaranteed visible motion. Here,
/// [didUpdateWidget] captures the outgoing price as `begin` for a fresh
/// `Tween` and drives the controller from 0 explicitly, so the start and end
/// of the count-up are always the two real values.
class AnimatedPrice extends StatefulWidget {
  const AnimatedPrice({super.key, required this.price, this.style});

  final double price;
  final TextStyle? style;

  @override
  State<AnimatedPrice> createState() => _AnimatedPriceState();
}

class _AnimatedPriceState extends State<AnimatedPrice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _priceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.priceCountUp);
    _priceAnimation = AlwaysStoppedAnimation(widget.price);
  }

  @override
  void didUpdateWidget(covariant AnimatedPrice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price != widget.price) {
      _priceAnimation = Tween<double>(begin: oldWidget.price, end: widget.price)
          .animate(CurvedAnimation(parent: _controller, curve: AppCurves.priceCountUp));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ??
        const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        );

    return AnimatedBuilder(
      animation: _priceAnimation,
      builder: (context, child) {
        return Text(formatPrice(_priceAnimation.value), style: effectiveStyle);
      },
    );
  }
}
