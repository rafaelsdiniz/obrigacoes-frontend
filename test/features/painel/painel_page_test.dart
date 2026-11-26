import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/filtro_obrigacoes.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/resumo_obrigacoes.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/status_obrigacao.dart';

import '../../apoio.dart';

void main() {
  setUpAll(registrarValoresPadrao);

  testWidgets('mostra os totais e abre a lista filtrada ao tocar em um indicador', (tester) async {
    final falsos = repositoriosComDados();
    when(
      () => falsos.obrigacoes.resumir(
        empresaId: any(named: 'empresaId'),
        responsavelId: any(named: 'responsavelId'),
      ),
    ).thenAnswer((_) async => const ResumoObrigacoes(pendentes: 4, emAndamento: 2, concluidas: 9, atrasadas: 3));
    await abrirApp(tester, tamanho: const Size(1280, 900), repositorios: falsos);

    expect(find.bySemanticsLabel('Pendentes: 4. Ver obrigações'), findsOneWidget);
    expect(find.bySemanticsLabel('Atrasadas: 3. Ver obrigações'), findsOneWidget);
    expect(find.text('Entrega da DCTFWeb'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Atrasadas: 3. Ver obrigações'));
    await tester.pumpAndSettle();

    final filtro = verify(() => falsos.obrigacoes.listar(captureAny())).captured.last as FiltroObrigacoes;
    expect(filtro.somenteAtrasadas, isTrue);
    expect(find.text('Prazos e entregas das empresas clientes'), findsOneWidget);
  });

  testWidgets('o leitor de tela consegue abrir a lista a partir de um indicador', (tester) async {
    final semantica = tester.ensureSemantics();
    final falsos = repositoriosComDados();
    await abrirApp(tester, tamanho: const Size(1280, 900), repositorios: falsos);

    final indicador = tester.getSemantics(find.bySemanticsLabel('Concluídas: 1. Ver obrigações'));
    expect(indicador.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    tester.semantics.tap(find.semantics.byLabel('Concluídas: 1. Ver obrigações'));
    await tester.pumpAndSettle();

    final filtro = verify(() => falsos.obrigacoes.listar(captureAny())).captured.last as FiltroObrigacoes;
    expect(filtro.status, {StatusObrigacao.concluida});
    semantica.dispose();
  });
}
