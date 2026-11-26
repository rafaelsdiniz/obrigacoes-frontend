import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';

class IconeEmQuadro extends StatelessWidget {
  const IconeEmQuadro(this.icone, {super.key});

  final IconData icone;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: Cores.douradoSuave, borderRadius: Raios.pequeno),
    child: SizedBox.square(dimension: 40, child: Icon(icone, size: 21, color: Cores.douradoTexto)),
  );
}
