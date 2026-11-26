import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';

class ConteudoCentralizado extends StatelessWidget {
  const ConteudoCentralizado({required this.children, this.larguraMaxima = Medidas.larguraMaximaDoConteudo, super.key});

  final List<Widget> children;
  final double larguraMaxima;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: Medidas.margemDaPagina(context),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: larguraMaxima),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
          ),
        ],
      ),
    ),
  );
}
