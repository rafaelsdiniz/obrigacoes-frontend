import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/core/widgets/campo_busca.dart';

void main() {
  testWidgets('busca só depois de uma pausa na digitação e limpa de imediato', (tester) async {
    final buscas = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CampoBusca(dica: 'Buscar', aoBuscar: buscas.add),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'al');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(find.byType(TextField), 'alfa');
    await tester.pump(CampoBusca.espera - const Duration(milliseconds: 1));
    expect(buscas, isEmpty);

    await tester.pump(const Duration(milliseconds: 1));
    expect(buscas, ['alfa']);

    await tester.tap(find.byTooltip('Limpar busca'));
    await tester.pump();
    expect(buscas, ['alfa', '']);
  });

  testWidgets('mostra o valor quando o filtro muda por fora do campo', (tester) async {
    final buscas = <String>[];
    var valor = 'xyz';
    late StateSetter alterar;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              alterar = setState;
              return CampoBusca(dica: 'Buscar', valorInicial: valor, aoBuscar: buscas.add);
            },
          ),
        ),
      ),
    );
    expect(find.text('xyz'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'xyzw');
    alterar(() => valor = '');
    await tester.pump();
    await tester.pump(CampoBusca.espera);

    expect(find.text('xyzw'), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    expect(buscas, isEmpty);
  });
}
