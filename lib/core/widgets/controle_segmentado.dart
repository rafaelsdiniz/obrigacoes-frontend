import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import '../tema/tema.dart';
import 'opcao.dart';

class ControleSegmentado<T> extends StatelessWidget {
  const ControleSegmentado({
    required this.opcoes,
    required this.selecionado,
    required this.aoSelecionar,
    this.contagens = const {},
    super.key,
  });

  final List<Opcao<T>> opcoes;
  final T selecionado;
  final ValueChanged<T> aoSelecionar;
  final Map<T, int> contagens;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.cores.superficie,
        borderRadius: Raios.controle,
        border: Border.all(color: context.cores.bordaDoCampo),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final opcao in opcoes)
            _Segmento(
              rotulo: opcao.rotulo,
              contagem: contagens[opcao.valor],
              selecionado: opcao.valor == selecionado,
              aoTocar: () => aoSelecionar(opcao.valor),
            ),
        ],
      ),
    ),
  );
}

class _Segmento extends StatelessWidget {
  const _Segmento({required this.rotulo, required this.contagem, required this.selecionado, required this.aoTocar});

  static const _recuo = 4.0;

  final String rotulo;
  final int? contagem;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final estilo = Theme.of(context).textTheme.labelLarge;
    final contagem = this.contagem;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selecionado,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: aoTocar,
          borderRadius: Raios.controle,
          hoverColor: cores.superficieAlta,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Medidas.alturaDoControle),
            child: Padding(
              padding: const EdgeInsets.all(_recuo),
              child: AnimatedContainer(
                duration: Movimento.duracao(context, Movimento.mudancaDeEstado),
                curve: Movimento.curvaDeEntrada,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selecionado ? cores.primaria : Colors.transparent,
                  borderRadius: Raios.controle,
                  boxShadow: selecionado
                      ? const [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))]
                      : const [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rotulo,
                      maxLines: 1,
                      style: estilo?.copyWith(
                        fontWeight: selecionado ? FontWeight.w600 : FontWeight.w500,
                        color: selecionado ? cores.sobrePrimaria : cores.textoVariante,
                      ),
                    ),
                    if (contagem != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '$contagem',
                        style: Tema.mono(
                          context,
                          tamanho: 11,
                          cor: selecionado ? cores.sobrePrimaria.withValues(alpha: 0.8) : cores.textoVariante,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
