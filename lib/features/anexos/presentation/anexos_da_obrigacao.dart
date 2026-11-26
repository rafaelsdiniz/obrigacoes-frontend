import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/arquivos/arquivos_do_dispositivo.dart';
import '../../../core/formatacao/datas.dart';
import '../../../core/formatacao/tamanhos.dart';
import '../../../core/tema/tema.dart';
import '../../../core/widgets/avisos.dart';
import '../../../core/widgets/cabecalho_do_cartao.dart';
import '../../../core/widgets/erro_em_linha.dart';
import '../../../core/widgets/grupo.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/progresso_no_botao.dart';
import '../domain/anexo.dart';
import '../domain/tipo_de_anexo.dart';
import 'anexos_providers.dart';
import 'area_de_envio.dart';

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

  bool get _ocupado => _escolhendo || _enviando != null;

  Future<void> _escolher() async {
    if (_ocupado) {
      return;
    }
    setState(() => _escolhendo = true);
    try {
      final arquivo = await ref
          .read(arquivosDoDispositivoProvider)
          .escolher(extensoes: TipoDeAnexo.extensoesPermitidas);
      if (arquivo != null && mounted) {
        await _enviar([arquivo]);
      }
    } catch (erro, pilha) {
      if (mounted) {
        avisarFalha(context, erro, pilha);
      }
    } finally {
      if (mounted) {
        setState(() => _escolhendo = false);
      }
    }
  }

  Future<void> _enviar(List<ArquivoEscolhido> arquivos) async {
    if (_enviando != null || arquivos.isEmpty) {
      return;
    }
    var enviados = 0;
    try {
      for (final arquivo in arquivos) {
        if (!mounted) {
          return;
        }
        setState(() => _enviando = arquivo.nome);
        try {
          await _gestao.enviar(widget.obrigacaoId, arquivo);
          enviados++;
        } catch (erro, pilha) {
          if (mounted) {
            avisarFalha(context, erro, pilha);
          }
        }
      }
      if (mounted && enviados > 0) {
        avisarSucesso(context, enviados == 1 ? 'Arquivo anexado.' : '$enviados arquivos anexados.');
      }
    } finally {
      if (mounted) {
        setState(() => _enviando = null);
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
    if (_excluindo.contains(anexo.id)) {
      return;
    }
    final confirmado = await confirmar(
      context,
      titulo: 'Excluir anexo?',
      mensagem: '"${anexo.nome}" será removido desta obrigação.',
      acao: 'Excluir',
    );
    if (!confirmado || !mounted || _excluindo.contains(anexo.id)) {
      return;
    }
    setState(() => _excluindo.add(anexo.id));
    try {
      await _gestao.excluir(widget.obrigacaoId, anexo);
      if (mounted) {
        avisarSucesso(context, 'Anexo excluído.');
      }
    } catch (erro, pilha) {
      if (mounted) {
        avisarFalha(context, erro, pilha);
      }
    } finally {
      if (mounted) {
        setState(() => _excluindo.remove(anexo.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final anexos = ref.watch(anexosDaObrigacaoProvider(widget.obrigacaoId));
    final quantidade = anexos.value?.length;
    return Grupo(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CabecalhoDoCartao(
            titulo: 'Anexos',
            detalhe: switch (quantidade) {
              null || 0 => null,
              1 => '1 arquivo',
              _ => '$quantidade arquivos',
            },
            acao: OutlinedButton.icon(
              onPressed: _ocupado ? null : () => unawaited(_escolher()),
              icon: const Icone(Icones.anexar, tamanho: TamanhosDeIcone.padrao),
              label: const Text('Anexar arquivo'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AreaDeEnvio(
                  enviando: _enviando,
                  habilitada: !_ocupado,
                  aoEscolher: () => unawaited(_escolher()),
                  aoSoltar: (arquivos) => unawaited(_enviar(arquivos)),
                ),
                const SizedBox(height: 12),
                anexos.when(
                  loading: () => const LinearProgressIndicator(semanticsLabel: 'Carregando anexos'),
                  error: (erro, _) => ErroEmLinha(
                    erro: erro,
                    aoTentarNovamente: () => ref.invalidate(anexosDaObrigacaoProvider(widget.obrigacaoId)),
                  ),
                  data: (lista) => lista.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Nenhum arquivo anexado.', textAlign: TextAlign.center, style: tema.bodySmall),
                        )
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
          ),
        ],
      ),
    );
  }
}

extension on TipoDeAnexo {
  Icones get icone => switch (this) {
    TipoDeAnexo.pdf => Icones.arquivoPdf,
    TipoDeAnexo.png || TipoDeAnexo.jpeg => Icones.arquivoImagem,
    TipoDeAnexo.xml => Icones.arquivoXml,
    TipoDeAnexo.csv || TipoDeAnexo.xlsx => Icones.arquivoPlanilha,
    TipoDeAnexo.docx => Icones.arquivoTexto,
    TipoDeAnexo.outro => Icones.arquivo,
  };
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
            decoration: BoxDecoration(color: context.cores.superficie, borderRadius: Raios.controle),
            child: SizedBox.square(
              dimension: 40,
              child: Center(
                child: Icone(anexo.tipo.icone, tamanho: TamanhosDeIcone.grande, cor: context.cores.primaria),
              ),
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
            icon: const Icone(Icones.baixar, tamanho: TamanhosDeIcone.grande),
          ),
          if (aoExcluir != null)
            IconButton(
              tooltip: 'Excluir ${anexo.nome}',
              onPressed: excluindo ? null : aoExcluir,
              icon: excluindo
                  ? const ProgressoNoBotao(rotulo: 'Excluindo')
                  : const Icone(Icones.excluir, tamanho: TamanhosDeIcone.grande),
            ),
        ],
      ),
    );
  }
}
