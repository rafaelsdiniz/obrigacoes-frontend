import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/app/roteador.dart';

import 'apoio.dart';

void main() {
  setUpAll(registrarValoresPadrao);

  testWidgets('abre no painel e navega pela barra lateral em telas largas', (tester) async {
    await abrirApp(tester, tamanho: const Size(1280, 800));

    expect(find.bySemanticsLabel('Player Contabilidade'), findsOneWidget);
    expect(find.text('Próximos vencimentos'), findsOneWidget);

    await tester.tap(find.widgetWithText(InkWell, 'Empresas'));
    await tester.pumpAndSettle();
    expect(find.text('Contábil Alfa LTDA'), findsWidgets);

    await tester.tap(find.widgetWithText(InkWell, 'Usuários'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Souza'), findsOneWidget);
  });

  testWidgets('usa a barra inferior e o botão compacto em telas estreitas', (tester) async {
    await abrirApp(tester, tamanho: const Size(400, 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Empresas'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Nova empresa'), findsOneWidget);
  });

  testWidgets('tocar na seção atual volta para a lista', (tester) async {
    final itemEmpresasDaBarraLateral = find.descendant(
      of: find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label == 'Navegação principal'),
      matching: find.widgetWithText(InkWell, 'Empresas'),
    );
    await abrirApp(tester, tamanho: const Size(1280, 800));
    await tester.tap(itemEmpresasDaBarraLateral);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nova empresa'));
    await tester.pumpAndSettle();
    expect(find.text('Identificação'), findsOneWidget);

    await tester.tap(itemEmpresasDaBarraLateral);
    await tester.pumpAndSettle();
    expect(find.text('Identificação'), findsNothing);
  });

  testWidgets('mostra página não encontrada para endereços desconhecidos', (tester) async {
    final container = await abrirApp(tester, tamanho: const Size(1280, 800));

    container.read(roteadorProvider).go('/empresas/abc/editar');
    await tester.pumpAndSettle();
    expect(find.text('Página não encontrada'), findsOneWidget);

    container.read(roteadorProvider).go('/nao-existe');
    await tester.pumpAndSettle();
    expect(find.text('Página não encontrada'), findsOneWidget);
  });
}
