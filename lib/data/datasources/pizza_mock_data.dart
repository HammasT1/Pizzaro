import '../../domain/models/pizza_category.dart';
import '../../domain/models/pizza_model.dart';

/// Local stand-in for a real menu API. Only 8 pizza images exist in
/// assets/images/pizzas (1.png-8.png) with no accompanying metadata, so
/// names/descriptions/categories/prices below are placeholder menu copy —
/// swap for real content whenever it's available.
final List<PizzaModel> kMockPizzas = [
  const PizzaModel(
    id: 'pizza-1',
    name: 'Margherita Classic',
    description:
        'San Marzano tomato sauce, fresh mozzarella, and basil on a '
        'thin, hand-stretched crust.',
    basePrice: 9.99,
    imagePath: 'assets/images/pizzas/1.png',
    category: PizzaCategory.veg,
    ingredients: ['Mozzarella', 'Tomato Sauce', 'Basil', 'Olive Oil'],
  ),
  const PizzaModel(
    id: 'pizza-2',
    name: 'Pepperoni Supreme',
    description:
        'Loaded with crisped pepperoni and a blend of melted mozzarella '
        'over a rich tomato base.',
    basePrice: 11.49,
    imagePath: 'assets/images/pizzas/2.png',
    category: PizzaCategory.nonVeg,
    ingredients: ['Pepperoni', 'Mozzarella', 'Tomato Sauce', 'Oregano'],
  ),
  const PizzaModel(
    id: 'pizza-3',
    name: 'Garden Veggie',
    description:
        'Bell peppers, red onion, mushrooms, and black olives over a '
        'garlic-herb base.',
    basePrice: 10.49,
    imagePath: 'assets/images/pizzas/3.png',
    category: PizzaCategory.veg,
    ingredients: ['Bell Pepper', 'Onion', 'Mushroom', 'Olives', 'Mozzarella'],
  ),
  const PizzaModel(
    id: 'pizza-4',
    name: 'BBQ Chicken Ranch',
    description:
        'Grilled chicken, smoky BBQ sauce, red onion, and a ranch drizzle.',
    basePrice: 12.99,
    imagePath: 'assets/images/pizzas/4.png',
    category: PizzaCategory.nonVeg,
    ingredients: ['Chicken', 'BBQ Sauce', 'Red Onion', 'Mozzarella'],
  ),
  const PizzaModel(
    id: 'pizza-5',
    name: 'Four Cheese',
    description:
        'Mozzarella, gorgonzola, parmesan, and provolone on a golden '
        'buttery crust.',
    basePrice: 11.99,
    imagePath: 'assets/images/pizzas/5.png',
    category: PizzaCategory.specialty,
    ingredients: ['Mozzarella', 'Gorgonzola', 'Parmesan', 'Provolone'],
  ),
  const PizzaModel(
    id: 'pizza-6',
    name: 'Truffle Mushroom',
    description:
        'Wild mushrooms, truffle oil, and shaved parmesan over a white '
        'garlic cream base.',
    basePrice: 13.99,
    imagePath: 'assets/images/pizzas/6.png',
    category: PizzaCategory.specialty,
    ingredients: ['Mushroom', 'Truffle Oil', 'Parmesan', 'Garlic Cream'],
  ),
  const PizzaModel(
    id: 'pizza-7',
    name: 'Spicy Diavola',
    description:
        'Spicy salami, chili flakes, and mozzarella over a fiery arrabbiata '
        'sauce.',
    basePrice: 12.49,
    imagePath: 'assets/images/pizzas/7.png',
    category: PizzaCategory.nonVeg,
    ingredients: ['Spicy Salami', 'Chili Flakes', 'Mozzarella', 'Arrabbiata'],
  ),
  const PizzaModel(
    id: 'pizza-8',
    name: 'Roasted Veggie Deluxe',
    description:
        'Zucchini, roasted peppers, cherry tomatoes, and feta finished '
        'with a balsamic glaze.',
    basePrice: 12.99,
    imagePath: 'assets/images/pizzas/8.png',
    category: PizzaCategory.specialty,
    ingredients: ['Zucchini', 'Roasted Pepper', 'Cherry Tomato', 'Feta'],
  ),
];
