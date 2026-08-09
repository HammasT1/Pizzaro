import 'package:flutter/material.dart';

import '../../../core/constants/app_motion.dart';

/// Fades + slides + scales [child] in based on where [index] falls in a
/// shared [controller] timeline, rather than giving every grid item its own
/// AnimationController. Each item's Interval overlaps the next so the whole
/// grid still finishes inside one [controller] run, and only the
/// [AnimatedBuilder] subtree here rebuilds per tick — the parent grid does
/// not.
///
/// [AppCurves.cardEntrance] (`easeOutBack`) overshoots past 1.0 before
/// settling, which is what gives the pop-in its slight bounce. Opacity is
/// clamped to a valid 0-1 range since `Opacity` asserts on that, but the
/// scale/translate values are left to overshoot on purpose.
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    super.key,
    required this.controller,
    required this.index,
    required this.itemCount,
    required this.child,
  });

  final AnimationController controller;
  final int index;
  final int itemCount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final safeCount = itemCount.clamp(1, itemCount == 0 ? 1 : itemCount);
    final start = (index / safeCount) * 0.6;
    final end = (start + 0.4).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start.clamp(0.0, 1.0), end, curve: AppCurves.cardEntrance),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, builtChild) {
        final t = animation.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 28),
            child: Transform.scale(
              scale: 0.88 + 0.12 * t,
              child: builtChild,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
