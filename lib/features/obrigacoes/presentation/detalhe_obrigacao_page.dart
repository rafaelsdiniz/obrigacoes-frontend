import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/formatacao/cnpj.dart';
import '../../../core/formatacao/datas.dart';
import '../../../core/http/erro_api.dart';
import '../../../core/layout/medidas.dart';
import '../../../core/tema/tema.dart';
import '../../../core/widgets/avisos.dart';
import '../../../core/widgets/cabecalho_de_pagina.dart';
import '../../../core/widgets/conteudo_centralizado.dart';
import '../../../core/widgets/grupo.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/registro_com_carregamento.dart';
import '../domain/obrigacao.dart';
import '../domain/prazo.dart';
import '../domain/status_obrigacao.dart';
import 'andamento_da_obrigacao.dart';
import 'indicador_de_status.dart';
import 'obrigacoes_providers.dart';
import 'rotas_obrigacoes.dart';
import 'texto_do_prazo.dart';

class DetalheObrigacaoPage extends ConsumerWidget {
  const DetalheObrigacaoPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => RegistroComCarregamento<Obrigacao>(
    titulo: 'Obrigação',
    registro: ref.watch(obrigacaoProvider(id)),
    aoTentarNovamente: () => ref.invalidate(obrigacaoProvider(id)),
    aoVoltar: () => context.go(RotasObrigacoes.lista),
    builder: (obrigacao) => _Detalhe(obrigacao),
  );
}

class _Detalhe extends ConsumerStatefulWidget {
  const _Detalhe(this.obrigacao);

  final Obrigacao obrigacao;

  @override
  ConsumerState<_Detalhe> createState() => _DetalheState();
}

class _DetalheState extends ConsumerState<_Detalhe> {
  bool _ocupado = false;
  bool _avancando = false;

  Future<void> _avancar(StatusObrigacao proximo) async {
    if (_ocupado) {
      return;
    }
    _ocupado = true;
    try {
      if (proximo == StatusObrigacao.concluida && !await _confirmarConclusao()) {
        return;
      }
      setState(() => _avancando = true);
      await ref.read(cadastroDeObrigacoesProvider).avancarStatus(widget.obrigacao, proximo);
      if (mounted) {
        avisarSucesso(context, 'Obrigação ${proximo == StatusObrigacao.concluida ? 'concluída' : 'iniciada'}.');
      }
    } catch (erro, pilha) {
      if (_statusMudouNoServidor(erro)) {
        ref
          ..invalidate(obrigacaoProvider(widget.obrigacao.id))
          ..invalidate(historicoDaObrigacaoProvider(widget.obrigacao.id));
      }
      if (mounted) {
        avisarFalha(context, erro, pilha);
      }
    } finally {
      _ocupado = false;
      if (mounted) {
        setState(() => _avancando = false);
      }
    }
  }

  static bool _statusMudouNoServidor(Object erro) =>
      erro is ErroApi && (erro.codigo == CodigoErro.conflito || erro.codigo == CodigoErro.regraNegocio);

  Future<bool> _confirmarConclusao() async =>
      await confirmar(
        context,
        titulo: 'Concluir obrigação?',
        mensagem: 'Depois de concluída, a obrigação não poderá mais ser editada nem mudar de status.',
        acao: 'Concluir',
      ) &&
      mounted;

  @override
  Widget build(BuildContext context) {
    final obrigacao = widget.obrigacao;
    final proximo = obrigacao.proximoStatus;
    final estreita = Medidas.telaEstreita(context);
    final competencia = obrigacao.competencia;
    return ConteudoCentralizado(
      children: [
        CabecalhoDePagina(
          titulo: obrigacao.titulo,
          subtitulo: [obrigacao.tipo.rotulo, if (competencia != null) 'Competência $competencia'].join('  ·  '),
          aoVoltar: () => context.go(RotasObrigacoes.lista),
          acoes: [
            if (!obrigacao.concluida)
              IconButton(
                tooltip: 'Editar',
                onPressed: () => context.go(RotasObrigacoes.edicao(obrigacao.id)),
                icon: const Icone(Icones.editar, tamanho: 20),
              ),
            if (proximo != null && !estreita)
              _BotaoDeAvanco(proximo: proximo, avancando: _avancando, aoAvancar: _avancar),
          ],
        ),
        if (proximo != null && estreita) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: _BotaoDeAvanco(proximo: proximo, avancando: _avancando, aoAvancar: _avancar),
          ),
        ],
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, restricoes) {
            final dados = _DadosDaObrigacao(obrigacao);
            final andamento = AndamentoDaObrigacao(obrigacao);
            if (restricoes.maxWidth < Medidas.larguraParaColunas) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [dados, const SizedBox(height: 20), andamento],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: dados),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: andamento),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BotaoDeAvanco extends StatelessWidget {
  const _BotaoDeAvanco({required this.proximo, required this.avancando, required this.aoAvancar});

  final StatusObrigacao proximo;
  final bool avancando;
  final Future<void> Function(StatusObrigacao) aoAvancar;

  @override
  Widget build(BuildContext context) {
    final concluir = proximo == StatusObrigacao.concluida;
    return FilledButton.icon(
      onPressed: () => unawaited(aoAvancar(proximo)),
      icon: avancando
          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icone(concluir ? Icones.statusConcluida : Icones.statusEmAndamento, tamanho: 18),
      label: Text(concluir ? 'Concluir obrigação' : 'Iniciar obrigação'),
    );
  }
}

class _DadosDaObrigacao extends StatelessWidget {
  const _DadosDaObrigacao(this.obrigacao);

  final Obrigacao obrigacao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final descricao = obrigacao.descricao;
    return Grupo(
      preenchimento: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text('Detalhes', style: tema.titleMedium)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 32,
            runSpacing: 20,
            children: [
              _Informacao(rotulo: 'Status', valor: IndicadorDeStatus(obrigacao.status)),
              _Informacao(
                rotulo: 'Vencimento',
                valor: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Datas.formatar(obrigacao.dataVencimento), style: tema.bodyMedium),
                    TextoDoPrazo(Prazo.de(obrigacao, Datas.hoje())),
                  ],
                ),
              ),
              _Informacao(
                rotulo: 'Empresa',
                valor: _TextoComDetalhe(obrigacao.empresa.razaoSocial, 'CNPJ ${Cnpj.formatar(obrigacao.empresa.cnpj)}'),
              ),
              _Informacao(
                rotulo: 'Responsável',
                valor: _TextoComDetalhe(obrigacao.responsavel.nome, obrigacao.responsavel.email),
              ),
            ],
          ),
          if (descricao != null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 20),
            Text('DESCRIÇÃO', style: tema.labelMedium),
            const SizedBox(height: 6),
            Text(descricao, style: tema.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _Informacao extends StatelessWidget {
  const _Informacao({required this.rotulo, required this.valor});

  static const _largura = 220.0;

  final String rotulo;
  final Widget valor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _largura,
    child: MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          valor,
        ],
      ),
    ),
  );
}

class _TextoComDetalhe extends StatelessWidget {
  const _TextoComDetalhe(this.texto, this.detalhe);

  final String texto;
  final String detalhe;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(texto, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      Text(detalhe, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario)),
    ],
  );
}
