import 'package:flutter/material.dart';

import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

enum _CtaPhase { idle, loading, success }

/// Morphs idle -> loading spinner -> checkmark -> idle using
/// `AnimatedContainer` (width/color) and `AnimatedSwitcher` (icon/label
/// swap), per the project's "native APIs only" constraint rather than an
/// animated-button package. A press-scale on tap-down and an `easeOutBack`
/// pop on every icon/label swap give it a tactile, spring-like feel instead
/// of a flat linear crossfade.
class AddToCartButton extends StatefulWidget {
  const AddToCartButton({super.key, required this.onConfirmed});

  /// Called once the loading phase completes, so the caller can perform the
  /// real "add to cart" side effect exactly once per tap.
  final VoidCallback onConfirmed;

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  _CtaPhase _phase = _CtaPhase.idle;
  bool _pressed = false;

  Future<void> _handleTap() async {
    if (_phase != _CtaPhase.idle) return;

    setState(() => _phase = _CtaPhase.loading);
    await Future<void>.delayed(AppDurations.ctaLoadingHold);
    if (!mounted) return;

    widget.onConfirmed();
    setState(() => _phase = _CtaPhase.success);
    await Future<void>.delayed(AppDurations.ctaSuccessHold);
    if (!mounted) return;

    setState(() => _phase = _CtaPhase.idle);
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _phase != _CtaPhase.idle;

    // `AnimatedContainer` can't animate `width` between a finite value and
    // `double.infinity` — lerping toward/from infinity produces a NaN/
    // infinite intermediate frame, which threw a real (if brief) layout
    // exception on every tap. `LayoutBuilder` resolves "full width" to the
    // actual finite pixel value handed down by the parent `Expanded` first,
    // so the tween only ever runs between two concrete numbers.
    return LayoutBuilder(
      builder: (context, constraints) {
        final expandedWidth = constraints.maxWidth;
        return GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _handleTap,
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1,
            duration: AppDurations.chipSelect,
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: AppDurations.ctaMorph,
              curve: AppCurves.ctaMorph,
              height: 54,
              width: isBusy ? 54 : expandedWidth,
              decoration: BoxDecoration(
                color: _phase == _CtaPhase.success ? AppColors.success : AppColors.primary,
                borderRadius: BorderRadius.circular(_phase == _CtaPhase.idle ? AppSpacing.buttonRadius : 27),
                boxShadow: [
                  BoxShadow(
                    color: (_phase == _CtaPhase.success ? AppColors.success : AppColors.primary)
                        .withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: AppDurations.ctaMorph,
                // `switchInCurve`/`switchOutCurve` would feed the same curved
                // animation into both Scale and Fade below. `easeOutBack`
                // overshoots past 1.0 for the bounce, which is fine for scale
                // but would violate FadeTransition's opacity assertion — so
                // the bounce curve is applied only to scale here, and fade
                // stays on the switcher's plain linear animation.
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: switch (_phase) {
                  _CtaPhase.idle => const Text(
                      'Add to Cart',
                      key: ValueKey('idle'),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  _CtaPhase.loading => const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    ),
                  _CtaPhase.success =>
                    const Icon(Icons.check_rounded, key: ValueKey('success'), color: Colors.white),
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
