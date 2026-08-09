import 'pizza_category.dart';
import 'pizza_size.dart';

class PizzaModel {
  const PizzaModel({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.imagePath,
    required this.category,
    required this.ingredients,
    this.sizes = PizzaSize.standardSizes,
    this.hasTransparentBackground = true,
  });

  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String imagePath;
  final PizzaCategory category;
  final List<String> ingredients;
  final List<PizzaSize> sizes;

  /// All current pizza images are transparent PNGs, but a non-transparent
  /// asset (e.g. a flat JPEG) can set this to `false` — the detail screen
  /// then swaps in a soft backing disc behind the image instead of relying
  /// on transparency.
  final bool hasTransparentBackground;

  double priceForSize(PizzaSize size) => basePrice + size.priceDelta;
}
