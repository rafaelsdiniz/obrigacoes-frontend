import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';

class ConteudoCentralizado extends StatelessWidget {
  const ConteudoCentralizado({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: Medidas.margemDaPagina(context),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Medidas.larguraMaximaDaPagina),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
          ),
        ],
      ),
    ),
  );
}
