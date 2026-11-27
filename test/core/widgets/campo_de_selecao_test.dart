import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/core/tema/tema.dart';
import 'package:obrigacoes_app/core/widgets/campo_de_selecao.dart';
import 'package:obrigacoes_app/core/widgets/opcao.dart';

void main() {
  const alfa = (valor: 1, rotulo: 'Contábil Alfa');
  const beta = (valor: 2, rotulo: 'Beta Serviços');

  Future<GlobalKey<FormState>> montar(WidgetTester tester, List<Opcao<int>> opcoes) async {
    final formulario = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: Tema.claro(),
        home: Scaffold(
          body: Form(
            key: formulario,
            child: CampoDeSelecao<int>(
              rotulo: 'Empresa',
              dica: 'Selecione a empresa',
              valor: 1,
              opcoes: opcoes,
              validador: (valor) => valor == null ? 'A empresa é obrigatória.' : null,
              aoSelecionar: (_) {},
            ),
          ),
        ),
      ),
    );
    return formulario;
  }

  testWidgets('mostra a opção escolhida enquanto ela continua disponível', (tester) async {
    final formulario = await montar(tester, const [alfa, beta]);

    expect(find.text('Contábil Alfa'), findsOneWidget);
    expect(formulario.currentState!.validate(), isTrue);
  });

  testWidgets('descarta a escolha que deixou de estar entre as opções e exige uma nova', (tester) async {
    await montar(tester, const [alfa, beta]);
    final formulario = await montar(tester, const [beta]);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Contábil Alfa'), findsNothing);
    expect(find.text('Selecione a empresa'), findsOneWidget);
    expect(formulario.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('A empresa é obrigatória.'), findsOneWidget);
  });
}
