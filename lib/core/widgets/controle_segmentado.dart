import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';

typedef OpcaoSegmentada<T> = ({T valor, String rotulo});

class ControleSegmentado<T> extends StatelessWidget {
  const ControleSegmentado({required this.opcoes, required this.selecionado, required this.aoSelecionar, super.key});

  final List<OpcaoSegmentada<T>> opcoes;
  final T selecionado;
  final ValueChanged<T> aoSelecionar;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: Cores.preenchimento, borderRadius: Raios.pequeno),
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final opcao in opcoes)
            Flexible(
              child: _Segmento(
                rotulo: opcao.rotulo,
                selecionado: opcao.valor == selecionado,
                aoTocar: () => aoSelecionar(opcao.valor),
              ),
            ),
        ],
      ),
    ),
  );
}

class _Segmento extends StatelessWidget {
  const _Segmento({required this.rotulo, required this.selecionado, required this.aoTocar});

  static const _alturaMinima = 48.0;
  static const _raio = BorderRadius.all(Radius.circular(8));

  final String rotulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelLarge;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selecionado,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selecionado ? Cores.superficie : Colors.transparent,
          borderRadius: _raio,
          boxShadow: selecionado
              ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))]
              : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: aoTocar,
            borderRadius: _raio,
            hoverColor: Cores.sobreposicao,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _alturaMinima),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    rotulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: estilo?.copyWith(
                      fontWeight: selecionado ? FontWeight.w600 : FontWeight.w500,
                      color: selecionado ? Cores.texto : Cores.textoSecundario,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
