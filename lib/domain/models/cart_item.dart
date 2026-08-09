import 'pizza_model.dart';
import 'pizza_size.dart';

class CartItem {
  const CartItem({
    required this.id,
    required this.pizza,
    required this.size,
    required this.quantity,
  });

  final String id;
  final PizzaModel pizza;
  final PizzaSize size;
  final int quantity;

  double get lineTotal => pizza.priceForSize(size) * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      pizza: pizza,
      size: size,
      quantity: quantity ?? this.quantity,
    );
  }
}
