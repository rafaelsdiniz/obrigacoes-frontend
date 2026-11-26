import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/tema/tema.dart';
import '../../../core/widgets/cabecalho_de_colunas.dart';
import '../../../core/widgets/campo_busca.dart';
import '../../../core/widgets/controle_segmentado.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/lista_paginada.dart';
import '../../../core/widgets/pagina_de_listagem.dart';
import '../domain/filtro_obrigacoes.dart';
import '../domain/obrigacao.dart';
import '../domain/status_obrigacao.dart';
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
        cabecalho: const CabecalhoDeColunas(
          titulo: 'Obrigação',
          detalhes: ['Empresa', 'Responsável', 'Vencimento'],
          situacao: 'Status',
        ),
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

class _Filtros extends StatelessWidget {
  const _Filtros({required this.filtro, required this.notifier});

  final FiltroObrigacoes filtro;
  final FiltroObrigacoesNotifier notifier;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 12,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
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
        selecionado: filtro.status.length == 1 ? filtro.status.single : null,
        aoSelecionar: notifier.filtrarPorStatus,
      ),
      FilterChip(
        label: const Text('Somente atrasadas'),
        avatar: Icone(
          Icones.statusAtrasada,
          tamanho: 16,
          cor: filtro.somenteAtrasadas ? Cores.erro : Cores.textoSecundario,
        ),
        showCheckmark: false,
        selected: filtro.somenteAtrasadas,
        selectedColor: Cores.erroSuave,
        side: const BorderSide(color: Cores.separador),
        shape: const StadiumBorder(),
        onSelected: (ativo) => notifier.mostrarSomenteAtrasadas(ativo: ativo),
      ),
    ],
  );
}
