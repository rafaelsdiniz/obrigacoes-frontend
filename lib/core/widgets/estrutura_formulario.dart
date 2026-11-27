import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import '../tema/tema.dart';
import 'cabecalho_de_pagina.dart';
import 'conteudo_centralizado.dart';
import 'grupo.dart';
import 'icone.dart';
import 'progresso_no_botao.dart';
import 'secao_do_formulario.dart';
import 'trilha.dart';

class EstruturaFormulario extends StatelessWidget {
  const EstruturaFormulario({
    required this.titulo,
    required this.subtitulo,
    required this.chave,
    required this.secoes,
    required this.salvando,
    required this.aoSalvar,
    required this.retorno,
    super.key,
  });

  final String titulo;
  final String subtitulo;
  final GlobalKey<FormState> chave;
  final List<SecaoDoFormulario> secoes;
  final bool salvando;
  final Future<void> Function() aoSalvar;
  final Retorno retorno;

  @override
  Widget build(BuildContext context) {
    final estreita = Medidas.telaEstreita(context);
    return ConteudoCentralizado(
      children: [
        CabecalhoDePagina(titulo: titulo, subtitulo: subtitulo, retorno: retorno),
        const SizedBox(height: 28),
        Form(
          key: chave,
          child: Grupo(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (indice, secao) in secoes.indexed) ...[
                  if (indice > 0) const Divider(),
                  Padding(padding: EdgeInsets.all(estreita ? 20 : 32), child: secao),
                ],
                const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: estreita ? 20 : 32, vertical: 16),
                  child: _Acoes(
                    salvando: salvando,
                    aoSalvar: aoSalvar,
                    aoCancelar: retorno.aoVoltar,
                    empilhadas: estreita,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Acoes extends StatelessWidget {
  const _Acoes({required this.salvando, required this.aoSalvar, required this.aoCancelar, required this.empilhadas});

  final bool salvando;
  final Future<void> Function() aoSalvar;
  final VoidCallback aoCancelar;
  final bool empilhadas;

  @override
  Widget build(BuildContext context) {
    final salvar = FilledButton.icon(
      onPressed: () => unawaited(aoSalvar()),
      icon: salvando
          ? ProgressoNoBotao(cor: context.cores.sobrePrimaria)
          : const Icone(Icones.salvar, tamanho: TamanhosDeIcone.padrao),
      label: Text(salvando ? 'Salvando…' : 'Salvar'),
    );
    final cancelar = TextButton(onPressed: aoCancelar, child: const Text('Cancelar'));
    if (empilhadas) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [salvar, const SizedBox(height: 8), cancelar],
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [cancelar, const SizedBox(width: 12), salvar]);
  }
}
