import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';

class Grupo extends StatelessWidget {
  const Grupo({required this.child, this.preenchimento = EdgeInsets.zero, this.corDaBorda, super.key});

  final Widget child;
  final EdgeInsetsGeometry preenchimento;
  final Color? corDaBorda;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: Raios.cartao,
        boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Material(
        color: cores.superficieMaisBaixa,
        shape: RoundedRectangleBorder(
          borderRadius: Raios.cartao,
          side: BorderSide(color: corDaBorda ?? cores.borda),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: preenchimento, child: child),
      ),
    );
  }
}
