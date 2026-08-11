import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_motion.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/pizza_category.dart';
import '../../domain/models/pizza_model.dart';
import '../../domain/models/pizza_size.dart';
import '../providers/cart_providers.dart';
import 'widgets/add_to_cart_button.dart';
import 'widgets/animated_price.dart';
import 'widgets/pizza_3d_viewer.dart';
import 'widgets/size_selector.dart';

class PizzaDetailScreen extends ConsumerStatefulWidget {
  const PizzaDetailScreen({super.key, required this.pizza});

  final PizzaModel pizza;

  @override
  ConsumerState<PizzaDetailScreen> createState() => _PizzaDetailScreenState();
}

class _PizzaDetailScreenState extends ConsumerState<PizzaDetailScreen>
    with SingleTickerProviderStateMixin {
  late PizzaSize _selectedSize = widget.pizza.sizes[1];
  late final AnimationController _panelController = AnimationController(
    vsync: this,
    duration: AppDurations.detailPanelReveal,
  );
  late final Animation<double> _panelAnimation = CurvedAnimation(
    parent: _panelController,
    curve: AppCurves.panelReveal,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(AppDurations.heroFlight, () {
      if (mounted) _panelController.forward();
    });
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pizza = widget.pizza;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: AppSpacing.detailHeroSize,
              child: Stack(
                children: [
                  Center(
                    child: Pizza3DViewer(
                      pizza: pizza,
                      sizeScale: _selectedSize.visualScale,
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    top: AppSpacing.sm,
                    child: _CircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _panelAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _panelAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - _panelAnimation.value) * 40),
                      child: child,
                    ),
                  );
                },
                child: _DetailPanel(
                  pizza: pizza,
                  selectedSize: _selectedSize,
                  onSizeChanged: (size) => setState(() => _selectedSize = size),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPanel extends ConsumerWidget {
  const _DetailPanel({
    required this.pizza,
    required this.selectedSize,
    required this.onSizeChanged,
  });

  final PizzaModel pizza;
  final PizzaSize selectedSize;
  final ValueChanged<PizzaSize> onSizeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.sheetRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pizza.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      _CategoryBadge(category: pizza.category),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    pizza.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Size', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SizeSelector(
                    sizes: pizza.sizes,
                    selected: selectedSize,
                    onChanged: onSizeChanged,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final ingredient in pizza.ingredients)
                        _IngredientPill(label: ingredient),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          Row(
            children: [
              AnimatedPrice(price: pizza.priceForSize(selectedSize)),
              const Spacer(),
              Expanded(
                flex: 2,
                child: AddToCartButton(
                  onConfirmed: () => ref
                      .read(cartProvider.notifier)
                      .addItem(pizza, selectedSize),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Icon(icon, size: 18, color: AppColors.background),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final PizzaCategory category;

  @override
  Widget build(BuildContext context) {
    final color = category == PizzaCategory.veg
        ? AppColors.accent
        : AppColors.primary;
    return Container(
      height: 30,
      width: 30,
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 4),
        borderRadius: BorderRadius.circular(5),
      ),
      child: CircleAvatar(backgroundColor: color),
    );
  }
}

class _IngredientPill extends StatelessWidget {
  const _IngredientPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(50),
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
