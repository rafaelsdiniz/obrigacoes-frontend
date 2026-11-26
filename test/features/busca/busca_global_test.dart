import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/core/dominio/filtro_cadastro.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/filtro_obrigacoes.dart';

import '../../apoio.dart';

void main() {
  setUpAll(registrarValoresPadrao);

  const desktop = Size(1280, 800);
  final campoDaBusca = find.widgetWithText(TextField, 'Buscar obrigações, empresas ou usuários');

  Future<void> digitar(WidgetTester tester, String termo) async {
    await tester.tap(campoDaBusca);
    await tester.enterText(campoDaBusca, termo);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  }

  testWidgets('agrupa obrigações, empresas e usuários encontrados', (tester) async {
    final falsos = repositoriosComDados();
    await abrirApp(tester, tamanho: desktop, repositorios: falsos);

    await digitar(tester, 'alfa');

    expect(find.text('OBRIGAÇÕES'), findsOneWidget);
    expect(find.text('EMPRESAS'), findsOneWidget);
    expect(find.text('USUÁRIOS'), findsOneWidget);
    expect(find.textContaining('Contábil Alfa LTDA', findRichText: true), findsWidgets);
    verify(() => falsos.empresas.listar(any(that: isA<FiltroCadastro>().having((f) => f.busca, 'busca', 'alfa'))))
        .called(1);
    verify(() => falsos.obrigacoes.listar(any(that: isA<FiltroObrigacoes>().having((f) => f.busca, 'busca', 'alfa'))))
        .called(1);
  });

  testWidgets('não consulta a API com menos de dois caracteres', (tester) async {
    final falsos = repositoriosComDados();
    await abrirApp(tester, tamanho: desktop, repositorios: falsos);

    await digitar(tester, 'a');

    verifyNever(() => falsos.empresas.listar(any(that: isA<FiltroCadastro>().having((f) => f.busca, 'busca', 'a'))));
    expect(find.text('EMPRESAS'), findsNothing);
  });

  testWidgets('Enter abre o primeiro resultado e limpa a busca', (tester) async {
    await abrirApp(tester, tamanho: desktop);

    await digitar(tester, 'dctf');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Iniciar obrigação'), findsOneWidget);
    expect(find.text('OBRIGAÇÕES'), findsNothing);
  });

  testWidgets('as setas mudam o item selecionado antes de abrir com Enter', (tester) async {
    await abrirApp(tester, tamanho: desktop);

    await digitar(tester, 'alfa');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.textContaining('Esta obrigação venceu em'), findsOneWidget);
    expect(find.text('FGTS Digital'), findsWidgets);
  });

  testWidgets('a tecla / leva o foco para a busca e Esc limpa', (tester) async {
    await abrirApp(tester, tamanho: desktop);

    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pump();
    expect(tester.widget<TextField>(campoDaBusca).focusNode?.hasFocus, isTrue);

    await tester.enterText(campoDaBusca, 'alfa');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(campoDaBusca).controller?.text, isEmpty);
    expect(find.text('EMPRESAS'), findsNothing);
  });

  testWidgets('no celular a busca abre em tela cheia', (tester) async {
    await abrirApp(tester, tamanho: const Size(400, 800));

    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Fechar busca'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'alfa');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('EMPRESAS'), findsOneWidget);
  });
}
