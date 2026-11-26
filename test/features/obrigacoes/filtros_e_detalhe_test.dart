import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/app/roteador.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/core/tema/tema.dart';
import 'package:obrigacoes_app/core/widgets/controle_segmentado.dart';
import 'package:obrigacoes_app/core/widgets/icone.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/filtro_obrigacoes.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/resumo_obrigacoes.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/status_obrigacao.dart';

import '../../apoio.dart';

void main() {
  setUpAll(registrarValoresPadrao);

  const desktop = Size(1440, 1000);

  Future<RepositoriosFalsos> abrirEm(WidgetTester tester, String rota, {RepositoriosFalsos? repositorios}) async {
    final falsos = repositorios ?? repositoriosComDados();
    final container = await abrirApp(tester, tamanho: desktop, repositorios: falsos);
    container.read(roteadorProvider).go(rota);
    await tester.pumpAndSettle();
    return falsos;
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  Finder itemDoMenu(String texto) => find.descendant(of: find.byType(MenuItemButton), matching: find.text(texto));

  Matcher filtroCom(bool Function(FiltroObrigacoes filtro) condicao) =>
      isA<FiltroObrigacoes>().having(condicao, 'condição do filtro', isTrue);

  group('filtros da lista', () {
    testWidgets('filtra por empresa e "Limpar filtros" volta para todas', (tester) async {
      final falsos = await abrirEm(tester, '/obrigacoes');

      await tocar(tester, find.text('Empresa'));
      await tocar(tester, itemDoMenu('Contábil Alfa LTDA'));

      verify(() => falsos.obrigacoes.listar(any(that: filtroCom((filtro) => filtro.empresaId == 1)))).called(1);
      expect(find.text('Limpar filtros'), findsOneWidget);

      await tocar(tester, find.text('Limpar filtros'));

      expect(find.text('Limpar filtros'), findsNothing);
      verify(() => falsos.obrigacoes.listar(any(that: filtroCom((filtro) => !filtro.temFiltrosAdicionais))))
          .called(greaterThan(0));
    });

    testWidgets('o ícone de "Somente atrasadas" continua visível com o filtro ligado', (tester) async {
      await abrirEm(tester, '/obrigacoes');
      final botao = find.ancestor(of: find.text('Somente atrasadas'), matching: find.byType(OutlinedButton));
      Icone icone() => tester.widget<Icone>(find.descendant(of: botao, matching: find.byType(Icone)));

      expect(icone().cor, Paleta.claro.erro);

      await tocar(tester, find.text('Somente atrasadas'));

      expect(icone().cor, Paleta.claro.sobreForte);
      expect(icone().cor, isNot(Paleta.claro.erro));
    });

    testWidgets('os filtros mostram também cadastros inativos, identificados', (tester) async {
      final falsos = repositoriosComDados();
      when(
        () => falsos.empresas.listarTodas(),
      ).thenAnswer((_) async => paginaCom([empresaDeExemplo(), empresaDeExemplo(id: 2, situacao: Situacao.inativo)]));
      await abrirEm(tester, '/obrigacoes', repositorios: falsos);

      await tocar(tester, find.text('Empresa'));

      expect(itemDoMenu('Contábil Alfa LTDA (inativa)'), findsOneWidget);
    });

    testWidgets('filtra por tipo e por período de vencimento e muda a ordenação', (tester) async {
      final falsos = await abrirEm(tester, '/obrigacoes');

      await tocar(tester, find.text('Tipo'));
      await tocar(tester, itemDoMenu('Fiscal'));
      await tocar(tester, find.text('Vencimento').first);
      await tocar(tester, itemDoMenu('Este mês'));
      await tocar(tester, find.text('Ordenar: vencimento mais antigo'));
      await tocar(tester, itemDoMenu('Título (A–Z)'));

      verify(
        () => falsos.obrigacoes.listar(
          any(
            that: filtroCom(
              (filtro) =>
                  filtro.tipo?.name == 'fiscal' &&
                  filtro.periodo == PeriodoDeVencimento.esteMes &&
                  filtro.ordem == OrdemDasObrigacoes.titulo,
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets('as abas mostram a contagem do resumo, que some quando há busca', (tester) async {
      final falsos = repositoriosComDados();
      when(
        () => falsos.obrigacoes.resumir(
          empresaId: any(named: 'empresaId'),
          responsavelId: any(named: 'responsavelId'),
        ),
      ).thenAnswer((_) async => const ResumoObrigacoes(pendentes: 4, emAndamento: 2, concluidas: 9, atrasadas: 3));
      await abrirEm(tester, '/obrigacoes', repositorios: falsos);
      final abas = find.byType(ControleSegmentado<StatusObrigacao?>);

      expect(find.descendant(of: abas, matching: find.text('15')), findsOneWidget);
      expect(find.descendant(of: abas, matching: find.text('9')), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Buscar por título ou descrição'), 'dctf');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.descendant(of: abas, matching: find.text('15')), findsNothing);
    });
  });

  group('detalhe', () {
    testWidgets('obrigação atrasada mostra a faixa com os dias de atraso, as etapas e o registro', (tester) async {
      await abrirEm(tester, '/obrigacoes/11');

      expect(find.textContaining('Esta obrigação venceu em'), findsOneWidget);
      expect(find.textContaining('há 3 dias.'), findsOneWidget);
      expect(find.bySemanticsLabel('Pendente, etapa cumprida'), findsOneWidget);
      expect(find.bySemanticsLabel('Em andamento, etapa atual'), findsOneWidget);
      expect(find.bySemanticsLabel('Concluída, próxima etapa'), findsOneWidget);
      expect(find.text('#11'), findsOneWidget);
    });

    testWidgets('obrigação concluída mostra a faixa de concluída e não oferece edição', (tester) async {
      await abrirEm(tester, '/obrigacoes/12');

      expect(find.text('Obrigação concluída. Ela não pode mais ser editada nem mudar de status.'), findsOneWidget);
      expect(find.text('Editar'), findsNothing);
    });
  });
}
