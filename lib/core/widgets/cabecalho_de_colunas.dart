import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';
import 'linha_de_cadastro.dart';

class CabecalhoDeColunas extends StatelessWidget {
  const CabecalhoDeColunas({required this.titulo, required this.detalhes, required this.situacao, super.key});

  final String titulo;
  final List<String> detalhes;
  final String situacao;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final estilo = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: cores.textoVariante, fontWeight: FontWeight.w700);
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cores.superficieBaixa,
          border: Border(bottom: BorderSide(color: cores.borda)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(LinhaDeCadastro.margemHorizontal, 12, 8, 12),
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
      ),
    );
  }
}
