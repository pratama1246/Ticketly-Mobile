import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketly/main.dart';

void main() {
  testWidgets('TicketlyApp smoke test renders MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const TicketlyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    // Advance time past the splash screen timer to drain all pending timers
    await tester.pump(const Duration(milliseconds: 3000));
  });
}
