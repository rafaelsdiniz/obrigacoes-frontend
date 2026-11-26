import 'package:material_ui/material_ui.dart';

class Marca extends StatelessWidget {
  const Marca({required this.altura, this.sobreFundoEscuro = false, super.key});

  final double altura;
  final bool sobreFundoEscuro;

  @override
  Widget build(BuildContext context) {
    final clara = sobreFundoEscuro || Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Image.asset(
        clara ? 'assets/imagens/logo-player-escuro.png' : 'assets/imagens/logo-player.png',
        height: altura,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Player Contabilidade',
      ),
    );
  }
}
