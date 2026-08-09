import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pizzaro/app.dart';

void main() {
  testWidgets('Home screen shows the menu heading and pizza cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PizzaroApp()));
    await tester.pumpAndSettle();

    expect(find.text('Find your next favorite pizza'), findsOneWidget);
    expect(find.text('Margherita Classic'), findsOneWidget);
  });
}
