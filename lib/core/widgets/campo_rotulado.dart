import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';

class CampoRotulado extends StatelessWidget {
  const CampoRotulado({required this.rotulo, required this.child, this.obrigatorio = false, super.key});

  final String rotulo;
  final bool obrigatorio;
  final Widget child;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: rotulo,
            children: [
              if (obrigatorio)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: context.cores.erro),
                  semanticsLabel: ', obrigatório',
                ),
            ],
          ),
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: context.cores.texto, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}
