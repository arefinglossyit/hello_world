import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:hello_world/main.dart';
import 'package:hello_world/todo_repository.dart';

http.Client _zenClient(String body, [int status = 200]) => MockClient(
      (request) async => http.Response(body, status),
    );

void main() {
  testWidgets('Shows Hello World and text from the API', (tester) async {
    await tester.pumpWidget(
      MyApp(client: _zenClient('Keep it logically awesome.')),
    );

    // API text is loading first.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Hello World!'), findsOneWidget);
    expect(find.text('Keep it logically awesome.'), findsOneWidget);
  });

  testWidgets('Shows error message when the API fails', (tester) async {
    await tester.pumpWidget(MyApp(client: _zenClient('Server Error', 500)));

    await tester.pumpAndSettle();

    expect(find.text('Hello World!'), findsOneWidget);
    expect(find.text('Could not load message from API'), findsOneWidget);
  });

  testWidgets('To-do list supports add, edit, toggle and delete',
      (tester) async {
    final repo = InMemoryTodoRepository();
    await tester.pumpWidget(MyApp(
      client: _zenClient('zen'),
      todoRepository: repo,
    ));
    await tester.pumpAndSettle();

    // Open the to-do list.
    await tester.tap(find.text('My To-Do List'));
    await tester.pumpAndSettle();
    expect(find.text('No to-dos yet. Tap + to add one.'), findsOneWidget);

    // Add a to-do.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Buy milk'), findsOneWidget);

    // Edit it.
    await tester.tap(find.text('Buy milk'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Buy oat milk');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Buy oat milk'), findsOneWidget);

    // Mark as done (checkbox toggle).
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Delete by swiping.
    await tester.drag(find.text('Buy oat milk'), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Buy oat milk'), findsNothing);
    expect(find.text('No to-dos yet. Tap + to add one.'), findsOneWidget);
  });
}
