import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/core/tema/tema.dart';
import 'package:obrigacoes_app/core/widgets/botao_de_acao.dart';
import 'package:obrigacoes_app/core/widgets/icone.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('todo ícone do catálogo tem um SVG empacotado que usa a cor do tema', () async {
    for (final icone in Icones.values) {
      final svg = await rootBundle.loadString(icone.caminho);
      expect(svg, contains('stroke="currentColor"'), reason: icone.caminho);
    }
  });

  testWidgets('o botão de ação compacto mostra o ícone em branco sobre o grafite', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: Tema.claro(),
        home: Scaffold(
          body: BotaoDeAcao(rotulo: 'Nova obrigação', icone: Icones.adicionar, aoPressionar: () {}),
        ),
      ),
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.colorFilter, const ColorFilter.mode(Colors.white, BlendMode.srcIn));
  });
}
