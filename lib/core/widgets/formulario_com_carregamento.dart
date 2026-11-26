import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../http/erro_api.dart';
import '../layout/medidas.dart';
import 'aviso_de_estado.dart';
import 'cabecalho_de_pagina.dart';
import 'estado_carregando.dart';
import 'estado_erro.dart';
import 'icone.dart';

class FormularioComCarregamento<T> extends StatelessWidget {
  const FormularioComCarregamento({
    required this.titulo,
    required this.registro,
    required this.aoTentarNovamente,
    required this.aoVoltar,
    required this.builder,
    super.key,
  });

  final String titulo;
  final AsyncValue<T> registro;
  final VoidCallback aoTentarNovamente;
  final VoidCallback aoVoltar;
  final Widget Function(T registro) builder;

  @override
  Widget build(BuildContext context) => registro.when(
    data: builder,
    loading: () => _Moldura(titulo: titulo, aoVoltar: aoVoltar, child: const EstadoCarregando()),
    error: (erro, _) => _Moldura(
      titulo: titulo,
      aoVoltar: aoVoltar,
      child: erro is ErroApi && erro.codigo == CodigoErro.recursoNaoEncontrado
          ? AvisoDeEstado(
              icone: Icones.naoEncontrado,
              titulo: 'Registro não encontrado',
              mensagem: erro.mensagem,
              acao: FilledButton(onPressed: aoVoltar, child: const Text('Voltar')),
            )
          : EstadoErro(erro: erro, aoTentarNovamente: aoTentarNovamente),
    ),
  );
}

class _Moldura extends StatelessWidget {
  const _Moldura({required this.titulo, required this.aoVoltar, required this.child});

  final String titulo;
  final VoidCallback aoVoltar;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: Medidas.margemDaPagina(context),
        child: Column(
          children: [
            CabecalhoDePagina(titulo: titulo, aoVoltar: aoVoltar),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}
