enum PizzaSizeLabel { small, medium, large }

/// A purchasable size variant of a pizza.
///
/// [visualScale] drives the elastic scale animation on the 3D pizza image —
/// it is intentionally a tighter range (0.85–1.15) than a real menu's inch
/// spread so the size change reads as a physical "grow/shrink" rather than
/// the image clipping out of frame.
class PizzaSize {
  const PizzaSize({
    required this.label,
    required this.displayName,
    required this.inches,
    required this.priceDelta,
    required this.visualScale,
  });

  final PizzaSizeLabel label;
  final String displayName;
  final double inches;
  final double priceDelta;
  final double visualScale;

  static const List<PizzaSize> standardSizes = [
    PizzaSize(
      label: PizzaSizeLabel.small,
      displayName: 'Small',
      inches: 9,
      priceDelta: 0,
      visualScale: 0.85,
    ),
    PizzaSize(
      label: PizzaSizeLabel.medium,
      displayName: 'Medium',
      inches: 12,
      priceDelta: 3.5,
      visualScale: 1.0,
    ),
    PizzaSize(
      label: PizzaSizeLabel.large,
      displayName: 'Large',
      inches: 16,
      priceDelta: 7,
      visualScale: 1.15,
    ),
  ];
}
