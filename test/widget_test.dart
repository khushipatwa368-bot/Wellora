import 'package:flutter_test/flutter_test.dart';
import 'package:wellora/main.dart';

void main() {
  testWidgets('Wellora app launch test', (WidgetTester tester) async {
    // App launch test
    await tester.pumpWidget(const WelloraApp());

    // Verify that Wellora title is displayed
    expect(find.text('Wellora'), findsWidgets);
  });
}