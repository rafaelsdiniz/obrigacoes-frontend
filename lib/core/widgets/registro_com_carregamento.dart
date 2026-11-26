import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../http/erro_api.dart';
import '../layout/medidas.dart';
import 'aviso_de_estado.dart';
import 'cabecalho_de_pagina.dart';
import 'estado_carregando.dart';
import 'estado_erro.dart';
import 'icone.dart';
import 'trilha.dart';

class RegistroComCarregamento<T> extends StatelessWidget {
  const RegistroComCarregamento({
    required this.titulo,
    required this.registro,
    required this.aoTentarNovamente,
    required this.retorno,
    required this.builder,
    super.key,
  });

  final String titulo;
  final AsyncValue<T> registro;
  final VoidCallback aoTentarNovamente;
  final Retorno retorno;
  final Widget Function(T registro) builder;

  @override
  Widget build(BuildContext context) => registro.when(
    data: builder,
    loading: () => MolduraDoRegistro(titulo: titulo, retorno: retorno, child: const EstadoCarregando()),
    error: (erro, _) => MolduraDoRegistro(
      titulo: titulo,
      retorno: retorno,
      child: erro is ErroApi && erro.codigo == CodigoErro.recursoNaoEncontrado
          ? AvisoDeEstado(
              icone: Icones.naoEncontrado,
              titulo: 'Registro não encontrado',
              mensagem: erro.mensagem,
              acao: FilledButton(onPressed: retorno.aoVoltar, child: const Text('Voltar')),
            )
          : EstadoErro(erro: erro, aoTentarNovamente: aoTentarNovamente),
    ),
  );
}

class MolduraDoRegistro extends StatelessWidget {
  const MolduraDoRegistro({required this.titulo, required this.retorno, required this.child, super.key});

  final String titulo;
  final Retorno retorno;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: Medidas.margemDaPagina(context),
        child: Column(
          children: [
            CabecalhoDePagina(titulo: titulo, retorno: retorno),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}
