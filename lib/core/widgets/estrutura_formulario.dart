import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import 'cabecalho_de_pagina.dart';
import 'grupo.dart';

class CampoDoFormulario {
  const CampoDoFormulario(this.campo, {this.larguraInteira = false});

  final Widget campo;
  final bool larguraInteira;
}

class EstruturaFormulario extends StatelessWidget {
  const EstruturaFormulario({
    required this.titulo,
    required this.subtitulo,
    required this.chave,
    required this.campos,
    required this.salvando,
    required this.aoSalvar,
    required this.aoVoltar,
    super.key,
  });

  static const _espacamento = 16.0;
  static const _alturaDoBotaoNoCelular = 50.0;

  final String titulo;
  final String subtitulo;
  final GlobalKey<FormState> chave;
  final List<CampoDoFormulario> campos;
  final bool salvando;
  final Future<void> Function() aoSalvar;
  final VoidCallback aoVoltar;

  @override
  Widget build(BuildContext context) {
    final estreita = Medidas.telaEstreita(context);
    final botaoSalvar = FilledButton.icon(
      onPressed: () => unawaited(aoSalvar()),
      icon: salvando
          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.check_rounded, size: 20),
      label: const Text('Salvar'),
    );
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: chave,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: Medidas.margemDaPagina(context),
            children: [
              CabecalhoDePagina(
                titulo: titulo,
                subtitulo: subtitulo,
                aoVoltar: aoVoltar,
                acoes: estreita ? const [] : [botaoSalvar],
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Medidas.larguraMaximaDoFormulario),
                  child: Grupo(
                    preenchimento: EdgeInsets.all(estreita ? 16 : 28),
                    child: LayoutBuilder(
                      builder: (context, restricoes) {
                        final duasColunas = restricoes.maxWidth >= Medidas.larguraParaColunas;
                        final meiaLargura = (restricoes.maxWidth - _espacamento) / 2;
                        return Wrap(
                          spacing: _espacamento,
                          runSpacing: _espacamento,
                          children: [
                            for (final campo in campos)
                              SizedBox(
                                width: duasColunas && !campo.larguraInteira ? meiaLargura : restricoes.maxWidth,
                                child: campo.campo,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (estreita) ...[
                const SizedBox(height: 24),
                SizedBox(height: _alturaDoBotaoNoCelular, child: botaoSalvar),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
