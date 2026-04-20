import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tubes_apb_fe/main.dart';

void main() {
  testWidgets('ButterflyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ButterflyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
