import 'package:material_ui/material_ui.dart';

import '../../../core/tema/tema.dart';
import '../../../core/widgets/grupo.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/indicador.dart';

class CartaoDeIndicador extends StatelessWidget {
  const CartaoDeIndicador({
    required this.rotulo,
    required this.quantidade,
    required this.icone,
    required this.tom,
    required this.aoAbrir,
    this.destacarQuandoMaiorQueZero = false,
    super.key,
  });

  static const _opacidadeDoFundoDoIcone = 0.12;

  final String rotulo;
  final int quantidade;
  final Icones icone;
  final TomDoIndicador tom;
  final VoidCallback aoAbrir;
  final bool destacarQuandoMaiorQueZero;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final emAlerta = destacarQuandoMaiorQueZero && quantidade > 0;
    return Semantics(
      button: true,
      label: '$rotulo: $quantidade. Ver obrigações',
      onTap: aoAbrir,
      excludeSemantics: true,
      child: Grupo(
        child: InkWell(
          onTap: aoAbrir,
          hoverColor: Cores.sobreposicao,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(rotulo.toUpperCase(), style: tema.labelMedium)),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: tom.cor.withValues(alpha: _opacidadeDoFundoDoIcone),
                        borderRadius: Raios.pequeno,
                      ),
                      child: SizedBox.square(
                        dimension: 36,
                        child: Center(child: Icone(icone, tamanho: 19, cor: tom.cor)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$quantidade',
                  style: tema.displaySmall?.copyWith(
                    color: emAlerta ? Cores.erro : Cores.texto,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Ver obrigações',
                        style: tema.bodySmall?.copyWith(color: Cores.textoSecundario),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icone(Icones.avancar, tamanho: 14, cor: Cores.textoSecundario),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
