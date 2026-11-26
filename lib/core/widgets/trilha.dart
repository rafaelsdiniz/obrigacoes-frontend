import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import '../tema/tema.dart';
import 'icone.dart';

typedef Retorno = ({String rotulo, VoidCallback aoVoltar});

class Trilha extends StatelessWidget {
  const Trilha({required this.retorno, required this.atual, super.key});

  final Retorno retorno;
  final String atual;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Row(
      children: [
        TextButton.icon(
          onPressed: retorno.aoVoltar,
          style: TextButton.styleFrom(
            foregroundColor: cores.textoVariante,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          icon: const Icone(Icones.voltar, tamanho: TamanhosDeIcone.padrao),
          label: Text(retorno.rotulo, semanticsLabel: 'Voltar para ${retorno.rotulo.toLowerCase()}'),
        ),
        if (!Medidas.telaEstreita(context)) ...[
          Icone(Icones.avancar, tamanho: TamanhosDeIcone.pequeno, cor: cores.textoVariante),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              atual,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cores.texto),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
