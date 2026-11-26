import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/layout/medidas.dart';
import '../core/tema/preferencia_de_tema.dart';
import '../core/tema/tema.dart';
import '../core/widgets/icone.dart';
import '../core/widgets/marca.dart';
import '../features/busca/presentation/busca_global.dart';
import '../features/obrigacoes/presentation/obrigacoes_providers.dart';

typedef DestinoDeNavegacao = ({Icones icone, String rotulo});

class EstruturaNavegacao extends StatefulWidget {
  const EstruturaNavegacao({required this.navegacao, super.key});

  static const larguraDaBarraLateral = 240.0;
  static const alturaDaBarraSuperior = 64.0;

  static const List<DestinoDeNavegacao> destinos = [
    (icone: Icones.painel, rotulo: 'Painel'),
    (icone: Icones.obrigacoes, rotulo: 'Obrigações'),
    (icone: Icones.empresas, rotulo: 'Empresas'),
    (icone: Icones.usuarios, rotulo: 'Usuários'),
  ];

  final StatefulNavigationShell navegacao;

  @override
  State<EstruturaNavegacao> createState() => _EstruturaNavegacaoState();
}

class _EstruturaNavegacaoState extends State<EstruturaNavegacao> {
  final _focoDaBusca = FocusNode(debugLabel: 'Busca global');
  final _escopoDoConteudo = FocusScopeNode(debugLabel: 'Conteúdo');

  @override
  void dispose() {
    _focoDaBusca.dispose();
    _escopoDoConteudo.dispose();
    super.dispose();
  }

  void _irPara(int indice) =>
      widget.navegacao.goBranch(indice, initialLocation: indice == widget.navegacao.currentIndex);

  KeyEventResult _atalhos(FocusNode _, KeyEvent evento) {
    final digitando = FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>();
    if (evento is KeyDownEvent && evento.logicalKey == LogicalKeyboardKey.slash && digitando == null) {
      _focoDaBusca.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _pularParaOConteudo() {
    _escopoDoConteudo.requestFocus();
    _escopoDoConteudo.nextFocus();
  }

  @override
  Widget build(BuildContext context) {
    final conteudo = FocusScope(node: _escopoDoConteudo, child: widget.navegacao);
    if (!Medidas.telaLarga(context)) {
      return Scaffold(
        appBar: const _BarraSuperiorCompacta(),
        body: conteudo,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.cores.borda)),
          ),
          child: NavigationBar(
            selectedIndex: widget.navegacao.currentIndex,
            onDestinationSelected: _irPara,
            destinations: [
              for (final destino in EstruturaNavegacao.destinos)
                NavigationDestination(
                  icon: Icone(destino.icone, tamanho: TamanhosDeIcone.grande),
                  label: destino.rotulo,
                ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Focus(
          onKeyEvent: _atalhos,
          canRequestFocus: false,
          skipTraversal: true,
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Stack(
              children: [
                Row(
                  children: [
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(2),
                      child: SizedBox(
                        width: EstruturaNavegacao.larguraDaBarraLateral,
                        child: _BarraLateral(selecionado: widget.navegacao.currentIndex, aoSelecionar: _irPara),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(3),
                            child: _BarraSuperior(focoDaBusca: _focoDaBusca),
                          ),
                          Expanded(
                            child: FocusTraversalOrder(order: const NumericFocusOrder(4), child: conteudo),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: _PularParaOConteudo(aoAcionar: _pularParaOConteudo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PularParaOConteudo extends StatefulWidget {
  const _PularParaOConteudo({required this.aoAcionar});

  final VoidCallback aoAcionar;

  @override
  State<_PularParaOConteudo> createState() => _PularParaOConteudoState();
}

class _PularParaOConteudoState extends State<_PularParaOConteudo> {
  bool _visivel = false;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 16,
    top: 12,
    child: Opacity(
      opacity: _visivel ? 1 : 0,
      child: Focus(
        onFocusChange: (focado) => setState(() => _visivel = focado),
        child: FilledButton(onPressed: widget.aoAcionar, child: const Text('Pular para o conteúdo')),
      ),
    ),
  );
}

class _BarraLateral extends ConsumerWidget {
  const _BarraLateral({required this.selecionado, required this.aoSelecionar});

  final int selecionado;
  final ValueChanged<int> aoSelecionar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cores = context.cores;
    final atrasadas = ref.watch(resumoDasObrigacoesProvider).value?.atrasadas ?? 0;
    return ColoredBox(
      color: cores.barraLateral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: EstruturaNavegacao.alturaDaBarraSuperior,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cores.sobreBarraLateral.withValues(alpha: 0.08))),
            ),
            child: const Marca(altura: 34, sobreFundoEscuro: true),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: ExcludeSemantics(
                    child: Text(
                      'GESTÃO',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: cores.sobreBarraLateral.withValues(alpha: 0.6), letterSpacing: 1.2),
                    ),
                  ),
                ),
                Semantics(
                  container: true,
                  label: 'Navegação principal',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (indice, destino) in EstruturaNavegacao.destinos.indexed)
                        _ItemDaBarraLateral(
                          destino: destino,
                          selecionado: indice == selecionado,
                          contador: indice == 1 ? atrasadas : 0,
                          aoTocar: () => aoSelecionar(indice),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemDaBarraLateral extends StatelessWidget {
  const _ItemDaBarraLateral({
    required this.destino,
    required this.selecionado,
    required this.contador,
    required this.aoTocar,
  });

  static const _larguraDoDestaque = 3.0;

  final DestinoDeNavegacao destino;
  final bool selecionado;
  final int contador;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final base = cores.sobreBarraLateral;
    final corDoTexto = selecionado ? base : base.withValues(alpha: 0.78);
    final corDoIcone = selecionado ? cores.marca : base.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selecionado ? base.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: Raios.controle,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          hoverColor: base.withValues(alpha: 0.06),
          highlightColor: base.withValues(alpha: 0.08),
          splashColor: base.withValues(alpha: 0.08),
          child: Semantics(
            selected: selecionado,
            button: true,
            label: contador > 0 ? '${destino.rotulo}, $contador obrigações atrasadas' : destino.rotulo,
            excludeSemantics: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Medidas.alturaDoControle),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: Movimento.duracao(context, Movimento.mudancaDeEstado),
                    width: _larguraDoDestaque,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selecionado ? cores.marca : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(_larguraDoDestaque)),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Icone(destino.icone, tamanho: TamanhosDeIcone.grande, cor: corDoIcone),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      destino.rotulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: corDoTexto, fontWeight: selecionado ? FontWeight.w600 : FontWeight.w500),
                    ),
                  ),
                  if (contador > 0) _Contador(contador),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador(this.valor);

  final int valor;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: cores.erro, borderRadius: Raios.pilula),
      child: Text(
        '$valor',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: cores.sobreForte, fontFeatures: const [FontFeature.tabularFigures()]),
      ),
    );
  }
}

class _BarraSuperior extends StatelessWidget {
  const _BarraSuperior({required this.focoDaBusca});

  static const _recuoOpticoDoBotao = (Medidas.alturaDoControle - TamanhosDeIcone.grande) / 2;

  final FocusNode focoDaBusca;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final margem = Medidas.margemDaPagina(context);
    return Container(
      height: EstruturaNavegacao.alturaDaBarraSuperior,
      padding: EdgeInsets.only(left: margem.left, right: margem.right),
      decoration: BoxDecoration(
        color: cores.superficieMaisBaixa,
        border: Border(bottom: BorderSide(color: cores.borda)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Medidas.larguraMaximaDaPagina),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: BuscaGlobal(foco: focoDaBusca),
                ),
              ),
              const SizedBox(width: 16),
              Transform.translate(offset: const Offset(_recuoOpticoDoBotao, 0), child: const BotaoDeTema()),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarraSuperiorCompacta extends StatelessWidget implements PreferredSizeWidget {
  const _BarraSuperiorCompacta();

  @override
  Size get preferredSize => const Size.fromHeight(EstruturaNavegacao.alturaDaBarraSuperior);

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Material(
      color: cores.superficieMaisBaixa,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: EstruturaNavegacao.alturaDaBarraSuperior,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cores.borda)),
          ),
          child: Row(
            children: [
              const Expanded(child: Marca(altura: 30)),
              IconButton(
                tooltip: 'Buscar',
                onPressed: () => abrirBuscaEmTelaCheia(context),
                icon: const Icone(Icones.buscar, tamanho: TamanhosDeIcone.grande),
              ),
              const BotaoDeTema(),
            ],
          ),
        ),
      ),
    );
  }
}

class BotaoDeTema extends ConsumerWidget {
  const BotaoDeTema({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final rotulo = escuro ? 'Usar tema claro' : 'Usar tema escuro';
    return IconButton(
      tooltip: rotulo,
      onPressed: () => ref.read(temaProvider.notifier).alternar(Theme.of(context).brightness),
      style: IconButton.styleFrom(foregroundColor: context.cores.textoVariante),
      icon: AnimatedSwitcher(
        duration: Movimento.duracao(context, Movimento.mudancaDeEstado),
        child: Icone(
          escuro ? Icones.sol : Icones.lua,
          key: ValueKey(escuro),
          tamanho: TamanhosDeIcone.grande,
          rotulo: rotulo,
        ),
      ),
    );
  }
}
