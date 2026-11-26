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
}
