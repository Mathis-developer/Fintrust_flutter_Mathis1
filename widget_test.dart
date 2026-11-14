import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintrust_digital_bank/main.dart';

void main() {
  testWidgets('Login opens dashboard', (tester) async {
    await tester.pumpWidget(const FinTrustApp());
    expect(find.text('Welcome Back'), findsOneWidget);
    await tester.tap(find.text('Login — Demo'));
    await tester.pumpAndSettle();
    expect(find.text('LKR 528,750.00'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
  });

  testWidgets('Dashboard opens transfer', (tester) async {
    await tester.pumpWidget(const FinTrustApp());
    await tester.tap(find.text('Login — Demo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Review Transfer'), findsOneWidget);
    expect(find.text('To Beneficiary'), findsWidgets);
  });

  testWidgets('User can open bill payment', (tester) async {
    await tester.pumpWidget(const FinTrustApp());
    await tester.tap(find.text('Login — Demo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pay Bills'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a service'), findsOneWidget);
    expect(find.text('Recent Bills'), findsOneWidget);
  });
}
