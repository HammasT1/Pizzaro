import 'package:flutter/material.dart';

import '../../core/constants/app_motion.dart';
import '../../domain/models/pizza_model.dart';
import 'pizza_detail_screen.dart';

/// A custom, explicit-duration route so the Hero flight timing
/// ([AppDurations.heroFlight]) is deterministic and the detail screen can
/// schedule its panel reveal to start exactly when the flight ends, instead
/// of guessing the platform's default page-transition duration.
Route<void> buildPizzaDetailRoute(PizzaModel pizza) {
  return PageRouteBuilder<void>(
    transitionDuration: AppDurations.heroFlight,
    reverseTransitionDuration: AppDurations.heroFlight,
    pageBuilder: (context, animation, secondaryAnimation) {
      return PizzaDetailScreen(pizza: pizza);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Hero flies via its own overlay entry independent of this transition,
      // so scaling the destination page here doesn't distort the flight —
      // it only adds weight to the page material settling in behind it.
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
