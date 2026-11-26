import 'package:material_ui/material_ui.dart';

class Marca extends StatelessWidget {
  const Marca({required this.altura, super.key});

  final double altura;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Image.asset(
      'assets/imagens/logo-player.png',
      height: altura,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Player Contabilidade',
    ),
  );
}
