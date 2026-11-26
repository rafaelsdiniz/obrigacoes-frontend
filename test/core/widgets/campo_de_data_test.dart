import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/core/tema/tema.dart';
import 'package:obrigacoes_app/core/widgets/campo_de_data.dart';

void main() {
  for (final tecla in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
    testWidgets('abre o calendário pelo teclado com ${tecla.keyLabel.isEmpty ? 'espaço' : tecla.keyLabel}', (
      tester,
    ) async {
      DateTime? escolhida;
      await tester.pumpWidget(
        MaterialApp(
          theme: Tema.claro(),
          home: Scaffold(
            body: CampoDeData(
              rotulo: 'Vencimento',
              valor: DateTime(2026, 11, 10),
              primeiraData: DateTime(2000),
              ultimaData: DateTime(2100),
              aoSelecionar: (data) => escolhida = data,
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(tecla);
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(escolhida, DateTime(2026, 11, 15));
    });
  }
}
