import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/core/tema/tema.dart';
import 'package:obrigacoes_app/core/widgets/controle_segmentado.dart';

void main() {
  Future<List<String>> abrir(WidgetTester tester) async {
    final escolhas = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: Tema.claro(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ControleSegmentado<String>(
              opcoes: const [(valor: 'todas', rotulo: 'Todas'), (valor: 'ativas', rotulo: 'Ativas')],
              selecionado: escolhas.isEmpty ? 'todas' : escolhas.last,
              aoSelecionar: (valor) => setState(() => escolhas.add(valor)),
            ),
          ),
        ),
      ),
    );
    return escolhas;
  }

  testWidgets('seleciona pelo toque e informa a seleção aos leitores de tela', (tester) async {
    final semantica = tester.ensureSemantics();
    final escolhas = await abrir(tester);

    await tester.tap(find.text('Ativas'));
    await tester.pumpAndSettle();

    expect(escolhas, ['ativas']);
    expect(
      tester.getSemantics(find.text('Ativas')),
      isSemantics(
        label: 'Ativas',
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    semantica.dispose();
  });

  testWidgets('pode ser operado pelo teclado', (tester) async {
    final escolhas = await abrir(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(escolhas, ['ativas']);
  });
}
