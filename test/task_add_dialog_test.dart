import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/presentation/screens/task_add_dialog.dart';

void main() {
  testWidgets('TaskAddDialog shows input fields and add button', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: Scaffold(body: TaskAddDialog()))));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
  });
}
