import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/cart_item.dart';
import '../../domain/models/pizza_model.dart';
import '../../domain/models/pizza_size.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(PizzaModel pizza, PizzaSize size) {
    final existingIndex = state.indexWhere(
      (item) => item.pizza.id == pizza.id && item.size.label == size.label,
    );

    if (existingIndex != -1) {
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == existingIndex)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
      return;
    }

    final newItem = CartItem(
      id: '${pizza.id}_${size.label.name}_${DateTime.now().microsecondsSinceEpoch}',
      pizza: pizza,
      size: size,
      quantity: 1,
    );
    state = [...state, newItem];
  }

  void removeItem(String cartItemId) {
    state = state.where((item) => item.id != cartItemId).toList();
  }

  void updateQuantity(String cartItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(cartItemId);
      return;
    }
    state = [
      for (final item in state)
        if (item.id == cartItemId) item.copyWith(quantity: quantity) else item,
    ];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.lineTotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});
