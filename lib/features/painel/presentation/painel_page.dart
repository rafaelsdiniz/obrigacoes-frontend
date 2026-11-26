import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/layout/medidas.dart';
import '../../../core/widgets/cabecalho_de_pagina.dart';
import '../../../core/widgets/conteudo_centralizado.dart';
import '../../../core/widgets/estado_carregando.dart';
import '../../../core/widgets/estado_erro.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../core/widgets/grupo.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/indicador.dart';
import '../../../core/widgets/marca.dart';
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
    final tema = Theme.of(context).textTheme;
    return ConteudoCentralizado(
      larguraMaxima: Medidas.larguraMaximaDaListagem,
      children: [
        if (!Medidas.telaLarga(context)) ...[const Marca(altura: 28), const SizedBox(height: 20)],
        const CabecalhoDePagina(titulo: 'Painel', subtitulo: 'Visão geral das obrigações do escritório'),
        const SizedBox(height: 28),
        ref
            .watch(resumoDasObrigacoesProvider)
            .when(
              loading: () => const SizedBox(height: 160, child: EstadoCarregando()),
              error: (erro, _) => Grupo(
                child: EstadoErro(erro: erro, aoTentarNovamente: () => ref.invalidate(resumoDasObrigacoesProvider)),
              ),
              data: (resumo) => _Indicadores(resumo),
            ),
        const SizedBox(height: 36),
        Semantics(header: true, child: Text('Próximos vencimentos', style: tema.titleLarge)),
        const SizedBox(height: 4),
        Text('Obrigações em aberto com vencimento a partir de hoje', style: tema.bodySmall),
        const SizedBox(height: 16),
        ref
            .watch(proximosVencimentosProvider)
            .when(
              loading: () => const SizedBox(height: 160, child: EstadoCarregando()),
              error: (erro, _) => Grupo(
                child: EstadoErro(erro: erro, aoTentarNovamente: () => ref.invalidate(proximosVencimentosProvider)),
              ),
              data: (pagina) => Grupo(
                child: pagina.vazia
                    ? const EstadoVazio(
                        icone: Icones.vazio,
                        titulo: 'Nada para os próximos dias',
                        mensagem: 'Não há obrigações em aberto com vencimento futuro.',
                      )
                    : Column(
                        children: [
                          for (final (indice, obrigacao) in pagina.itens.indexed) ...[
                            if (indice > 0) const Divider(indent: 20, endIndent: 20),
                            LinhaDeObrigacao(obrigacao),
                          ],
                        ],
                      ),
              ),
            ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              ref.read(filtroObrigacoesProvider.notifier).exibir();
              context.go(RotasObrigacoes.lista);
            },
            child: const Text('Ver todas as obrigações'),
          ),
        ),
      ],
    );
  }
}

class _Indicadores extends ConsumerWidget {
  const _Indicadores(this.resumo);

  static const _espacamento = 16.0;
  static const _larguraMinimaDoCartao = 160.0;

  final ResumoObrigacoes resumo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void abrirLista({StatusObrigacao? status, bool somenteAtrasadas = false}) {
      ref.read(filtroObrigacoesProvider.notifier).exibir(status: status, somenteAtrasadas: somenteAtrasadas);
      context.go(RotasObrigacoes.lista);
    }

    final cartoes = [
      CartaoDeIndicador(
        rotulo: 'Pendentes',
        quantidade: resumo.pendentes,
        icone: Icones.statusPendente,
        tom: TomDoIndicador.atencao,
        aoAbrir: () => abrirLista(status: StatusObrigacao.pendente),
      ),
      CartaoDeIndicador(
        rotulo: 'Em andamento',
        quantidade: resumo.emAndamento,
        icone: Icones.statusEmAndamento,
        tom: TomDoIndicador.informacao,
        aoAbrir: () => abrirLista(status: StatusObrigacao.emAndamento),
      ),
      CartaoDeIndicador(
        rotulo: 'Atrasadas',
        quantidade: resumo.atrasadas,
        icone: Icones.statusAtrasada,
        tom: TomDoIndicador.erro,
        destacarQuandoMaiorQueZero: true,
        aoAbrir: () => abrirLista(somenteAtrasadas: true),
      ),
      CartaoDeIndicador(
        rotulo: 'Concluídas',
        quantidade: resumo.concluidas,
        icone: Icones.statusConcluida,
        tom: TomDoIndicador.sucesso,
        aoAbrir: () => abrirLista(status: StatusObrigacao.concluida),
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
