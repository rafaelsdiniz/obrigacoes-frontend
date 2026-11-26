import 'package:material_ui/material_ui.dart';

import '../../../core/layout/medidas.dart';
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
    this.contexto,
    this.destacarQuandoMaiorQueZero = false,
    super.key,
  });

  static const _larguraParaRotulo = 280.0;

  final String rotulo;
  final int quantidade;
  final Icones icone;
  final TomDoIndicador tom;
  final VoidCallback aoAbrir;
  final String? contexto;
  final bool destacarQuandoMaiorQueZero;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final cores = context.cores;
    final emAlerta = destacarQuandoMaiorQueZero && quantidade > 0;
    final corDeDestaque = emAlerta ? cores.erro : null;
    final compacto = Medidas.telaEstreita(context);
    return Semantics(
      button: true,
      label: '$rotulo: $quantidade. Ver obrigações',
      onTap: aoAbrir,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, restricoes) {
          final largo = restricoes.maxWidth >= MediaQuery.textScalerOf(context).scale(_larguraParaRotulo);
          return Grupo(
            corDaBorda: emAlerta ? cores.erro.withValues(alpha: 0.3) : null,
            child: InkWell(
              onTap: aoAbrir,
              hoverColor: emAlerta ? cores.erroContainer.withValues(alpha: 0.15) : cores.realce,
              child: Padding(
                padding: EdgeInsets.all(compacto ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            rotulo.toUpperCase(),
                            style: tema.labelMedium?.copyWith(color: corDeDestaque),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(color: tom.forte(cores), borderRadius: Raios.controle),
                          child: SizedBox.square(
                            dimension: 32,
                            child: Center(
                              child: Icone(icone, tamanho: TamanhosDeIcone.padrao, cor: tom.sobreForte(cores)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compacto ? 10 : 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$quantidade',
                          style: tema.displaySmall?.copyWith(
                            color: corDeDestaque,
                            fontSize: compacto ? 28 : null,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const Spacer(),
                        if (!compacto && largo)
                          Text(
                            'Ver obrigações',
                            style: tema.labelLarge?.copyWith(color: corDeDestaque ?? cores.textoVariante),
                            maxLines: 1,
                          ),
                        const SizedBox(width: 2),
                        Icone(
                          Icones.avancar,
                          tamanho: TamanhosDeIcone.padrao,
                          cor: corDeDestaque ?? cores.textoVariante,
                        ),
                      ],
                    ),
                    if (contexto case final contexto? when !compacto) ...[
                      const SizedBox(height: 6),
                      Text(
                        contexto,
                        style: tema.bodySmall?.copyWith(color: corDeDestaque),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
