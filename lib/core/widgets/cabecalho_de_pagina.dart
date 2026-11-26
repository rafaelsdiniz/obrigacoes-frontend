import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import '../tema/tema.dart';

class CabecalhoDePagina extends StatelessWidget {
  const CabecalhoDePagina({required this.titulo, this.subtitulo, this.aoVoltar, this.acoes = const [], super.key});

  final String titulo;
  final String? subtitulo;
  final VoidCallback? aoVoltar;
  final List<Widget> acoes;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Row(
      children: [
        if (aoVoltar case final voltar?) ...[
          IconButton(
            tooltip: 'Voltar',
            onPressed: voltar,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: Medidas.telaEstreita(context) ? tema.headlineSmall : tema.displaySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
  }
}
