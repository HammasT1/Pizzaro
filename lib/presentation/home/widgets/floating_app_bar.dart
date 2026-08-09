import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

/// A rounded, frosted-glass app bar that floats above the scrolling grid
/// instead of docking flush to the top edge. It does two things a plain
/// `AppBar` doesn't:
///
/// 1. Plays a one-off slide-down + fade entrance on first build.
/// 2. Reacts continuously to [scrollProgress] (0 = top of the list, 1 = a
///    few pixels scrolled) by deepening its blur, background opacity and
///    shadow — a cheap way to read as "floating over" the content beneath
///    it rather than "sitting on top of" it.
///
/// [scrollProgress] is a plain `ValueListenable` (not a `Provider`) so this
/// widget only rebuilds itself on scroll ticks, not the rest of the screen.
class FloatingHomeAppBar extends StatefulWidget {
  const FloatingHomeAppBar({
    super.key,
    required this.cartCount,
    required this.onCartTap,
    required this.scrollProgress,
  });

  final int cartCount;
  final VoidCallback onCartTap;
  final ValueListenable<double> scrollProgress;

  static const double height = 58;
  static const double topMargin = AppSpacing.sm;
  static const double reservedSpace = height + topMargin + AppSpacing.md;

  @override
  State<FloatingHomeAppBar> createState() => _FloatingHomeAppBarState();
}

class _FloatingHomeAppBarState extends State<FloatingHomeAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entrance = CurvedAnimation(
    parent: _entranceController,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: AppDurations.cardEntrance,
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topInset + FloatingHomeAppBar.topMargin,
      left: AppSpacing.md,
      right: AppSpacing.md,
      height: FloatingHomeAppBar.height,
      child: AnimatedBuilder(
        animation: _entrance,
        builder: (context, child) {
          return Opacity(
            opacity: _entrance.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (1 - _entrance.value) * -24),
              child: child,
            ),
          );
        },
        child: ValueListenableBuilder<double>(
          valueListenable: widget.scrollProgress,
          builder: (context, progress, child) {
            final blurSigma = lerpDouble(4, 18, progress)!;
            final backgroundAlpha = lerpDouble(0.78, 0.94, progress)!;
            final shadowAlpha = lerpDouble(0.05, 0.16, progress)!;

            return ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.sheetRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: backgroundAlpha),
                    borderRadius: BorderRadius.circular(AppSpacing.sheetRadius),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: shadowAlpha),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: _FloatingBarContent(cartCount: widget.cartCount, onCartTap: widget.onCartTap),
        ),
      ),
    );
  }
}

class _FloatingBarContent extends StatelessWidget {
  const _FloatingBarContent({required this.cartCount, required this.onCartTap});

  final int cartCount;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.local_pizza_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('Pizzaro', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          _CartAction(count: cartCount, onTap: onCartTap),
        ],
      ),
    );
  }
}

class _CartAction extends StatelessWidget {
  const _CartAction({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(color: AppColors.chipBackground, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary, size: 20),
          ),
          if (count > 0)
            Positioned(
              right: -4,
              top: -4,
              child: AnimatedSwitcher(
                duration: AppDurations.chipSelect,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Container(
                  key: ValueKey<int>(count),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
