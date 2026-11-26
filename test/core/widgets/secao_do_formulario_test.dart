import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/core/widgets/campo_do_formulario.dart';
import 'package:obrigacoes_app/core/widgets/secao_do_formulario.dart';

void main() {
  Future<void> abrir(WidgetTester tester, double largura) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: largura,
              child: const SecaoDoFormulario(
                titulo: 'Contato',
                descricao: 'Canais de contato.',
                campos: [
                  CampoDoFormulario(Text('campo inteiro'), larguraInteira: true),
                  CampoDoFormulario(Text('campo A')),
                  CampoDoFormulario(Text('campo B')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('em telas largas a descrição fica ao lado e os campos dividem a linha', (tester) async {
    await abrir(tester, 1000);

    expect(tester.getTopLeft(find.text('Contato')).dy, tester.getTopLeft(find.text('campo inteiro')).dy);
    expect(tester.getTopLeft(find.text('campo A')).dy, tester.getTopLeft(find.text('campo B')).dy);
  });

  testWidgets('em telas estreitas tudo fica empilhado', (tester) async {
    await abrir(tester, 360);

    expect(tester.getTopLeft(find.text('campo inteiro')).dy, greaterThan(tester.getTopLeft(find.text('Contato')).dy));
    expect(tester.getTopLeft(find.text('campo B')).dy, greaterThan(tester.getTopLeft(find.text('campo A')).dy));
  });
}
