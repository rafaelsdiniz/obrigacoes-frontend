import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/formatacao/datas.dart';
import '../../../core/http/erro_api.dart';
import '../../../core/tema/tema.dart';
import '../../../core/widgets/grupo.dart';
import '../../../core/widgets/icone.dart';
import '../domain/historico_de_status.dart';
import '../domain/obrigacao.dart';
import '../domain/status_obrigacao.dart';
import 'obrigacoes_providers.dart';

class AndamentoDaObrigacao extends ConsumerWidget {
  const AndamentoDaObrigacao(this.obrigacao, {super.key});

  final Obrigacao obrigacao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context).textTheme;
    final historico = ref.watch(historicoDaObrigacaoProvider(obrigacao.id));
    return Grupo(
      preenchimento: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text('Andamento', style: tema.titleMedium)),
          const SizedBox(height: 16),
          for (final status in StatusObrigacao.values) _Etapa(status: status, situacao: _situacaoDa(status)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icone(Icones.historico, tamanho: 18, cor: Cores.textoSecundario),
              const SizedBox(width: 8),
              Text('HISTÓRICO', style: tema.labelMedium),
            ],
          ),
          const SizedBox(height: 12),
          historico.when(
            loading: () => const LinearProgressIndicator(),
            error: (erro, _) => Row(
              children: [
                Expanded(child: Text(ErroApi.mensagemPara(erro), style: tema.bodySmall)),
                TextButton(
                  onPressed: () => ref.invalidate(historicoDaObrigacaoProvider(obrigacao.id)),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
            data: (transicoes) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final transicao in transicoes.reversed) _ItemDoHistorico(transicao)],
            ),
          ),
        ],
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

enum _SituacaoDaEtapa { cumprida, atual, futura }

class _Etapa extends StatelessWidget {
  const _Etapa({required this.status, required this.situacao});

  final StatusObrigacao status;
  final _SituacaoDaEtapa situacao;

  @override
  Widget build(BuildContext context) {
    final (icone, cor, descricao) = switch (situacao) {
      _SituacaoDaEtapa.cumprida => (Icones.situacaoAtiva, Cores.sucesso, 'etapa cumprida'),
      _SituacaoDaEtapa.atual => (Icones.statusEmAndamento, Cores.informacao, 'etapa atual'),
      _SituacaoDaEtapa.futura => (Icones.statusPendente, Cores.textoSecundario, 'próxima etapa'),
    };
    return Semantics(
      label: '${status.rotulo}, $descricao',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icone(icone, tamanho: 20, cor: cor),
            const SizedBox(width: 12),
            Text(
              status.rotulo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: situacao == _SituacaoDaEtapa.atual ? FontWeight.w600 : null,
                color: situacao == _SituacaoDaEtapa.futura ? Cores.textoSecundario : Cores.texto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemDoHistorico extends StatelessWidget {
  const _ItemDoHistorico(this.transicao);

  final TransicaoDeStatus transicao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final anterior = transicao.statusAnterior;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            anterior == null ? 'Obrigação cadastrada' : '${anterior.rotulo} → ${transicao.statusNovo.rotulo}',
            style: tema.bodyMedium,
          ),
          Text(Datas.formatarComHora(transicao.alteradoEm), style: tema.bodySmall),
        ],
      ),
    );
  }
}
