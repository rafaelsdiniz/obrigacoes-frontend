import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';
import 'icone.dart';

enum TomDoIndicador {
  sucesso(Cores.sucesso),
  atencao(Cores.atencao),
  informacao(Cores.informacao),
  erro(Cores.erro),
  neutro(Cores.textoSecundario);

  const TomDoIndicador(this.cor);

  final Color cor;
}

class Indicador extends StatelessWidget {
  const Indicador({required this.icone, required this.rotulo, required this.tom, super.key});

  final Icones icone;
  final String rotulo;
  final TomDoIndicador tom;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icone(icone, tamanho: 17, cor: tom.cor),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          rotulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: tom.cor),
        ),
      ),
    ],
  );
}
