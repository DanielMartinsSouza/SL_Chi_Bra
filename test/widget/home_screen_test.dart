import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:china_brasil_sl/presentation/screens/home_screen.dart';

void main() {
  testWidgets('Renderiza elementos principais da tela inicial',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Tradutor pt-BR para Libras'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Traduzir'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}
