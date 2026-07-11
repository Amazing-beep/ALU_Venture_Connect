import 'package:flutter_test/flutter_test.dart';
import 'package:venture_connect/main.dart';

void main() {
  testWidgets('VentureConnect app launch and splash smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VentureConnectApp());

    // Verify that the splash screen shows 'ALU VentureConnect'
    expect(find.text('ALU VentureConnect'), findsOneWidget);
    expect(find.text('Bridging Talent and Campus Innovation'), findsOneWidget);
  });
}
