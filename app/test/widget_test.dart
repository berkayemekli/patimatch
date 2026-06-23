import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Material uygulama smoke testi', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('PatiParent'))),
    );
    expect(find.text('PatiParent'), findsOneWidget);
  });
}
