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
import '../../../core/widgets/cabecalho_do_cartao.dart';
import '../../../core/widgets/conteudo_centralizado.dart';
import '../../../core/widgets/grupo.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/progresso_no_botao.dart';
import '../../../core/widgets/registro_com_carregamento.dart';
import '../../../core/widgets/trilha.dart';
import '../../anexos/presentation/anexos_da_obrigacao.dart';
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
    retorno: (rotulo: 'Obrigações', aoVoltar: () => context.go(RotasObrigacoes.lista)),
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
      await ref.read(obrigacaoProvider(widget.obrigacao.id).future);
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
    final editar = obrigacao.concluida
        ? null
        : OutlinedButton.icon(
            onPressed: () => context.go(RotasObrigacoes.edicao(obrigacao.id)),
            icon: const Icone(Icones.editar, tamanho: TamanhosDeIcone.padrao),
            label: const Text('Editar'),
          );
    final avancar = proximo == null
        ? null
        : _BotaoDeAvanco(proximo: proximo, avancando: _avancando, aoAvancar: _avancar);
    return ConteudoCentralizado(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Trilha(
            retorno: (rotulo: 'Obrigações', aoVoltar: () => context.go(RotasObrigacoes.lista)),
            atual: obrigacao.titulo,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _Identificacao(obrigacao)),
            if (!estreita) ...[
              if (editar != null) ...[const SizedBox(width: 16), editar],
              if (avancar != null) ...[const SizedBox(width: 12), avancar],
            ],
          ],
        ),
        if (estreita && (editar != null || avancar != null)) ...[
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?avancar,
              if (editar != null && avancar != null) const SizedBox(height: Medidas.espacoEntreControles),
              ?editar,
            ],
          ),
        ],
        if (_Faixa.para(obrigacao) case final faixa?) ...[const SizedBox(height: 24), faixa],
        const SizedBox(height: 24),
        EtapasDoFluxo(obrigacao),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, restricoes) {
            final dados = _DadosDaObrigacao(obrigacao);
            final anexos = AnexosDaObrigacao(obrigacaoId: obrigacao.id, permiteExcluir: !obrigacao.concluida);
            final historico = HistoricoDaObrigacao(obrigacao);
            final registro = _Registro(obrigacao);
            if (restricoes.maxWidth < _larguraParaDuasColunas) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  dados,
                  const SizedBox(height: 24),
                  anexos,
                  const SizedBox(height: 24),
                  historico,
                  const SizedBox(height: 24),
                  registro,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [dados, const SizedBox(height: 24), anexos],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [historico, const SizedBox(height: 24), registro],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  static const _larguraParaDuasColunas = 960.0;
}

class _Identificacao extends StatelessWidget {
  const _Identificacao(this.obrigacao);

  final Obrigacao obrigacao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final competencia = obrigacao.competencia;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            obrigacao.titulo,
            style: Medidas.telaEstreita(context) ? tema.headlineSmall : tema.displaySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${obrigacao.empresa.razaoSocial}  ·  responsável ${obrigacao.responsavel.nome}',
          style: Tema.textoSecundario(context),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Etiqueta(icone: Icones.etiqueta, texto: obrigacao.tipo.rotulo),
            if (competencia != null) _Etiqueta(texto: 'Competência $competencia', mono: true),
          ],
        ),
      ],
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, this.icone, this.mono = false});

  final String texto;
  final Icones? icone;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final icone = this.icone;
    return DecoratedBox(
      decoration: BoxDecoration(color: cores.secundarioContainer, borderRadius: Raios.controle),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[
              Icone(icone, tamanho: TamanhosDeIcone.pequeno, cor: cores.sobreSecundarioContainer),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                texto,
                style: mono
                    ? Tema.mono(context, peso: FontWeight.w600, cor: cores.sobreSecundarioContainer)
                    : Theme.of(context).textTheme.labelLarge?.copyWith(color: cores.sobreSecundarioContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Faixa extends StatelessWidget {
  const _Faixa({required this.icone, required this.mensagem, required this.tom});

  static _Faixa? para(Obrigacao obrigacao) {
    if (obrigacao.concluida) {
      return const _Faixa(
        icone: Icones.statusConcluida,
        mensagem: 'Obrigação concluída. Ela não pode mais ser editada nem mudar de status.',
        tom: _TomDaFaixa.sucesso,
      );
    }
    final prazo = Prazo.de(obrigacao, Datas.hoje());
    if (prazo.urgencia != UrgenciaDoPrazo.atrasada) {
      return null;
    }
    final diasDeAtraso = -prazo.diasAteOVencimento;
    final ha = diasDeAtraso > 0 ? ', há ${Prazo.emDias(diasDeAtraso)}' : '';
    return _Faixa(
      icone: Icones.statusAtrasada,
      mensagem: 'Esta obrigação venceu em ${Datas.formatar(obrigacao.dataVencimento)}$ha.',
      tom: _TomDaFaixa.erro,
    );
  }

  final Icones icone;
  final String mensagem;
  final _TomDaFaixa tom;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final corDeFundo = switch (tom) {
      _TomDaFaixa.erro => cores.erro,
      _TomDaFaixa.sucesso => cores.sucesso,
    };
    final corDoConteudo = cores.sobreForte;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: corDeFundo, borderRadius: Raios.cartao),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icone(icone, tamanho: TamanhosDeIcone.grande, cor: corDoConteudo),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mensagem,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: corDoConteudo, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TomDaFaixa { erro, sucesso }

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
          ? ProgressoNoBotao(cor: context.cores.sobrePrimaria)
          : Icone(proximo.icone, tamanho: TamanhosDeIcone.padrao),
      label: Text(concluir ? 'Concluir obrigação' : 'Iniciar obrigação'),
    );
  }
}

class _DadosDaObrigacao extends StatelessWidget {
  const _DadosDaObrigacao(this.obrigacao);

  static const _larguraParaDuasColunas = 480.0;

  final Obrigacao obrigacao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final descricao = obrigacao.descricao;
    final informacoes = [
      _Informacao(
        rotulo: 'Empresa',
        valor: _TextoComDetalhe(
          obrigacao.empresa.razaoSocial,
          Text(
            'CNPJ ${Cnpj.formatar(obrigacao.empresa.cnpj)}',
            style: Tema.mono(context, cor: context.cores.textoVariante),
          ),
        ),
      ),
      _Informacao(
        rotulo: 'Responsável',
        valor: _TextoComDetalhe(obrigacao.responsavel.nome, Text(obrigacao.responsavel.email, style: tema.bodySmall)),
      ),
      _Informacao(
        rotulo: 'Vencimento',
        valor: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Datas.formatar(obrigacao.dataVencimento),
              style: Tema.mono(context, tamanho: 13, peso: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            TextoDoPrazo(Prazo.de(obrigacao, Datas.hoje())),
          ],
        ),
      ),
      _Informacao(rotulo: 'Status', valor: IndicadorDeStatus(obrigacao.status)),
    ];
    return Grupo(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CabecalhoDoCartao(titulo: 'Detalhes'),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, restricoes) {
                    final colunas = restricoes.maxWidth >= _larguraParaDuasColunas ? 2 : 1;
                    final largura = (restricoes.maxWidth - 32 * (colunas - 1)) / colunas;
                    return Wrap(
                      spacing: 32,
                      runSpacing: 24,
                      children: [for (final informacao in informacoes) SizedBox(width: largura, child: informacao)],
                    );
                  },
                ),
                if (descricao != null) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text('DESCRIÇÃO', style: tema.labelMedium),
                  const SizedBox(height: 6),
                  Text(descricao, style: tema.bodyMedium?.copyWith(height: 1.55)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Informacao extends StatelessWidget {
  const _Informacao({required this.rotulo, required this.valor});

  final String rotulo;
  final Widget valor;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        valor,
      ],
    ),
  );
}

class _TextoComDetalhe extends StatelessWidget {
  const _TextoComDetalhe(this.texto, this.detalhe);

  final String texto;
  final Widget detalhe;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(texto, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 2),
      detalhe,
    ],
  );
}

class _Registro extends StatelessWidget {
  const _Registro(this.obrigacao);

  final Obrigacao obrigacao;

  @override
  Widget build(BuildContext context) {
    final criadoEm = obrigacao.criadoEm;
    final atualizadoEm = obrigacao.atualizadoEm;
    return Grupo(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CabecalhoDoCartao(titulo: 'Registro'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              children: [
                if (criadoEm != null) _LinhaDoRegistro('Criada em', Datas.formatarComHora(criadoEm)),
                if (atualizadoEm != null) _LinhaDoRegistro('Atualizada em', Datas.formatarComHora(atualizadoEm)),
                _LinhaDoRegistro('Código', '#${obrigacao.id}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaDoRegistro extends StatelessWidget {
  const _LinhaDoRegistro(this.rotulo, this.valor);

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(rotulo, style: Tema.textoSecundario(context))),
          Text(valor, style: Tema.mono(context, peso: FontWeight.w600)),
        ],
      ),
    ),
  );
}
