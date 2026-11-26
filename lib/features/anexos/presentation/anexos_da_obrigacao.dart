import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/arquivos/arquivos_do_dispositivo.dart';
import '../../../core/formatacao/datas.dart';
import '../../../core/formatacao/tamanhos.dart';
import '../../../core/http/erro_api.dart';
import '../../../core/tema/tema.dart';
import '../../../core/widgets/avisos.dart';
import '../../../core/widgets/grupo.dart';
import '../../../core/widgets/icone.dart';
import '../domain/anexo.dart';
import '../domain/tipo_de_anexo.dart';
import 'anexos_providers.dart';

class AnexosDaObrigacao extends ConsumerStatefulWidget {
  const AnexosDaObrigacao({required this.obrigacaoId, required this.permiteExcluir, super.key});

  final int obrigacaoId;
  final bool permiteExcluir;

  @override
  ConsumerState<AnexosDaObrigacao> createState() => _AnexosDaObrigacaoState();
}

class _AnexosDaObrigacaoState extends ConsumerState<AnexosDaObrigacao> {
  bool _escolhendo = false;
  String? _enviando;
  final _baixando = <int>{};
  final _excluindo = <int>{};

  GestaoDeAnexos get _gestao => ref.read(gestaoDeAnexosProvider);

  Future<void> _anexar() async {
    if (_escolhendo || _enviando != null) {
      return;
    }
    setState(() => _escolhendo = true);
    try {
      final arquivo = await ref
          .read(arquivosDoDispositivoProvider)
          .escolher(extensoes: TipoDeAnexo.extensoesPermitidas);
      if (arquivo == null || !mounted) {
        return;
      }
      setState(() {
        _escolhendo = false;
        _enviando = arquivo.nome;
      });
      await _gestao.enviar(widget.obrigacaoId, arquivo);
      if (mounted) {
        avisarSucesso(context, 'Arquivo anexado.');
      }
    } catch (erro, pilha) {
      if (mounted) {
        avisarFalha(context, erro, pilha);
      }
    } finally {
      if (mounted) {
        setState(() {
          _escolhendo = false;
          _enviando = null;
        });
      }
    }
  }

  Future<void> _baixar(Anexo anexo) async {
    if (!_baixando.add(anexo.id)) {
      return;
    }
    try {
      await _gestao.baixar(widget.obrigacaoId, anexo);
    } catch (erro, pilha) {
      if (mounted) {
        avisarFalha(context, erro, pilha);
      }
    } finally {
      _baixando.remove(anexo.id);
    }
  }

  Future<void> _excluir(Anexo anexo) async {
    if (!_excluindo.add(anexo.id)) {
      return;
    }
    try {
      final confirmado = await confirmar(
        context,
        titulo: 'Excluir anexo?',
        mensagem: '"${anexo.nome}" será removido desta obrigação.',
        acao: 'Excluir',
      );
      if (!confirmado || !mounted) {
        return;
      }
      setState(() {});
      await _gestao.excluir(widget.obrigacaoId, anexo);
      if (mounted) {
        avisarSucesso(context, 'Anexo excluído.');
      }
    } catch (erro, pilha) {
      if (mounted) {
        avisarFalha(context, erro, pilha);
      }
    } finally {
      _excluindo.remove(anexo.id);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final anexos = ref.watch(anexosDaObrigacaoProvider(widget.obrigacaoId));
    final enviando = _enviando;
    return Grupo(
      preenchimento: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Semantics(header: true, child: Text('Anexos', style: tema.titleMedium)),
              TextButton.icon(
                onPressed: enviando == null && !_escolhendo ? () => unawaited(_anexar()) : null,
                icon: const Icone(Icones.anexar, tamanho: 18),
                label: const Text('Anexar arquivo'),
              ),
            ],
          ),
          Text(
            'PDF, imagens, XML, CSV, planilhas e documentos de até ${Tamanhos.formatar(Anexo.tamanhoMaximo)}.',
            style: tema.bodySmall,
          ),
          const SizedBox(height: 16),
          if (enviando != null) _Envio(nome: enviando),
          anexos.when(
            loading: () => const LinearProgressIndicator(semanticsLabel: 'Carregando anexos'),
            error: (erro, _) => Row(
              children: [
                Expanded(
                  child: Semantics(liveRegion: true, child: Text(ErroApi.mensagemPara(erro), style: tema.bodySmall)),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(anexosDaObrigacaoProvider(widget.obrigacaoId)),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
            data: (lista) => lista.isEmpty && enviando == null
                ? Text('Nenhum arquivo anexado.', style: tema.bodyMedium?.copyWith(color: Cores.textoSecundario))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (indice, anexo) in lista.indexed) ...[
                        if (indice > 0) const Divider(),
                        _ItemDoAnexo(
                          anexo: anexo,
                          excluindo: _excluindo.contains(anexo.id),
                          aoBaixar: () => unawaited(_baixar(anexo)),
                          aoExcluir: widget.permiteExcluir ? () => unawaited(_excluir(anexo)) : null,
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Envio extends StatelessWidget {
  const _Envio({required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Enviando $nome…', style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          const LinearProgressIndicator(),
        ],
      ),
    ),
  );
}

class _ItemDoAnexo extends StatelessWidget {
  const _ItemDoAnexo({required this.anexo, required this.excluindo, required this.aoBaixar, this.aoExcluir});

  final Anexo anexo;
  final bool excluindo;
  final VoidCallback aoBaixar;
  final VoidCallback? aoExcluir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final aoExcluir = this.aoExcluir;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(color: Cores.preenchimento, borderRadius: Raios.pequeno),
            child: SizedBox.square(
              dimension: 40,
              child: Center(child: Icone(anexo.tipo.icone, tamanho: 20, cor: Cores.grafite)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anexo.nome,
                  style: tema.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    anexo.tipo.rotulo,
                    Tamanhos.formatar(anexo.tamanho),
                    Datas.formatarComHora(anexo.enviadoEm),
                  ].join('  ·  '),
                  style: tema.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Baixar ${anexo.nome}',
            onPressed: aoBaixar,
            icon: const Icone(Icones.baixar, tamanho: 20),
          ),
          if (aoExcluir != null)
            IconButton(
              tooltip: 'Excluir ${anexo.nome}',
              onPressed: excluindo ? null : aoExcluir,
              icon: excluindo
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, semanticsLabel: 'Excluindo'),
                    )
                  : const Icone(Icones.excluir, tamanho: 20),
            ),
        ],
      ),
    );
  }
}
