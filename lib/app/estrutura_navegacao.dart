import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/layout/medidas.dart';
import '../core/tema/tema.dart';
import '../core/widgets/icone.dart';
import '../core/widgets/marca.dart';

typedef _Destino = ({Icones icone, String rotulo});

class EstruturaNavegacao extends StatelessWidget {
  const EstruturaNavegacao({required this.navegacao, super.key});

  static const _larguraDaBarraLateral = 264.0;

  static const List<_Destino> _destinos = [
    (icone: Icones.painel, rotulo: 'Painel'),
    (icone: Icones.obrigacoes, rotulo: 'Obrigações'),
    (icone: Icones.empresas, rotulo: 'Empresas'),
    (icone: Icones.usuarios, rotulo: 'Usuários'),
  ];

  final StatefulNavigationShell navegacao;

  void _irPara(int indice) => navegacao.goBranch(indice, initialLocation: indice == navegacao.currentIndex);

  @override
  Widget build(BuildContext context) {
    if (!Medidas.telaLarga(context)) {
      return Scaffold(
        body: navegacao,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Cores.separador, width: 0.8)),
          ),
          child: NavigationBar(
            selectedIndex: navegacao.currentIndex,
            onDestinationSelected: _irPara,
            destinations: [
              for (final destino in _destinos)
                NavigationDestination(
                  icon: Icone(destino.icone, tamanho: 22, cor: Cores.textoSecundario),
                  selectedIcon: Icone(destino.icone, tamanho: 22, cor: Cores.dourado),
                  label: destino.rotulo,
                ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Row(
            children: [
              FocusTraversalOrder(
                order: const NumericFocusOrder(1),
                child: SizedBox(
                  width: _larguraDaBarraLateral,
                  child: _BarraLateral(destinos: _destinos, selecionado: navegacao.currentIndex, aoSelecionar: _irPara),
                ),
              ),
              Expanded(
                child: FocusTraversalOrder(order: const NumericFocusOrder(2), child: navegacao),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarraLateral extends StatelessWidget {
  const _BarraLateral({required this.destinos, required this.selecionado, required this.aoSelecionar});

  final List<_Destino> destinos;
  final int selecionado;
  final ValueChanged<int> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Cores.superficie,
        border: Border(right: BorderSide(color: Cores.separador, width: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Marca(altura: 40)),
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ExcludeSemantics(child: Text('GESTÃO', style: tema.labelMedium)),
            ),
            const SizedBox(height: 8),
            for (final (indice, destino) in destinos.indexed)
              _ItemDaBarraLateral(
                destino: destino,
                selecionado: indice == selecionado,
                aoTocar: () => aoSelecionar(indice),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Gerenciamento de Obrigações', style: tema.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemDaBarraLateral extends StatelessWidget {
  const _ItemDaBarraLateral({required this.destino, required this.selecionado, required this.aoTocar});

  static const _alturaMinima = 48.0;

  final _Destino destino;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? Colors.white : Cores.texto;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selecionado ? Cores.grafite : Colors.transparent,
        borderRadius: Raios.pequeno,
        child: InkWell(
          onTap: aoTocar,
          borderRadius: Raios.pequeno,
          hoverColor: Cores.sobreposicao,
          child: Semantics(
            selected: selecionado,
            button: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _alturaMinima),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Icone(destino.icone, tamanho: 21, cor: selecionado ? Cores.dourado : Cores.textoSecundario),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        destino.rotulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(fontWeight: selecionado ? FontWeight.w600 : FontWeight.w500, color: cor),
                      ),
                    ),
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
