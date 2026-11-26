import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/formatacao/cnpj.dart';
import '../../../core/http/erro_api.dart';
import '../../../core/layout/medidas.dart';
import '../../../core/tema/tema.dart';
import '../../../core/widgets/campo_busca.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/indicador.dart';
import '../../../core/widgets/indicador_de_situacao.dart';
import '../../empresas/domain/empresa.dart';
import '../../empresas/presentation/rotas_empresas.dart';
import '../../obrigacoes/presentation/indicador_de_status.dart';
import '../../obrigacoes/presentation/rotas_obrigacoes.dart';
import '../../usuarios/domain/usuario.dart';
import '../../usuarios/presentation/rotas_usuarios.dart';
import '../domain/resultado_da_busca.dart';
import 'busca_global_providers.dart';

const _dica = 'Buscar obrigações, empresas ou usuários';

void _abrir(BuildContext context, ItemDaBusca item) => switch (item) {
  ObrigacaoEncontrada(:final obrigacao) => context.go(RotasObrigacoes.detalhe(obrigacao.id)),
  EmpresaEncontrada(:final empresa) => context.go(RotasEmpresas.edicao(empresa.id)),
  UsuarioEncontrado(:final usuario) => context.go(RotasUsuarios.edicao(usuario.id)),
};

class BuscaGlobal extends ConsumerStatefulWidget {
  const BuscaGlobal({required this.foco, super.key});

  static const largura = 440.0;
  static const larguraDosResultados = 560.0;

  final FocusNode foco;

  @override
  ConsumerState<BuscaGlobal> createState() => _BuscaGlobalState();
}

class _BuscaGlobalState extends ConsumerState<BuscaGlobal> {
  final _controlador = TextEditingController();
  final _painel = OverlayPortalController();
  final _elo = LayerLink();
  final _grupo = Object();
  Timer? _temporizador;
  String _termo = '';
  int _selecionado = 0;

  @override
  void initState() {
    super.initState();
    widget.foco.addListener(_aoMudarFoco);
  }

  @override
  void dispose() {
    widget.foco.removeListener(_aoMudarFoco);
    _temporizador?.cancel();
    _controlador.dispose();
    super.dispose();
  }

  void _aoMudarFoco() {
    if (widget.foco.hasFocus && _termo.length >= tamanhoMinimoDaBusca) {
      _painel.show();
    }
    setState(() {});
  }

  void _aoDigitar(String texto) {
    _temporizador?.cancel();
    _temporizador = Timer(CampoBusca.espera, () {
      setState(() {
        _termo = texto.trim();
        _selecionado = 0;
      });
      _termo.length >= tamanhoMinimoDaBusca ? _painel.show() : _painel.hide();
    });
  }

  void _fechar() {
    _temporizador?.cancel();
    _painel.hide();
  }

  void _limpar() {
    _controlador.clear();
    setState(() => _termo = '');
    _fechar();
  }

  List<ItemDaBusca> get _itens => _termo.length < tamanhoMinimoDaBusca
      ? const []
      : ref.read(resultadoDaBuscaProvider(_termo)).value?.itens ?? const [];

  void _abrirItem(ItemDaBusca item) {
    _limpar();
    widget.foco.unfocus();
    _abrir(context, item);
  }

  KeyEventResult _aoTeclar(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final itens = _itens;
    switch (evento.logicalKey) {
      case LogicalKeyboardKey.escape:
        _limpar();
        widget.foco.unfocus();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown when itens.isNotEmpty:
        setState(() => _selecionado = (_selecionado + 1) % itens.length);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp when itens.isNotEmpty:
        setState(() => _selecionado = (_selecionado - 1 + itens.length) % itens.length);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  void _aoConfirmar(String _) {
    final itens = _itens;
    if (itens.isNotEmpty) {
      _abrirItem(itens[_selecionado.clamp(0, itens.length - 1)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return OverlayPortal(
      controller: _painel,
      overlayChildBuilder: (context) => CompositedTransformFollower(
        link: _elo,
        targetAnchor: Alignment.bottomLeft,
        offset: const Offset(0, 6),
        child: Align(
          alignment: Alignment.topLeft,
          child: TapRegion(
            groupId: _grupo,
            onTapOutside: (_) => _fechar(),
            child: SizedBox(
              width: BuscaGlobal.larguraDosResultados,
              child: Material(
                color: cores.superficieMaisBaixa,
                elevation: 10,
                shadowColor: Colors.black38,
                shape: RoundedRectangleBorder(
                  borderRadius: Raios.cartao,
                  side: BorderSide(color: cores.borda),
                ),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
                  child: ResultadosDaBusca(
                    termo: _termo,
                    selecionado: _selecionado,
                    aoAbrir: _abrirItem,
                    comAtalhos: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      child: CompositedTransformTarget(
        link: _elo,
        child: TapRegion(
          groupId: _grupo,
          child: SizedBox(
            width: BuscaGlobal.largura,
            child: Focus(
              onKeyEvent: _aoTeclar,
              canRequestFocus: false,
              skipTraversal: true,
              child: Semantics(
                textField: true,
                label: 'Busca global',
                child: TextField(
                  controller: _controlador,
                  focusNode: widget.foco,
                  groupId: _grupo,
                  onChanged: _aoDigitar,
                  onSubmitted: _aoConfirmar,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: _dica,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icone(Icones.buscar, tamanho: TamanhosDeIcone.padrao, cor: cores.contorno),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 42),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _TeclaDeAtalho(_controlador.text.isEmpty ? '/' : 'Esc'),
                    ),
                    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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

Future<void> abrirBuscaEmTelaCheia(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => const Dialog.fullscreen(child: _TelaDeBusca()),
);

class _TelaDeBusca extends StatefulWidget {
  const _TelaDeBusca();

  @override
  State<_TelaDeBusca> createState() => _TelaDeBuscaState();
}

class _TelaDeBuscaState extends State<_TelaDeBusca> {
  Timer? _temporizador;
  String _termo = '';

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  void _aoDigitar(String texto) {
    _temporizador?.cancel();
    _temporizador = Timer(CampoBusca.espera, () => setState(() => _termo = texto.trim()));
  }

  void _abrirItem(ItemDaBusca item) {
    Navigator.of(context).pop();
    _abrir(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Scaffold(
      backgroundColor: cores.fundo,
      body: SafeArea(
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: cores.superficieMaisBaixa,
                border: Border(bottom: BorderSide(color: cores.borda)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Fechar busca',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icone(Icones.voltar, tamanho: TamanhosDeIcone.grande),
                    ),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        onChanged: _aoDigitar,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: _dica,
                          isDense: true,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icone(Icones.buscar, tamanho: TamanhosDeIcone.padrao, cor: cores.contorno),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 42),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _termo.length < tamanhoMinimoDaBusca
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Digite pelo menos $tamanhoMinimoDaBusca letras para buscar.',
                        style: Tema.textoSecundario(context),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ResultadosDaBusca(termo: _termo, selecionado: -1, aoAbrir: _abrirItem),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultadosDaBusca extends ConsumerWidget {
  const ResultadosDaBusca({
    required this.termo,
    required this.selecionado,
    required this.aoAbrir,
    this.comAtalhos = false,
    super.key,
  });

  final String termo;
  final int selecionado;
  final ValueChanged<ItemDaBusca> aoAbrir;
  final bool comAtalhos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (termo.length < tamanhoMinimoDaBusca) {
      return const SizedBox.shrink();
    }
    final tema = Theme.of(context).textTheme;
    return ref
        .watch(resultadoDaBuscaProvider(termo))
        .when(
          skipLoadingOnReload: true,
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(minHeight: 2, semanticsLabel: 'Buscando'),
          ),
          error: (erro, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              liveRegion: true,
              child: Text(
                erro is ErroApi ? erro.mensagem : 'Não foi possível buscar agora.',
                style: tema.bodySmall?.copyWith(color: context.cores.erro),
              ),
            ),
          ),
          data: (resultado) {
            var indice = 0;
            Widget item(ItemDaBusca item) =>
                _ItemDoResultado(item: item, termo: termo, selecionado: indice++ == selecionado, aoAbrir: aoAbrir);
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              children: [
                Semantics(
                  liveRegion: true,
                  label: resultado.total == 1 ? '1 resultado' : '${resultado.total} resultados',
                  child: const SizedBox.shrink(),
                ),
                _Grupo(
                  titulo: 'Obrigações',
                  vazio: 'Nenhuma obrigação encontrada',
                  itens: [for (final obrigacao in resultado.obrigacoes) item(ObrigacaoEncontrada(obrigacao))],
                ),
                _Grupo(
                  titulo: 'Empresas',
                  vazio: 'Nenhuma empresa encontrada',
                  itens: [for (final empresa in resultado.empresas) item(EmpresaEncontrada(empresa))],
                ),
                _Grupo(
                  titulo: 'Usuários',
                  vazio: 'Nenhum usuário encontrado',
                  itens: [for (final usuario in resultado.usuarios) item(UsuarioEncontrado(usuario))],
                ),
                if (comAtalhos) const _LegendaDeAtalhos(),
              ],
            );
          },
        );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo({required this.titulo, required this.vazio, required this.itens});

  final String titulo;
  final String vazio;
  final List<Widget> itens;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
          child: Semantics(header: true, child: Text(titulo.toUpperCase(), style: tema.labelMedium)),
        ),
        if (itens.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(vazio, style: tema.bodySmall),
          )
        else
          ...itens,
      ],
    );
  }
}

class _ItemDoResultado extends StatelessWidget {
  const _ItemDoResultado({required this.item, required this.termo, required this.selecionado, required this.aoAbrir});

  final ItemDaBusca item;
  final String termo;
  final bool selecionado;
  final ValueChanged<ItemDaBusca> aoAbrir;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final tema = Theme.of(context).textTheme;
    final (icone, tom, titulo, detalhe, selo) = switch (item) {
      ObrigacaoEncontrada(:final obrigacao) => (
        Icones.obrigacoes,
        TomDoIndicador.informacao,
        obrigacao.titulo,
        '${obrigacao.empresa.razaoSocial} · ${obrigacao.tipo.rotulo}',
        IndicadorDeStatus(obrigacao.status) as Widget,
      ),
      EmpresaEncontrada(:final empresa) => (
        Icones.empresas,
        TomDoIndicador.neutro,
        empresa.razaoSocial,
        Cnpj.formatar(empresa.cnpj),
        IndicadorDeSituacao(situacao: empresa.situacao, termos: termosDaEmpresa),
      ),
      UsuarioEncontrado(:final usuario) => (
        Icones.usuarios,
        TomDoIndicador.neutro,
        usuario.nome,
        usuario.email,
        IndicadorDeSituacao(situacao: usuario.situacao, termos: termosDoUsuario),
      ),
    };
    final ehDocumento = item is EmpresaEncontrada;
    return Semantics(
      button: true,
      selected: selecionado,
      child: Material(
        color: selecionado ? cores.superficieBaixa : Colors.transparent,
        borderRadius: Raios.controle,
        child: InkWell(
          onTap: () => aoAbrir(item),
          borderRadius: Raios.controle,
          hoverColor: cores.realce,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Medidas.alturaDoControle),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(color: tom.forte(cores), borderRadius: Raios.controle),
                    child: SizedBox.square(
                      dimension: 32,
                      child: Center(
                        child: Icone(icone, tamanho: TamanhosDeIcone.padrao, cor: tom.sobreForte(cores)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          _destacar(titulo, termo, tema.labelLarge ?? const TextStyle()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text.rich(
                          _destacar(
                            detalhe,
                            termo,
                            ehDocumento
                                ? Tema.mono(context, cor: cores.textoVariante)
                                : tema.bodySmall ?? const TextStyle(),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  selo,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

TextSpan _destacar(String texto, String termo, TextStyle estilo) {
  final inicio = texto.toLowerCase().indexOf(termo.toLowerCase());
  if (termo.isEmpty || inicio < 0) {
    return TextSpan(text: texto, style: estilo);
  }
  final fim = inicio + termo.length;
  return TextSpan(
    style: estilo,
    children: [
      TextSpan(text: texto.substring(0, inicio)),
      TextSpan(
        text: texto.substring(inicio, fim),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      TextSpan(text: texto.substring(fim)),
    ],
  );
}

class _LegendaDeAtalhos extends StatelessWidget {
  const _LegendaDeAtalhos();

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12);
    Widget atalho(String tecla, String acao) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TeclaDeAtalho(tecla),
        const SizedBox(width: 6),
        Text(acao, style: estilo),
      ],
    );
    return ExcludeSemantics(
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.cores.bordaSuave)),
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [atalho('↑↓', 'navegar'), atalho('Enter', 'abrir'), atalho('Esc', 'fechar')],
        ),
      ),
    );
  }
}

class _TeclaDeAtalho extends StatelessWidget {
  const _TeclaDeAtalho(this.tecla);

  final String tecla;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cores.superficieMaisBaixa,
          borderRadius: Raios.controle,
          border: Border.all(color: cores.borda),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          child: Text(tecla, style: Tema.mono(context, cor: cores.textoVariante, tamanho: 11)),
        ),
      ),
    );
  }
}
