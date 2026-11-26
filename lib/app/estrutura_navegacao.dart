import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class EstruturaNavegacao extends StatelessWidget {
  const EstruturaNavegacao({required this.navegacao, super.key});

  static const larguraParaMenuLateral = 840.0;
  static const larguraParaMenuExpandido = 1200.0;

  static const _destinos = [
    (icone: Icons.business_outlined, iconeSelecionado: Icons.business, rotulo: 'Empresas'),
    (icone: Icons.people_outline, iconeSelecionado: Icons.people, rotulo: 'Usuários'),
  ];

  final StatefulNavigationShell navegacao;

  void _irPara(int indice) => navegacao.goBranch(indice, initialLocation: indice == navegacao.currentIndex);

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    if (largura < larguraParaMenuLateral) {
      return Scaffold(
        body: navegacao,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navegacao.currentIndex,
          onDestinationSelected: _irPara,
          destinations: [
            for (final destino in _destinos)
              NavigationDestination(
                icon: Icon(destino.icone),
                selectedIcon: Icon(destino.iconeSelecionado),
                label: destino.rotulo,
              ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: largura >= larguraParaMenuExpandido,
            labelType: largura >= larguraParaMenuExpandido ? null : NavigationRailLabelType.all,
            selectedIndex: navegacao.currentIndex,
            onDestinationSelected: _irPara,
            leading: _Marca(comNome: largura >= larguraParaMenuExpandido),
            destinations: [
              for (final destino in _destinos)
                NavigationRailDestination(
                  icon: Icon(destino.icone),
                  selectedIcon: Icon(destino.iconeSelecionado),
                  label: Text(destino.rotulo),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navegacao),
        ],
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({required this.comNome});

  final bool comNome;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.task_alt,
            size: 32,
            color: tema.colorScheme.tertiary,
            semanticLabel: comNome ? null : 'Obrigações',
          ),
          if (comNome) ...[const SizedBox(width: 12), Text('Obrigações', style: tema.textTheme.titleLarge)],
        ],
      ),
    );
  }
}
