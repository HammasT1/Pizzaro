import 'package:flutter/animation.dart';

/// Every animation in the app pulls its duration from here so timing stays
/// consistent and sequenced animations (e.g. hero flight -> panel reveal)
/// can reference each other's durations instead of guessing matching numbers.
class AppDurations {
  AppDurations._();

  static const Duration cardEntranceStagger = Duration(milliseconds: 70);
  static const Duration cardEntrance = Duration(milliseconds: 550);
  static const Duration heroFlight = Duration(milliseconds: 500);
  static const Duration detailPanelReveal = Duration(milliseconds: 450);
  static const Duration sizeChange = Duration(milliseconds: 600);
  static const Duration priceCountUp = Duration(milliseconds: 400);
  static const Duration breathingCycle = Duration(milliseconds: 3200);
  static const Duration dragSpringBack = Duration(milliseconds: 650);
  static const Duration ctaMorph = Duration(milliseconds: 260);
  static const Duration ctaLoadingHold = Duration(milliseconds: 700);
  static const Duration ctaSuccessHold = Duration(milliseconds: 900);
  static const Duration cartRowAnimation = Duration(milliseconds: 350);
  static const Duration chipSelect = Duration(milliseconds: 220);
}

class AppCurves {
  AppCurves._();

  static const Curve cardEntrance = Curves.easeOutBack;
  static const Curve panelReveal = Curves.easeOutQuart;
  static const Curve sizeChange = Curves.elasticOut;
  static const Curve priceCountUp = Curves.easeOutCubic;
  static const Curve dragSpringBack = Curves.easeOutBack;
  static const Curve breathing = Curves.easeInOutSine;
  static const Curve ctaMorph = Curves.easeOutCubic;
  static const Curve chipSelect = Curves.easeOutCubic;
}
