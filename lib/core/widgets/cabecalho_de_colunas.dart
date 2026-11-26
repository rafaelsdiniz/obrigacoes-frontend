import 'package:material_ui/material_ui.dart';

import 'linha_de_cadastro.dart';

class CabecalhoDeColunas extends StatelessWidget {
  const CabecalhoDeColunas({required this.titulo, required this.detalhes, required this.situacao, super.key});

  final String titulo;
  final List<String> detalhes;
  final String situacao;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelMedium;
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(LinhaDeCadastro.margemHorizontal, 16, 8, 12),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(titulo.toUpperCase(), style: estilo)),
            for (final detalhe in detalhes) Expanded(flex: 2, child: Text(detalhe.toUpperCase(), style: estilo)),
            SizedBox(
              width: LinhaDeCadastro.larguraDaSituacao,
              child: Text(situacao.toUpperCase(), style: estilo),
            ),
            const SizedBox(width: LinhaDeCadastro.larguraDoMenu),
          ],
        ),
      ),
    );
  }
}
