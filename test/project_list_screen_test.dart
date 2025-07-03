import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/presentation/screens/project_list_screen.dart';

void main() {
  testWidgets('ProjectListScreen shows loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: ProjectListScreen())));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
