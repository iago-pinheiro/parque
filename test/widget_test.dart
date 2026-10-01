import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bank/main.dart';

void main() {
  testWidgets('creates and lists a ticket', (WidgetTester tester) async {
    await tester.pumpWidget(const AppParque());

    expect(find.text('Ingressos do parque'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '1003');
    await tester.enterText(find.byType(TextField).at(1), '12.50');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Bilhete nº 1003'), findsOneWidget);
  });
}
