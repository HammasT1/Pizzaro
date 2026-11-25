import 'package:flutter/material.dart';

import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/pizza_size.dart';

class SizeSelector extends StatelessWidget {
  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selected,
    required this.onChanged,
  });

  final List<PizzaSize> sizes;
  final PizzaSize selected;
  final ValueChanged<PizzaSize> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final size in sizes) ...[
          Expanded(
            child: _SizeOption(
              size: size,
              selected: size.label == selected.label,
              onTap: () => onChanged(size),
            ),
          ),
          if (size != sizes.last) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final PizzaSize size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1,
        duration: AppDurations.chipSelect,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: AppDurations.chipSelect,
          curve: AppCurves.chipSelect,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            children: [
              AnimatedDefaultTextStyle(
                duration: AppDurations.chipSelect,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
                child: Text(size.displayName),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: AppDurations.chipSelect,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white70 : AppColors.textSecondary,
                ),
                child: Text('${size.inches.toStringAsFixed(0)}"'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
