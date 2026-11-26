import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/app/roteador.dart';
import 'package:obrigacoes_app/core/widgets/indicador.dart';

import 'apoio.dart';

void main() {
  setUpAll(() async {
    registrarValoresPadrao();
    await carregarFontesDoApp();
  });

  const telas = {
    'celular pequeno': Size(320, 640),
    'celular': Size(400, 800),
    'tablet': Size(820, 1180),
    'desktop': Size(1280, 800),
  };
  const rotas = [
    '/painel',
    '/obrigacoes',
    '/obrigacoes/10',
    '/obrigacoes/nova',
    '/empresas',
    '/empresas/nova',
    '/usuarios',
    '/usuarios/novo',
  ];

  for (final MapEntry(key: nome, value: tamanho) in telas.entries) {
    testWidgets('todas as telas cabem no $nome com texto em dobro', (tester) async {
      final container = await abrirApp(tester, tamanho: tamanho, escalaDoTexto: 2);

      for (final rota in rotas) {
        container.read(roteadorProvider).go(rota);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: rota);
      }
    });
  }

  for (final MapEntry(key: nome, value: tamanho) in telas.entries) {
    testWidgets('painel, obrigações e empresas atendem contraste e alvos de toque no $nome', (tester) async {
      final semantica = tester.ensureSemantics();
      final container = await abrirApp(tester, tamanho: tamanho);

      for (final rota in ['/painel', '/obrigacoes', '/obrigacoes/10', '/empresas']) {
        container.read(roteadorProvider).go(rota);
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(textContrastGuideline), reason: rota);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline), reason: rota);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline), reason: rota);
      }
      semantica.dispose();
    });
  }

  testWidgets('no desktop o cabeçalho das colunas fica alinhado com os dados', (tester) async {
    final container = await abrirApp(tester, tamanho: const Size(1280, 800));
    container.read(roteadorProvider).go('/empresas');
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('CNPJ')).dx, tester.getTopLeft(find.text('11.222.333/0001-81').first).dx);
    expect(tester.getTopLeft(find.text('SITUAÇÃO')).dx, tester.getTopLeft(find.byType(Indicador).first).dx);
  });
}
