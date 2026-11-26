import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import '../tema/tema.dart';
import 'icone.dart';
import 'opcao.dart';

const _larguraMaximaDoMenu = 360.0;
const _tamanhoMaximoDoMenu = Size(_larguraMaximaDoMenu, 420);
const _larguraMaximaDoRotulo = 220.0;

class MenuDeFiltro<T extends Object> extends StatelessWidget {
  const MenuDeFiltro({
    required this.rotulo,
    required this.rotuloDeTodos,
    required this.icone,
    required this.opcoes,
    required this.selecionado,
    required this.aoSelecionar,
    super.key,
  });

  final String rotulo;
  final String rotuloDeTodos;
  final Icones icone;
  final List<Opcao<T>> opcoes;
  final T? selecionado;
  final ValueChanged<T?> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    final ativo = selecionado != null;
    final rotuloAtual = opcoes.where((opcao) => opcao.valor == selecionado).firstOrNull?.rotulo;
    final corDoConteudo = corDoFiltro(context, ativo: ativo);
    return MenuAnchor(
      style: const MenuStyle(maximumSize: WidgetStatePropertyAll(_tamanhoMaximoDoMenu)),
      menuChildren: [
        ItemDoMenu(rotulo: rotuloDeTodos, marcado: !ativo, aoSelecionar: () => aoSelecionar(null)),
        const Divider(height: 8),
        for (final opcao in opcoes)
          ItemDoMenu(
            rotulo: opcao.rotulo,
            marcado: opcao.valor == selecionado,
            aoSelecionar: () => aoSelecionar(opcao.valor),
          ),
      ],
      builder: (context, controle, _) => OutlinedButton(
        onPressed: () => controle.isOpen ? controle.close() : controle.open(),
        style: estiloDeFiltro(context, ativo: ativo),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icone(icone, tamanho: TamanhosDeIcone.padrao, cor: corDoConteudo),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _larguraMaximaDoRotulo),
              child: Text(
                rotuloAtual ?? rotulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                semanticsLabel: '$rotulo: ${rotuloAtual ?? rotuloDeTodos}',
              ),
            ),
            const SizedBox(width: 6),
            Icone(Icones.expandir, tamanho: TamanhosDeIcone.padrao, cor: corDoConteudo),
          ],
        ),
      ),
    );
  }
}

enum TomDoFiltro { padrao, alerta }

Color corDoFiltro(BuildContext context, {required bool ativo, TomDoFiltro tom = TomDoFiltro.padrao}) {
  final cores = context.cores;
  if (!ativo) {
    return cores.texto;
  }
  return tom == TomDoFiltro.alerta ? cores.sobreForte : cores.sobrePrimaria;
}

ButtonStyle estiloDeFiltro(BuildContext context, {required bool ativo, TomDoFiltro tom = TomDoFiltro.padrao}) {
  final cores = context.cores;
  final (fundo, borda) = switch ((ativo, tom)) {
    (false, _) => (cores.superficieMaisBaixa, cores.bordaDoCampo),
    (true, TomDoFiltro.padrao) => (cores.primaria, cores.primaria),
    (true, TomDoFiltro.alerta) => (cores.erro, cores.erro),
  };
  return OutlinedButton.styleFrom(
    minimumSize: const Size(0, Medidas.alturaDoControle),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    foregroundColor: corDoFiltro(context, ativo: ativo, tom: tom),
    backgroundColor: fundo,
    side: BorderSide(color: borda),
    shape: const RoundedRectangleBorder(borderRadius: Raios.controle),
  );
}

class BotaoDeAlternancia extends StatelessWidget {
  const BotaoDeAlternancia({
    required this.rotulo,
    required this.icone,
    required this.ativo,
    required this.aoAlternar,
    this.contador,
    this.tom = TomDoFiltro.padrao,
    super.key,
  });

  final String rotulo;
  final Icones icone;
  final bool ativo;
  final ValueChanged<bool> aoAlternar;
  final Widget? contador;
  final TomDoFiltro tom;

  @override
  Widget build(BuildContext context) {
    final contador = this.contador;
    final cor = corDoFiltro(context, ativo: ativo, tom: tom);
    return Semantics(
      toggled: ativo,
      child: OutlinedButton(
        onPressed: () => aoAlternar(!ativo),
        style: estiloDeFiltro(context, ativo: ativo, tom: tom),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icone(
              icone,
              tamanho: TamanhosDeIcone.padrao,
              cor: !ativo && tom == TomDoFiltro.alerta ? context.cores.erro : cor,
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(rotulo, maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (contador != null) ...[const SizedBox(width: 8), contador],
          ],
        ),
      ),
    );
  }
}

class ItemDoMenu extends StatelessWidget {
  const ItemDoMenu({required this.rotulo, required this.marcado, required this.aoSelecionar, super.key});

  final String rotulo;
  final bool marcado;
  final VoidCallback aoSelecionar;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: marcado,
    child: MenuItemButton(
      onPressed: aoSelecionar,
      leadingIcon: SizedBox.square(
        dimension: TamanhosDeIcone.padrao,
        child: marcado ? Icone(Icones.marcado, tamanho: TamanhosDeIcone.padrao, cor: context.cores.primaria) : null,
      ),
      style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(200, Medidas.alturaDoControle))),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _larguraMaximaDoMenu - 72),
        child: Text(
          rotulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: marcado ? const TextStyle(fontWeight: FontWeight.w600) : null,
        ),
      ),
    ),
  );
}
