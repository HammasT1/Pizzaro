import '../../domain/models/pizza_model.dart';
import '../datasources/pizza_mock_data.dart';

abstract class PizzaRepository {
  Future<List<PizzaModel>> getAllPizzas();
}

/// Reads from the local mock list today. Swap this implementation for one
/// backed by `http`/`dio` later without touching any presentation code,
/// since callers only depend on the [PizzaRepository] interface.
class MockPizzaRepository implements PizzaRepository {
  @override
  Future<List<PizzaModel>> getAllPizzas() async {
    return kMockPizzas;
  }
}
