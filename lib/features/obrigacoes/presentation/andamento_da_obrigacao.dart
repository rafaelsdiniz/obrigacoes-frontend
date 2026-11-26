import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/formatacao/datas.dart';
import '../../../core/tema/tema.dart';
import '../../../core/widgets/cabecalho_do_cartao.dart';
import '../../../core/widgets/erro_em_linha.dart';
import '../../../core/widgets/grupo.dart';
import '../../../core/widgets/icone.dart';
import '../domain/historico_de_status.dart';
import '../domain/obrigacao.dart';
import '../domain/status_obrigacao.dart';
import 'indicador_de_status.dart';
import 'obrigacoes_providers.dart';

enum _SituacaoDaEtapa { cumprida, atual, futura }

class EtapasDoFluxo extends ConsumerWidget {
  const EtapasDoFluxo(this.obrigacao, {super.key});

  static const _larguraParaLinha = 640.0;

  final Obrigacao obrigacao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transicoes = ref.watch(historicoDaObrigacaoProvider(obrigacao.id)).value ?? const <TransicaoDeStatus>[];
    final etapas = [
      for (final status in StatusObrigacao.values)
        _Etapa(
          status: status,
          situacao: _situacaoDa(status),
          alcancadaEm: transicoes.where((transicao) => transicao.statusNovo == status).firstOrNull?.alteradoEm,
        ),
    ];
    return Semantics(
      container: true,
      label: 'Andamento da obrigação',
      child: Grupo(
        preenchimento: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: LayoutBuilder(
          builder: (context, restricoes) {
            if (restricoes.maxWidth < MediaQuery.textScalerOf(context).scale(_larguraParaLinha)) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (indice, etapa) in etapas.indexed) ...[if (indice > 0) const SizedBox(height: 12), etapa],
                ],
              );
            }
            return Row(
              children: [
                for (final (indice, etapa) in etapas.indexed) ...[
                  if (indice > 0)
                    Expanded(
                      child: _Ligacao(cumprida: _situacaoDa(StatusObrigacao.values[indice]) != _SituacaoDaEtapa.futura),
                    ),
                  etapa,
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  _SituacaoDaEtapa _situacaoDa(StatusObrigacao status) {
    if (status.index < obrigacao.status.index || obrigacao.concluida) {
      return _SituacaoDaEtapa.cumprida;
    }
    return status == obrigacao.status ? _SituacaoDaEtapa.atual : _SituacaoDaEtapa.futura;
  }
}

class _Ligacao extends StatelessWidget {
  const _Ligacao({required this.cumprida});

  final bool cumprida;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(height: 2, color: cumprida ? context.cores.sucesso : context.cores.contornoVariante),
  );
}

class _Etapa extends StatelessWidget {
  const _Etapa({required this.status, required this.situacao, required this.alcancadaEm});

  final StatusObrigacao status;
  final _SituacaoDaEtapa situacao;
  final DateTime? alcancadaEm;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final tema = Theme.of(context).textTheme;
    final alcancadaEm = this.alcancadaEm;
    final (descricao, detalhe) = switch (situacao) {
      _SituacaoDaEtapa.cumprida => ('etapa cumprida', null),
      _SituacaoDaEtapa.atual => ('etapa atual', null),
      _SituacaoDaEtapa.futura => ('próxima etapa', 'Próxima etapa'),
    };
    final marcador = switch (situacao) {
      _SituacaoDaEtapa.cumprida => DecoratedBox(
        decoration: BoxDecoration(color: cores.sucesso, shape: BoxShape.circle),
        child: Center(
          child: Icone(Icones.marcado, tamanho: TamanhosDeIcone.padrao, cor: cores.sobreForte),
        ),
      ),
      _SituacaoDaEtapa.atual => DecoratedBox(
        decoration: BoxDecoration(color: status.tom.forte(cores), shape: BoxShape.circle),
        child: Center(
          child: Icone(status.icone, tamanho: TamanhosDeIcone.padrao, cor: status.tom.sobreForte(cores)),
        ),
      ),
      _SituacaoDaEtapa.futura => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: cores.contornoVariante, width: 1.5),
        ),
        child: Center(
          child: Icone(status.icone, tamanho: TamanhosDeIcone.padrao, cor: cores.textoVariante),
        ),
      ),
    };
    return Semantics(
      container: true,
      label: '${status.rotulo}, $descricao',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(dimension: 36, child: marcador),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.rotulo,
                  style: tema.titleSmall?.copyWith(
                    color: situacao == _SituacaoDaEtapa.futura ? cores.textoVariante : cores.texto,
                  ),
                ),
                if (alcancadaEm != null && situacao != _SituacaoDaEtapa.futura)
                  Text(Datas.formatarCurtoComHora(alcancadaEm), style: Tema.mono(context, cor: cores.textoVariante))
                else if (detalhe != null)
                  Text(detalhe, style: tema.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoricoDaObrigacao extends ConsumerWidget {
  const HistoricoDaObrigacao(this.obrigacao, {super.key});

  final Obrigacao obrigacao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historico = ref.watch(historicoDaObrigacaoProvider(obrigacao.id));
    return Grupo(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CabecalhoDoCartao(titulo: 'Histórico', icone: Icones.historico),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: historico.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(semanticsLabel: 'Carregando histórico'),
              ),
              error: (erro, _) => ErroEmLinha(
                erro: erro,
                aoTentarNovamente: () => ref.invalidate(historicoDaObrigacaoProvider(obrigacao.id)),
              ),
              data: (transicoes) {
                final ordenadas = transicoes.reversed.toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (indice, transicao) in ordenadas.indexed)
                      _ItemDoHistorico(transicao, maisRecente: indice == 0, ultimo: indice == ordenadas.length - 1),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemDoHistorico extends StatelessWidget {
  const _ItemDoHistorico(this.transicao, {required this.maisRecente, required this.ultimo});

  final TransicaoDeStatus transicao;
  final bool maisRecente;
  final bool ultimo;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final tema = Theme.of(context).textTheme;
    final anterior = transicao.statusAnterior;
    final (titulo, detalhe) = switch ((anterior, transicao.statusNovo)) {
      (null, final novo) => ('Obrigação cadastrada', 'Status inicial ${novo.rotulo}'),
      (final de?, StatusObrigacao.concluida) => ('Concluída', '${de.rotulo} → ${StatusObrigacao.concluida.rotulo}'),
      (final de?, final novo) => ('Iniciada', '${de.rotulo} → ${novo.rotulo}'),
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 14,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: maisRecente ? cores.primaria : cores.superficieMaisBaixa,
                    border: Border.all(color: maisRecente ? cores.primaria : cores.contorno, width: 1.5),
                  ),
                ),
                if (!ultimo) Expanded(child: Container(width: 1.5, color: cores.contornoVariante)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: tema.titleSmall),
                  Text(detalhe, style: tema.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    Datas.formatarCurtoComHora(transicao.alteradoEm),
                    style: Tema.mono(context, cor: cores.textoVariante),
                    semanticsLabel: Datas.formatarComHora(transicao.alteradoEm),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
