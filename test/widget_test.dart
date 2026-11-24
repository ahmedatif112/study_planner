import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner/main.dart';

void main() {
  // Checks that the reusable SummaryCard shows its title and value
  testWidgets('SummaryCard shows its title and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SummaryCard(
            title: 'Total hours',
            value: '10',
            icon: Icons.schedule,
            color: Colors.indigo,
          ),
        ),
      ),
    );

    expect(find.text('Total hours'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
  });
}
