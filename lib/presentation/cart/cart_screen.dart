import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_motion.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/cart_item.dart';
import '../detail/widgets/animated_price.dart';
import '../providers/cart_providers.dart';
import 'widgets/cart_item_tile.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

/// [_items] is a local snapshot used only to drive `AnimatedList`'s
/// insert/remove indices and to render a removed row during its exit
/// transition (after which the provider no longer has that data). While an
/// item is still present, its tile re-reads live quantity/total straight
/// from [cartProvider] via a `Consumer`, so quantity edits don't need to
/// touch the snapshot or the list's insert/remove machinery at all.
class _CartScreenState extends ConsumerState<CartScreen> {
  final _listKey = GlobalKey<AnimatedListState>();
  late final List<CartItem> _items = List.of(ref.read(cartProvider));

  void _handleCartChanged(List<CartItem>? previous, List<CartItem> next) {
    for (var i = _items.length - 1; i >= 0; i--) {
      final stillPresent = next.any((item) => item.id == _items[i].id);
      if (!stillPresent) {
        final removed = _items.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildTile(removed, animation),
          duration: AppDurations.cartRowAnimation,
        );
      }
    }

    for (var i = 0; i < next.length; i++) {
      final alreadyTracked = _items.any((item) => item.id == next[i].id);
      if (!alreadyTracked) {
        _items.insert(i, next[i]);
        _listKey.currentState?.insertItem(
          i,
          duration: AppDurations.cartRowAnimation,
        );
      }
    }
  }

  Widget _buildTile(CartItem snapshot, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ),
      axisAlignment: 0.0,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: FadeTransition(
          opacity: animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Consumer(
              builder: (context, ref, _) {
                final current = ref
                    .watch(cartProvider)
                    .firstWhere(
                      (item) => item.id == snapshot.id,
                      orElse: () => snapshot,
                    );
                return CartItemTile(
                  item: current,
                  onRemove: () =>
                      ref.read(cartProvider.notifier).removeItem(current.id),
                  onQuantityChanged: (quantity) => ref
                      .read(cartProvider.notifier)
                      .updateQuantity(current.id, quantity),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<CartItem>>(cartProvider, _handleCartChanged);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const _EmptyCart()
                : AnimatedList(
                    key: _listKey,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    initialItemCount: _items.length,
                    itemBuilder: (context, index, animation) =>
                        _buildTile(_items[index], animation),
                  ),
          ),
          _TotalBar(total: total),
        ],
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  const _TotalBar({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: Theme.of(context).textTheme.titleMedium),
            AnimatedPrice(price: total),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
