import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';
import 'icone.dart';

enum TomDoIndicador {
  sucesso,
  atencao,
  informacao,
  erro,
  neutro;

  Color sobreForte(Paleta cores) => this == atencao ? cores.sobreMarca : cores.sobreForte;

  Color forte(Paleta cores) => switch (this) {
    sucesso => cores.sucesso,
    atencao => cores.marca,
    informacao => cores.info,
    erro => cores.erro,
    neutro => cores.textoVariante,
  };
}

class Indicador extends StatelessWidget {
  const Indicador({required this.icone, required this.rotulo, required this.tom, super.key});

  static const larguraMinima = 124.0;

  final Icones icone;
  final String rotulo;
  final TomDoIndicador tom;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final conteudo = tom.sobreForte(cores);
    return Container(
      constraints: BoxConstraints(minWidth: MediaQuery.textScalerOf(context).scale(larguraMinima)),
      decoration: BoxDecoration(color: tom.forte(cores), borderRadius: Raios.pilula),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icone(icone, tamanho: TamanhosDeIcone.pequeno, cor: conteudo),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                rotulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: conteudo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
