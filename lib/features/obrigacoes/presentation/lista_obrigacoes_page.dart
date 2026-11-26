import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/dominio/situacao.dart';
import '../../../core/layout/medidas.dart';
import '../../../core/tema/tema.dart';
import '../../../core/widgets/campo_busca.dart';
import '../../../core/widgets/controle_segmentado.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/lista_paginada.dart';
import '../../../core/widgets/menu_de_filtro.dart';
import '../../../core/widgets/pagina_de_listagem.dart';
import '../../empresas/domain/empresa.dart';
import '../../usuarios/domain/usuario.dart';
import '../domain/filtro_obrigacoes.dart';
import '../domain/obrigacao.dart';
import '../domain/status_obrigacao.dart';
import '../domain/tipo_obrigacao.dart';
import 'linha_de_obrigacao.dart';
import 'obrigacoes_providers.dart';
import 'rotas_obrigacoes.dart';

class ListaObrigacoesPage extends ConsumerWidget {
  const ListaObrigacoesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.read(filtroObrigacoesProvider.notifier);
    return PaginaDeListagem(
      titulo: 'Obrigações',
      subtitulo: 'Prazos e entregas das empresas clientes',
      rotuloNovo: 'Nova obrigação',
      aoCriarNovo: () => context.go(RotasObrigacoes.nova),
      filtros: _Filtros(filtro: ref.watch(filtroObrigacoesProvider), notifier: filtro),
      conteudo: ListaPaginada<Obrigacao>(
        estado: ref.watch(paginaObrigacoesProvider),
        cabecalho: const CabecalhoDeObrigacoes(),
        vazio: const EstadoVazio(
          icone: Icones.obrigacoes,
          titulo: 'Nenhuma obrigação encontrada',
          mensagem: 'Cadastre uma obrigação ou ajuste os filtros.',
        ),
        aoMudarPagina: filtro.irParaPagina,
        aoTentarNovamente: () => ref.invalidate(paginaObrigacoesProvider),
        itemBuilder: (context, obrigacao) => LinhaDeObrigacao(obrigacao),
      ),
    );
  }
}

class _Filtros extends ConsumerWidget {
  const _Filtros({required this.filtro, required this.notifier});

  final FiltroObrigacoes filtro;
  final FiltroObrigacoesNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumo = filtro.contagemPorStatusValida ? ref.watch(resumoDaListaProvider).value : null;
    final contagens = <StatusObrigacao?, int>{
      if (resumo != null && !filtro.somenteAtrasadas) ...{
        null: resumo.pendentes + resumo.emAndamento + resumo.concluidas,
        StatusObrigacao.pendente: resumo.pendentes,
        StatusObrigacao.emAndamento: resumo.emAndamento,
        StatusObrigacao.concluida: resumo.concluidas,
      },
    };
    final menus = [
      MenuDeFiltro<int>(
        rotulo: 'Empresa',
        rotuloDeTodos: 'Todas as empresas',
        icone: Icones.empresas,
        opcoes: [
          for (final empresa in ref.watch(empresasDosFiltrosProvider).value?.itens ?? const <Empresa>[])
            (
              valor: empresa.id,
              rotulo: empresa.situacao == Situacao.ativo ? empresa.razaoSocial : '${empresa.razaoSocial} (inativa)',
            ),
        ],
        selecionado: filtro.empresaId,
        aoSelecionar: notifier.filtrarPorEmpresa,
      ),
      MenuDeFiltro<int>(
        rotulo: 'Responsável',
        rotuloDeTodos: 'Todos os responsáveis',
        icone: Icones.usuarios,
        opcoes: [
          for (final usuario in ref.watch(usuariosDosFiltrosProvider).value?.itens ?? const <Usuario>[])
            (
              valor: usuario.id,
              rotulo: usuario.situacao == Situacao.ativo ? usuario.nome : '${usuario.nome} (inativo)',
            ),
        ],
        selecionado: filtro.responsavelId,
        aoSelecionar: notifier.filtrarPorResponsavel,
      ),
      MenuDeFiltro<TipoObrigacao>(
        rotulo: 'Tipo',
        rotuloDeTodos: 'Todos os tipos',
        icone: Icones.etiqueta,
        opcoes: [for (final tipo in TipoObrigacao.values) (valor: tipo, rotulo: tipo.rotulo)],
        selecionado: filtro.tipo,
        aoSelecionar: notifier.filtrarPorTipo,
      ),
      MenuDeFiltro<PeriodoDeVencimento>(
        rotulo: 'Vencimento',
        rotuloDeTodos: 'Qualquer data',
        icone: Icones.calendario,
        opcoes: [for (final periodo in PeriodoDeVencimento.values) (valor: periodo, rotulo: periodo.rotulo)],
        selecionado: filtro.periodo,
        aoSelecionar: notifier.filtrarPorPeriodo,
      ),
      if (filtro.temFiltrosAdicionais)
        TextButton.icon(
          onPressed: notifier.limparFiltrosAdicionais,
          icon: const Icone(Icones.limpar, tamanho: TamanhosDeIcone.padrao),
          label: const Text('Limpar filtros'),
        ),
    ];
    final ordenacao = _MenuDeOrdenacao(ordem: filtro.ordem, aoOrdenar: notifier.ordenarPor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, restricoes) => Wrap(
            spacing: Medidas.espacoEntreControles,
            runSpacing: Medidas.espacoEntreControles,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: Medidas.larguraDaBusca(restricoes.maxWidth),
                child: CampoBusca(
                  dica: 'Buscar por título ou descrição',
                  valorInicial: filtro.busca,
                  aoBuscar: notifier.buscar,
                ),
              ),
              ControleSegmentado<StatusObrigacao?>(
                opcoes: [
                  (valor: null, rotulo: 'Todas'),
                  for (final status in StatusObrigacao.values) (valor: status, rotulo: status.rotulo),
                ],
                contagens: contagens,
                selecionado: filtro.status.length == 1 ? filtro.status.single : null,
                aoSelecionar: notifier.filtrarPorStatus,
              ),
              _FiltroDeAtrasadas(
                ativo: filtro.somenteAtrasadas,
                quantidade: filtro.status.isEmpty ? resumo?.atrasadas : null,
                aoAlternar: (ativo) => notifier.mostrarSomenteAtrasadas(ativo: ativo),
              ),
            ],
          ),
        ),
        const SizedBox(height: Medidas.espacoEntreControles),
        if (Medidas.telaEstreita(context))
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final menu in menus)
                  Padding(
                    padding: const EdgeInsets.only(right: Medidas.espacoEntreControles),
                    child: menu,
                  ),
                ordenacao,
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: menus),
              ),
              const SizedBox(width: 16),
              ordenacao,
            ],
          ),
      ],
    );
  }
}

class _FiltroDeAtrasadas extends StatelessWidget {
  const _FiltroDeAtrasadas({required this.ativo, required this.quantidade, required this.aoAlternar});

  final bool ativo;
  final int? quantidade;
  final ValueChanged<bool> aoAlternar;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final quantidade = this.quantidade;
    return BotaoDeAlternancia(
      rotulo: 'Somente atrasadas',
      icone: Icones.statusAtrasada,
      ativo: ativo,
      tom: TomDoFiltro.alerta,
      aoAlternar: aoAlternar,
      contador: quantidade == null || quantidade == 0
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(color: ativo ? cores.sobreForte : cores.erro, borderRadius: Raios.pilula),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                child: Text(
                  '$quantidade',
                  style: Tema.mono(
                    context,
                    tamanho: 11,
                    peso: FontWeight.w600,
                    cor: ativo ? cores.erro : cores.sobreForte,
                  ),
                  semanticsLabel: quantidade == 1 ? '1 atrasada' : '$quantidade atrasadas',
                ),
              ),
            ),
    );
  }
}

class _MenuDeOrdenacao extends StatelessWidget {
  const _MenuDeOrdenacao({required this.ordem, required this.aoOrdenar});

  final OrdemDasObrigacoes ordem;
  final ValueChanged<OrdemDasObrigacoes> aoOrdenar;

  @override
  Widget build(BuildContext context) => MenuAnchor(
    alignmentOffset: const Offset(0, 4),
    menuChildren: [
      for (final opcao in OrdemDasObrigacoes.values)
        ItemDoMenu(rotulo: opcao.rotulo, marcado: opcao == ordem, aoSelecionar: () => aoOrdenar(opcao)),
    ],
    builder: (context, controle, _) => TextButton.icon(
      onPressed: () => controle.isOpen ? controle.close() : controle.open(),
      icon: const Icone(Icones.ordenar, tamanho: TamanhosDeIcone.padrao),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Ordenar: ${ordem.rotulo.toLowerCase()}', semanticsLabel: 'Ordenar por ${ordem.rotulo}'),
          const SizedBox(width: 6),
          const Icone(Icones.expandir, tamanho: TamanhosDeIcone.padrao),
        ],
      ),
    ),
  );
}
