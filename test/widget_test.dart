import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saamago/app/app.dart';
import 'package:saamago/core/widgets/saamago_wordmark.dart';

void main() {
  testWidgets('SAAMAgo splash renders branded launch experience', (
    tester,
  ) async {
    await tester.pumpWidget(const SaamaGoApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Borrow. Save. Repeat.'), findsOneWidget);
    expect(find.byType(SaamaGoWordmark), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Borrow anything nearby.'), findsOneWidget);
  });
}
