import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hello_world/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App shows Hello World on the home screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello World!'), findsOneWidget);

    await tester.pumpAndSettle();
  });
}
