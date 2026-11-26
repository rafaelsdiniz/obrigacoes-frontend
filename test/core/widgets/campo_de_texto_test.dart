import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/core/tema/tema.dart';
import 'package:obrigacoes_app/core/widgets/campo_de_texto.dart';

void main() {
  testWidgets('o leitor de tela anuncia o rótulo, a obrigatoriedade e o erro do campo', (tester) async {
    final semantica = tester.ensureSemantics();
    final chave = GlobalKey<FormState>();
    final controlador = TextEditingController();
    addTearDown(controlador.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: Tema.claro(),
        home: Scaffold(
          body: Form(
            key: chave,
            child: CampoDeTexto(
              rotulo: 'Nome',
              obrigatorio: true,
              controlador: controlador,
              validador: (valor) => (valor ?? '').isEmpty ? 'O nome é obrigatório.' : null,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSemantics(find.byType(TextField)), isSemantics(label: 'Nome, obrigatório', isTextField: true));

    chave.currentState!.validate();
    await tester.pump();
    expect(find.text('O nome é obrigatório.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Ana');
    expect(controlador.text, 'Ana');
    semantica.dispose();
  });
}
