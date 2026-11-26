import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';

enum TomDoSelo {
  sucesso(Cores.sucessoSuave, Cores.sucesso),
  neutro(Cores.preenchimento, Cores.textoSecundario);

  const TomDoSelo(this.fundo, this.destaque);

  final Color fundo;
  final Color destaque;
}

class Selo extends StatelessWidget {
  const Selo({required this.rotulo, required this.tom, super.key});

  final String rotulo;
  final TomDoSelo tom;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(color: tom.fundo, shape: const StadiumBorder()),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: tom.destaque, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 6),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              rotulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: tom.destaque),
            ),
          ),
        ],
      ),
    ),
  );
}
