import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import '../tema/tema.dart';
import 'trilha.dart';

class CabecalhoDePagina extends StatelessWidget {
  const CabecalhoDePagina({required this.titulo, this.subtitulo, this.retorno, this.acoes = const [], super.key});

  final String titulo;
  final String? subtitulo;
  final Retorno? retorno;
  final List<Widget> acoes;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final retorno = this.retorno;
    final cabecalho = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  titulo,
                  style: Medidas.telaEstreita(context) ? tema.headlineSmall : tema.displaySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitulo case final subtitulo?) ...[
                const SizedBox(height: 6),
                Text(subtitulo, style: Tema.textoSecundario(context)),
              ],
            ],
          ),
        ),
        for (final acao in acoes) Padding(padding: const EdgeInsets.only(left: 12), child: acao),
      ],
    );
    if (retorno == null) {
      return cabecalho;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Trilha(retorno: retorno, atual: titulo),
        ),
        const SizedBox(height: 12),
        cabecalho,
      ],
    );
  }
}
