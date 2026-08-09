import 'package:flutter/material.dart';

import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/pizza_model.dart';
import '../../detail/pizza_detail_route.dart';

/// The pizza image sits in an [Expanded] rather than a fixed height. Grid
/// cell height is set by `GridView`'s `childAspectRatio`, which varies with
/// screen width — a fixed-height image plus a fixed-height text block below
/// it can add up to more than the cell actually has, which is exactly what
/// was overflowing here. Flexing the image means it always yields whatever
/// space the text block doesn't need, so the column can never overflow.
class PizzaCard extends StatefulWidget {
  const PizzaCard({super.key, required this.pizza});

  final PizzaModel pizza;

  @override
  State<PizzaCard> createState() => _PizzaCardState();
}

class _PizzaCardState extends State<PizzaCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final pizza = widget.pizza;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: AppDurations.chipSelect,
        curve: AppCurves.chipSelect,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            onTap: () => Navigator.of(context).push(buildPizzaDetailRoute(pizza)),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: Hero(
                        tag: 'pizza-image-${pizza.id}',
                        child: Image.asset(pizza.imagePath, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    pizza.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pizza.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'From ${formatPrice(pizza.basePrice)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
