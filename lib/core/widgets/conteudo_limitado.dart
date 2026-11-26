import 'package:material_ui/material_ui.dart';

class ConteudoLimitado extends StatelessWidget {
  const ConteudoLimitado({required this.child, this.larguraMaxima = 1100, super.key});

  final Widget child;
  final double larguraMaxima;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: larguraMaxima),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child),
    ),
  );
}
