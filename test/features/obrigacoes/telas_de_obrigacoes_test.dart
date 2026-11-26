import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/app/roteador.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/core/http/erro_api.dart';
import 'package:obrigacoes_app/core/widgets/campo_de_texto.dart';
import 'package:obrigacoes_app/core/widgets/controle_segmentado.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/filtro_obrigacoes.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/historico_de_status.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/obrigacao.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/status_obrigacao.dart';

import '../../apoio.dart';

void main() {
  setUpAll(registrarValoresPadrao);

  const desktop = Size(1280, 900);

  Future<RepositoriosFalsos> abrirEm(WidgetTester tester, String rota, {RepositoriosFalsos? repositorios}) async {
    final falsos = repositorios ?? repositoriosComDados();
    final container = await abrirApp(tester, tamanho: desktop, repositorios: falsos);
    container.read(roteadorProvider).go(rota);
    await tester.pumpAndSettle();
    return falsos;
  }

  group('lista', () {
    testWidgets('mostra o prazo relativo e o status de cada obrigação', (tester) async {
      await abrirEm(tester, '/obrigacoes');

      expect(find.text('Venceu há 3 dias'), findsOneWidget);
      expect(find.text('Vence em 5 dias'), findsOneWidget);
      expect(find.text('Entregue'), findsOneWidget);
      expect(find.text('Em andamento'), findsWidgets);
    });

    testWidgets('filtra por status e por atraso', (tester) async {
      final falsos = await abrirEm(tester, '/obrigacoes');

      await tester.tap(
        find.descendant(of: find.byType(ControleSegmentado<StatusObrigacao?>), matching: find.text('Pendente')),
      );
      await tester.pumpAndSettle();
      var filtro = verify(() => falsos.obrigacoes.listar(captureAny())).captured.last as FiltroObrigacoes;
      expect(filtro.status, {StatusObrigacao.pendente});

      await tester.tap(find.text('Somente atrasadas'));
      await tester.pumpAndSettle();
      filtro = verify(() => falsos.obrigacoes.listar(captureAny())).captured.last as FiltroObrigacoes;
      expect(filtro.somenteAtrasadas, isTrue);
      expect(filtro.status, {StatusObrigacao.pendente});
    });

    testWidgets('ao pedir só as atrasadas deixa de filtrar por concluídas', (tester) async {
      final falsos = await abrirEm(tester, '/obrigacoes');

      await tester.tap(
        find.descendant(of: find.byType(ControleSegmentado<StatusObrigacao?>), matching: find.text('Concluída')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Somente atrasadas'));
      await tester.pumpAndSettle();

      final filtro = verify(() => falsos.obrigacoes.listar(captureAny())).captured.last as FiltroObrigacoes;
      expect(filtro.status, isEmpty);
      expect(filtro.somenteAtrasadas, isTrue);
    });
  });

  group('detalhe', () {
    testWidgets('inicia uma obrigação pendente sem pedir confirmação', (tester) async {
      final falsos = repositoriosComDados();
      when(() => falsos.obrigacoes.avancarStatus(any(), any()))
          .thenAnswer((_) async => obrigacaoDeExemplo(status: StatusObrigacao.emAndamento));
      await abrirEm(tester, '/obrigacoes/10', repositorios: falsos);

      expect(find.text('Obrigação cadastrada'), findsOneWidget);
      await tester.tap(find.text('Iniciar obrigação'));
      await tester.pumpAndSettle();

      verify(() => falsos.obrigacoes.avancarStatus(any(), StatusObrigacao.emAndamento)).called(1);
      expect(find.text('Obrigação iniciada.'), findsOneWidget);
    });

    testWidgets('não envia o avanço duas vezes enquanto a obrigação recarrega', (tester) async {
      final falsos = repositoriosComDados();
      final recarga = Completer<Obrigacao>();
      var buscas = 0;
      when(() => falsos.obrigacoes.buscar(10)).thenAnswer((_) {
        buscas++;
        return buscas == 1 ? Future.value(obrigacaoDeExemplo()) : recarga.future;
      });
      when(() => falsos.obrigacoes.avancarStatus(any(), any()))
          .thenAnswer((_) async => obrigacaoDeExemplo(status: StatusObrigacao.emAndamento));
      await abrirEm(tester, '/obrigacoes/10', repositorios: falsos);

      await tester.tap(find.text('Iniciar obrigação'));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Iniciar obrigação'), warnIfMissed: false);
      await tester.pump();
      recarga.complete(obrigacaoDeExemplo(status: StatusObrigacao.emAndamento));
      await tester.pumpAndSettle();

      verify(() => falsos.obrigacoes.avancarStatus(any(), StatusObrigacao.emAndamento)).called(1);
    });

    testWidgets('pede confirmação antes de concluir', (tester) async {
      final falsos = await abrirEm(tester, '/obrigacoes/11');

      await tester.tap(find.text('Concluir obrigação'));
      await tester.pumpAndSettle();
      expect(find.text('Concluir obrigação?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(() => falsos.obrigacoes.avancarStatus(any(), any()));
    });

    testWidgets('quando outra pessoa já avançou o status, recarrega a obrigação', (tester) async {
      final falsos = repositoriosComDados();
      when(() => falsos.obrigacoes.avancarStatus(any(), any()))
          .thenThrow(const ErroApi(codigo: CodigoErro.regraNegocio, mensagem: 'A obrigação já está em andamento.'));
      await abrirEm(tester, '/obrigacoes/10', repositorios: falsos);
      when(() => falsos.obrigacoes.buscar(10))
          .thenAnswer((_) async => obrigacaoDeExemplo(status: StatusObrigacao.emAndamento));

      await tester.tap(find.text('Iniciar obrigação'));
      await tester.pumpAndSettle();

      expect(find.text('A obrigação já está em andamento.'), findsOneWidget);
      expect(find.text('Concluir obrigação'), findsOneWidget);
      verify(() => falsos.obrigacoes.historico(10)).called(2);
    });

    testWidgets('obrigação concluída não oferece edição nem mudança de status', (tester) async {
      await abrirEm(tester, '/obrigacoes/12');

      expect(find.byTooltip('Editar'), findsNothing);
      expect(find.text('Concluir obrigação'), findsNothing);
      expect(find.text('Iniciar obrigação'), findsNothing);
    });

    testWidgets('permite tentar de novo quando o histórico não carrega', (tester) async {
      final falsos = repositoriosComDados();
      when(() => falsos.obrigacoes.historico(any()))
          .thenThrow(const ErroApi(codigo: CodigoErro.semConexao, mensagem: 'Sem conexão com o servidor.'));
      await abrirEm(tester, '/obrigacoes/10', repositorios: falsos);

      expect(find.text('Sem conexão com o servidor.'), findsOneWidget);
      when(() => falsos.obrigacoes.historico(any())).thenAnswer(
        (_) async => [TransicaoDeStatus(statusNovo: StatusObrigacao.pendente, alteradoEm: DateTime.utc(2026, 11, 20))],
      );
      await tester.ensureVisible(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Obrigação cadastrada'), findsOneWidget);
    });
  });

  group('formulário', () {
    Finder campo(String rotulo) => find.descendant(
      of: find.byWidgetPredicate((widget) => widget is CampoDeTexto && widget.rotulo == rotulo),
      matching: find.byType(TextFormField),
    );

    Future<void> salvar(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Salvar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
    }

    testWidgets('exige os campos obrigatórios e valida a competência', (tester) async {
      final falsos = await abrirEm(tester, '/obrigacoes/nova');

      await tester.enterText(campo('Competência'), '132026');
      await salvar(tester);

      expect(find.text('O título é obrigatório.'), findsOneWidget);
      expect(find.text('O tipo é obrigatório.'), findsOneWidget);
      expect(find.text('A data de vencimento é obrigatória.'), findsOneWidget);
      expect(find.text('A empresa é obrigatória.'), findsOneWidget);
      expect(find.text('Informe a competência no formato MM/AAAA.'), findsOneWidget);
      verifyNever(() => falsos.obrigacoes.cadastrar(any()));
    });

    testWidgets('recusa competência fora do intervalo aceito', (tester) async {
      await abrirEm(tester, '/obrigacoes/nova');

      await tester.enterText(campo('Competência'), '011999');
      await salvar(tester);

      expect(find.text('A competência deve estar entre 2000 e 2100.'), findsOneWidget);
    });

    testWidgets('avisa quando nem todos os cadastros ativos cabem na lista de seleção', (tester) async {
      final falsos = repositoriosComDados();
      when(() => falsos.empresas.listarAtivas())
          .thenAnswer((_) async => paginaCom([empresaDeExemplo()], totalItens: 140, totalPaginas: 2));
      await abrirEm(tester, '/obrigacoes/nova', repositorios: falsos);

      expect(find.text('Mostrando 1 de 140 empresas ativas, em ordem alfabética.'), findsOneWidget);
    });

    testWidgets('não abre a edição de uma obrigação concluída', (tester) async {
      await abrirEm(tester, '/obrigacoes/12/editar');

      expect(find.text('Uma obrigação concluída não pode mais ser editada.'), findsOneWidget);
      expect(find.text('Salvar'), findsNothing);
      await tester.tap(find.text('Ver obrigação'));
      await tester.pumpAndSettle();
      expect(find.text('EFD-Reinf'), findsWidgets);
    });

    testWidgets('tentar novamente refaz as buscas que falharam', (tester) async {
      final falsos = repositoriosComDados();
      when(() => falsos.usuarios.listarAtivos())
          .thenThrow(const ErroApi(codigo: CodigoErro.semConexao, mensagem: 'Sem conexão com o servidor.'));
      await abrirEm(tester, '/obrigacoes/10/editar', repositorios: falsos);

      expect(find.text('Sem conexão com o servidor.'), findsOneWidget);
      when(() => falsos.usuarios.listarAtivos()).thenAnswer((_) async => paginaCom([usuarioDeExemplo()]));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Editar obrigação'), findsWidgets);
      verify(() => falsos.usuarios.listarAtivos()).called(2);
    });

    testWidgets('recarregar após conflito traz a versão atual da obrigação', (tester) async {
      final falsos = repositoriosComDados();
      when(
        () => falsos.obrigacoes.atualizar(any(), any()),
      ).thenThrow(const ErroApi(codigo: CodigoErro.conflito, mensagem: 'O registro foi alterado por outra operação.'));
      await abrirEm(tester, '/obrigacoes/10/editar', repositorios: falsos);
      await salvar(tester);

      when(() => falsos.obrigacoes.buscar(10))
          .thenAnswer((_) async => obrigacaoDeExemplo(titulo: 'DCTFWeb revisada', versao: 1));
      await tester.tap(find.text('Recarregar'));
      await tester.pumpAndSettle();

      expect(find.text('DCTFWeb revisada'), findsWidgets);
    });

    testWidgets('na edição mantém a empresa atual mesmo inativa e envia a versão lida', (tester) async {
      final falsos = repositoriosComDados();
      final obrigacao = obrigacaoDeExemplo(situacaoDaEmpresa: Situacao.inativo, empresaId: 7, versao: 3);
      when(() => falsos.obrigacoes.buscar(10)).thenAnswer((_) async => obrigacao);
      when(() => falsos.obrigacoes.atualizar(any(), any())).thenAnswer((_) async => obrigacao);
      await abrirEm(tester, '/obrigacoes/10/editar', repositorios: falsos);

      expect(find.text('Contábil Alfa LTDA (inativa)'), findsOneWidget);
      await tester.enterText(campo('Título'), 'DCTFWeb de outubro');
      await salvar(tester);

      final capturados = verify(() => falsos.obrigacoes.atualizar(captureAny(), captureAny())).captured;
      expect((capturados.first as Obrigacao).versao, 3);
      expect((capturados.last as DadosObrigacao).titulo, 'DCTFWeb de outubro');
      expect((capturados.last as DadosObrigacao).empresaId, 7);
    });
  });
}
