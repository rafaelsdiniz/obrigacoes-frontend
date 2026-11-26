import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/core/dominio/termos_do_cadastro.dart';
import 'package:obrigacoes_app/core/tema/tema.dart';
import 'package:obrigacoes_app/core/widgets/indicador_de_situacao.dart';

void main() {
  const termos = TermosDoCadastro(substantivo: 'Empresa', genero: Genero.feminino);

  Future<Text> rotulo(WidgetTester tester, Situacao situacao, String texto) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: Tema.claro(),
        home: Scaffold(
          body: IndicadorDeSituacao(situacao: situacao, termos: termos),
        ),
      ),
    );
    return tester.widget<Text>(find.text(texto));
  }

  testWidgets('usa verde para ativa e cinza para inativa, sempre com texto', (tester) async {
    expect((await rotulo(tester, Situacao.ativo, 'Ativa')).style?.color, Cores.sucesso);
    expect((await rotulo(tester, Situacao.inativo, 'Inativa')).style?.color, Cores.textoSecundario);
  });
}
