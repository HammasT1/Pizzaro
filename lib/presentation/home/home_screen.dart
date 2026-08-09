import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_motion.dart';
import '../../core/constants/app_spacing.dart';
import '../../domain/models/pizza_category.dart';
import '../cart/cart_screen.dart';
import '../providers/cart_providers.dart';
import '../providers/pizza_providers.dart';
import 'widgets/category_chip.dart';
import 'widgets/floating_app_bar.dart';
import 'widgets/pizza_card.dart';
import 'widgets/staggered_entrance.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  final ScrollController _scrollController = ScrollController();

  /// Drives [FloatingHomeAppBar]'s blur/shadow. A `ValueNotifier` (rather
  /// than `setState`) means each scroll tick only rebuilds the small
  /// `ValueListenableBuilder` inside the floating bar, not the grid beneath
  /// it or this whole screen.
  final ValueNotifier<double> _scrollProgress = ValueNotifier(0);

  static const double _scrollFadeDistance = 24;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: AppDurations.cardEntrance,
    )..forward();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final progress = (_scrollController.offset / _scrollFadeDistance).clamp(0.0, 1.0);
    _scrollProgress.value = progress;
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _scrollProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pizzasAsync = ref.watch(filteredPizzaListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: FloatingHomeAppBar.reservedSpace),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'Find your next favorite pizza',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    children: [
                      CategoryChip(
                        label: 'All',
                        selected: selectedCategory == null,
                        onTap: () =>
                            ref.read(selectedCategoryProvider.notifier).select(null),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      for (final category in PizzaCategory.values) ...[
                        CategoryChip(
                          label: category.label,
                          selected: selectedCategory == category,
                          onTap: () => ref
                              .read(selectedCategoryProvider.notifier)
                              .select(category),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: pizzasAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) =>
                        Center(child: Text('Could not load menu: $error')),
                    data: (pizzas) {
                      if (pizzas.isEmpty) {
                        return const Center(child: Text('No pizzas in this category yet.'));
                      }
                      return GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.xl,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: pizzas.length,
                        itemBuilder: (context, index) {
                          return StaggeredEntrance(
                            controller: _entranceController,
                            index: index,
                            itemCount: pizzas.length,
                            child: PizzaCard(pizza: pizzas[index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          FloatingHomeAppBar(
            cartCount: cartCount,
            scrollProgress: _scrollProgress,
            onCartTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
