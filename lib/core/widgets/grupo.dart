import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';

class Grupo extends StatelessWidget {
  const Grupo({required this.child, this.preenchimento = EdgeInsets.zero, super.key});

  final Widget child;
  final EdgeInsetsGeometry preenchimento;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      borderRadius: Raios.grande,
      boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 6))],
    ),
    child: Material(
      color: Cores.superficie,
      borderRadius: Raios.grande,
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: preenchimento, child: child),
    ),
  );
}
