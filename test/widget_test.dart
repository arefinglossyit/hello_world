import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:hello_world/main.dart';

void main() {
  testWidgets('Shows Hello World and text from the API', (tester) async {
    await tester.pumpWidget(
      MyApp(
        client: MockClient(
          (request) async => http.Response('Keep it logically awesome.', 200),
        ),
      ),
    );

    // API text is loading first.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Hello World!'), findsOneWidget);
    expect(find.text('Keep it logically awesome.'), findsOneWidget);
  });

  testWidgets('Shows error message when the API fails', (tester) async {
    await tester.pumpWidget(
      MyApp(
        client: MockClient(
          (request) async => http.Response('Server Error', 500),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hello World!'), findsOneWidget);
    expect(find.text('Could not load message from API'), findsOneWidget);
  });
}
