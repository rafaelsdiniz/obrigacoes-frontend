import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import 'botao_de_acao.dart';
import 'cabecalho_de_pagina.dart';
import 'marca.dart';

class PaginaDeListagem extends StatelessWidget {
  const PaginaDeListagem({
    required this.titulo,
    required this.subtitulo,
    required this.rotuloNovo,
    required this.aoCriarNovo,
    required this.filtros,
    required this.conteudo,
    super.key,
  });

  final String titulo;
  final String subtitulo;
  final String rotuloNovo;
  final VoidCallback aoCriarNovo;
  final Widget filtros;
  final Widget conteudo;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: Medidas.margemDaPagina(context),
        children: [
          if (!Medidas.telaLarga(context)) ...[const Marca(altura: 28), const SizedBox(height: 20)],
          CabecalhoDePagina(
            titulo: titulo,
            subtitulo: subtitulo,
            acoes: [BotaoDeAcao(rotulo: rotuloNovo, icone: Icons.add_rounded, aoPressionar: aoCriarNovo)],
          ),
          const SizedBox(height: 28),
          filtros,
          const SizedBox(height: 12),
          conteudo,
        ],
      ),
    ),
  );
}
