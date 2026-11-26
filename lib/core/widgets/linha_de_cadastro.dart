import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import '../tema/tema.dart';

class LinhaDeCadastro extends StatelessWidget {
  const LinhaDeCadastro({
    required this.titulo,
    required this.detalhes,
    required this.situacao,
    required this.menu,
    required this.aoTocar,
    super.key,
  });

  static const margemHorizontal = 20.0;
  static const larguraDaSituacao = 120.0;
  static const larguraDoMenu = 48.0;

  final String titulo;
  final List<String> detalhes;
  final Widget situacao;
  final Widget menu;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, restricoes) {
        final emColunas = restricoes.maxWidth >= Medidas.larguraParaColunas;
        return InkWell(
          onTap: aoTocar,
          hoverColor: Cores.sobreposicao,
          child: Padding(
            padding: EdgeInsets.fromLTRB(margemHorizontal, emColunas ? 16 : 14, 8, emColunas ? 16 : 14),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: tema.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (!emColunas) ...[
                        const SizedBox(height: 4),
                        Text(
                          detalhes.where((detalhe) => detalhe.isNotEmpty).join('  ·  '),
                          style: tema.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        situacao,
                      ],
                    ],
                  ),
                ),
                if (emColunas) ...[
                  for (final detalhe in detalhes)
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          detalhe.isEmpty ? '—' : detalhe,
                          style: Tema.textoSecundario(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: larguraDaSituacao,
                    child: Align(alignment: Alignment.centerLeft, child: situacao),
                  ),
                ],
                SizedBox(width: larguraDoMenu, child: menu),
              ],
            ),
          ),
        );
      },
    );
  }
}
