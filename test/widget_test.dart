// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluttertcc/models/registro_alimentacao.dart';
import 'package:fluttertcc/models/registro_sintoma.dart';
import 'package:fluttertcc/screens/inicio_screen.dart';

void main() {
  testWidgets('exibe o painel inicial sem registros', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InicioScreen(
          sintomasStream: Stream<List<RegistroSintoma>>.value(const []),
          refeicoesStream: Stream<List<RegistroAlimentacao>>.value(const []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SAÚDE INTESTINAL'), findsOneWidget);
    expect(find.text('Resumo de hoje'), findsOneWidget);
    expect(find.text('Frequência dos sintomas'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Possíveis padrões'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Possíveis padrões'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Continue registrando'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Continue registrando'), findsOneWidget);
  });
}
