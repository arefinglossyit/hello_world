import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hello_world/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App shows Hello World and text loaded from the API',
      (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello World!'), findsOneWidget);

    // Wait for the real API call to finish (or fail).
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // The API call must have succeeded: no spinner, no error text.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Could not load message from API'), findsNothing);
  });
}
