import 'package:material_ui/material_ui.dart';

import 'botao_de_acao.dart';
import 'cabecalho_de_pagina.dart';
import 'conteudo_centralizado.dart';
import 'icone.dart';

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
  Widget build(BuildContext context) => ConteudoCentralizado(
    children: [
      CabecalhoDePagina(
        titulo: titulo,
        subtitulo: subtitulo,
        acoes: [BotaoDeAcao(rotulo: rotuloNovo, icone: Icones.adicionar, aoPressionar: aoCriarNovo)],
      ),
      const SizedBox(height: 28),
      filtros,
      const SizedBox(height: 12),
      conteudo,
    ],
  );
}
