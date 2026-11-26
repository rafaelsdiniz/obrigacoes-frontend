import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import '../tema/tema.dart';

class LinhaDeCadastro extends StatelessWidget {
  const LinhaDeCadastro({
    required this.avatar,
    required this.titulo,
    required this.detalhes,
    required this.selo,
    required this.menu,
    required this.aoTocar,
    super.key,
  });

  static const margemHorizontal = 16.0;
  static const larguraDoAvatar = 56.0;
  static const larguraDoSelo = 112.0;
  static const larguraDoMenu = 48.0;
  static const recuoDoSeparador = margemHorizontal + larguraDoAvatar;

  final Widget avatar;
  final String titulo;
  final List<String> detalhes;
  final Widget selo;
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
            padding: const EdgeInsets.symmetric(horizontal: margemHorizontal, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: larguraDoAvatar,
                  child: Align(alignment: Alignment.centerLeft, child: avatar),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: tema.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (!emColunas) ...[
                        const SizedBox(height: 2),
                        Text(
                          detalhes.where((detalhe) => detalhe.isNotEmpty).join(' · '),
                          style: tema.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        selo,
                      ],
                    ],
                  ),
                ),
                if (emColunas) ...[
                  for (final detalhe in detalhes)
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          detalhe.isEmpty ? '—' : detalhe,
                          style: Tema.textoSecundario(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: larguraDoSelo,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(fit: BoxFit.scaleDown, child: selo),
                    ),
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
