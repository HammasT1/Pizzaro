import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/pizza_repository.dart';
import '../../domain/models/pizza_category.dart';
import '../../domain/models/pizza_model.dart';

final pizzaRepositoryProvider = Provider<PizzaRepository>((ref) {
  return MockPizzaRepository();
});

final pizzaListProvider = FutureProvider<List<PizzaModel>>((ref) {
  return ref.watch(pizzaRepositoryProvider).getAllPizzas();
});

/// `null` represents the "All" filter chip.
class SelectedCategoryNotifier extends Notifier<PizzaCategory?> {
  @override
  PizzaCategory? build() => null;

  void select(PizzaCategory? category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, PizzaCategory?>(
  SelectedCategoryNotifier.new,
);

final filteredPizzaListProvider = Provider<AsyncValue<List<PizzaModel>>>((
  ref,
) {
  final pizzas = ref.watch(pizzaListProvider);
  final category = ref.watch(selectedCategoryProvider);
  return pizzas.whenData((list) {
    if (category == null) return list;
    return list.where((pizza) => pizza.category == category).toList();
  });
});
