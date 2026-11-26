import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/http/pagina.dart';
import '../../../core/layout/medidas.dart';
import '../../../core/tema/tema.dart';
import '../../../core/widgets/botao_de_acao.dart';
import '../../../core/widgets/cabecalho_de_pagina.dart';
import '../../../core/widgets/conteudo_centralizado.dart';
import '../../../core/widgets/estado_carregando.dart';
import '../../../core/widgets/estado_erro.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../core/widgets/grupo.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/indicador.dart';
import '../../obrigacoes/domain/obrigacao.dart';
import '../../obrigacoes/domain/resumo_obrigacoes.dart';
import '../../obrigacoes/domain/status_obrigacao.dart';
import '../../obrigacoes/presentation/linha_de_obrigacao.dart';
import '../../obrigacoes/presentation/obrigacoes_providers.dart';
import '../../obrigacoes/presentation/rotas_obrigacoes.dart';
import 'cartao_de_indicador.dart';

class PainelPage extends ConsumerWidget {
  const PainelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void abrirLista({StatusObrigacao? status, bool somenteAtrasadas = false}) {
      ref.read(filtroObrigacoesProvider.notifier).exibir(status: status, somenteAtrasadas: somenteAtrasadas);
      context.go(RotasObrigacoes.lista);
    }

    final atrasadas = ref.watch(obrigacoesAtrasadasProvider);
    final temAtrasadas = atrasadas.value?.vazia == false;
    return ConteudoCentralizado(
      children: [
        CabecalhoDePagina(
          titulo: 'Painel',
          subtitulo: 'Visão geral das obrigações do escritório',
          acoes: [
            BotaoDeAcao(
              rotulo: 'Nova obrigação',
              icone: Icones.adicionar,
              aoPressionar: () => context.go(RotasObrigacoes.nova),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ref
            .watch(resumoDasObrigacoesProvider)
            .when(
              loading: () => const SizedBox(height: 160, child: EstadoCarregando()),
              error: (erro, _) => Grupo(
                child: EstadoErro(erro: erro, aoTentarNovamente: () => ref.invalidate(resumoDasObrigacoesProvider)),
              ),
              data: (resumo) => _Indicadores(resumo, aoAbrir: abrirLista),
            ),
        if (temAtrasadas) ...[
          const SizedBox(height: 32),
          _CabecalhoDeSecao(
            titulo: 'Requer atenção',
            subtitulo: 'Obrigações vencidas que ainda não foram concluídas',
            alerta: true,
            acao: 'Ver atrasadas',
            aoAcionar: () => abrirLista(somenteAtrasadas: true),
          ),
          const SizedBox(height: 16),
          _ListaDeObrigacoes(
            atrasadas,
            aoTentarNovamente: () => ref.invalidate(obrigacoesAtrasadasProvider),
            vazio: const SizedBox.shrink(),
          ),
        ],
        const SizedBox(height: 32),
        _CabecalhoDeSecao(
          titulo: 'Próximos vencimentos',
          subtitulo: 'Obrigações em aberto com vencimento a partir de hoje',
          acao: 'Ver todas as obrigações',
          aoAcionar: () => abrirLista(),
        ),
        const SizedBox(height: 16),
        _ListaDeObrigacoes(
          ref.watch(proximosVencimentosProvider),
          aoTentarNovamente: () => ref.invalidate(proximosVencimentosProvider),
          vazio: const EstadoVazio(
            icone: Icones.vazio,
            titulo: 'Nada para os próximos dias',
            mensagem: 'Não há obrigações em aberto com vencimento futuro.',
          ),
        ),
      ],
    );
  }
}

class _CabecalhoDeSecao extends StatelessWidget {
  const _CabecalhoDeSecao({
    required this.titulo,
    required this.subtitulo,
    required this.acao,
    required this.aoAcionar,
    this.alerta = false,
  });

  final String titulo;
  final String subtitulo;
  final String acao;
  final VoidCallback aoAcionar;
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final cor = alerta ? context.cores.erro : null;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 16,
      runSpacing: 4,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (alerta) ...[
                    Icone(Icones.statusAtrasada, tamanho: TamanhosDeIcone.grande, cor: cor),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(titulo, style: tema.titleLarge?.copyWith(color: cor)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitulo, style: tema.bodySmall),
          ],
        ),
        TextButton.icon(
          onPressed: aoAcionar,
          iconAlignment: IconAlignment.end,
          icon: const Icone(Icones.avancar, tamanho: TamanhosDeIcone.padrao),
          label: Text(acao),
        ),
      ],
    );
  }
}

class _ListaDeObrigacoes extends StatelessWidget {
  const _ListaDeObrigacoes(this.estado, {required this.aoTentarNovamente, required this.vazio});

  final AsyncValue<Pagina<Obrigacao>> estado;
  final VoidCallback aoTentarNovamente;
  final Widget vazio;

  @override
  Widget build(BuildContext context) => estado.when(
    loading: () => const SizedBox(height: 160, child: EstadoCarregando()),
    error: (erro, _) => Grupo(
      child: EstadoErro(erro: erro, aoTentarNovamente: aoTentarNovamente),
    ),
    data: (pagina) => pagina.vazia
        ? Grupo(child: vazio)
        : Grupo(
            child: LayoutBuilder(
              builder: (context, restricoes) => Column(
                children: [
                  if (restricoes.maxWidth >= Medidas.larguraParaColunas) const CabecalhoDeObrigacoes(),
                  for (final (indice, obrigacao) in pagina.itens.indexed) ...[
                    if (indice > 0) const Divider(),
                    LinhaDeObrigacao(obrigacao),
                  ],
                ],
              ),
            ),
          ),
  );
}

class _Indicadores extends StatelessWidget {
  const _Indicadores(this.resumo, {required this.aoAbrir});

  static const _espacamento = 16.0;
  static const _larguraMinimaDoCartao = 160.0;

  final ResumoObrigacoes resumo;
  final void Function({StatusObrigacao? status, bool somenteAtrasadas}) aoAbrir;

  @override
  Widget build(BuildContext context) {
    final total = resumo.pendentes + resumo.emAndamento + resumo.concluidas;
    final percentual = total == 0 ? 0 : (resumo.concluidas * 100 / total).round();
    final cartoes = [
      CartaoDeIndicador(
        rotulo: 'Pendentes',
        quantidade: resumo.pendentes,
        icone: Icones.statusPendente,
        tom: TomDoIndicador.atencao,
        contexto: 'Aguardando início',
        aoAbrir: () => aoAbrir(status: StatusObrigacao.pendente),
      ),
      CartaoDeIndicador(
        rotulo: 'Em andamento',
        quantidade: resumo.emAndamento,
        icone: Icones.statusEmAndamento,
        tom: TomDoIndicador.informacao,
        contexto: 'Sendo executadas pela equipe',
        aoAbrir: () => aoAbrir(status: StatusObrigacao.emAndamento),
      ),
      CartaoDeIndicador(
        rotulo: 'Atrasadas',
        quantidade: resumo.atrasadas,
        icone: Icones.statusAtrasada,
        tom: TomDoIndicador.erro,
        contexto: resumo.atrasadas > 0 ? 'Exigem ação imediata' : 'Nenhuma pendência vencida',
        destacarQuandoMaiorQueZero: true,
        aoAbrir: () => aoAbrir(somenteAtrasadas: true),
      ),
      CartaoDeIndicador(
        rotulo: 'Concluídas',
        quantidade: resumo.concluidas,
        icone: Icones.statusConcluida,
        tom: TomDoIndicador.sucesso,
        contexto: '$percentual% de todas as obrigações',
        aoAbrir: () => aoAbrir(status: StatusObrigacao.concluida),
      ),
    ];
    return LayoutBuilder(
      builder: (context, restricoes) {
        final larguraMinima = MediaQuery.textScalerOf(context).scale(_larguraMinimaDoCartao);
        final cabem = ((restricoes.maxWidth + _espacamento) / (larguraMinima + _espacamento)).floor();
        final colunas = cabem >= 4
            ? 4
            : cabem >= 2
            ? 2
            : 1;
        final largura = (restricoes.maxWidth - _espacamento * (colunas - 1)) / colunas;
        return Wrap(
          spacing: _espacamento,
          runSpacing: _espacamento,
          children: [for (final cartao in cartoes) SizedBox(width: largura, child: cartao)],
        );
      },
    );
  }
}
