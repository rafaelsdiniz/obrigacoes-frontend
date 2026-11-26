import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../http/pagina.dart';
import 'estado_carregando.dart';
import 'estado_erro.dart';
import 'estado_vazio.dart';

class ListaPaginada<T> extends StatelessWidget {
  const ListaPaginada({
    required this.estado,
    required this.itemBuilder,
    required this.vazio,
    required this.aoMudarPagina,
    required this.aoTentarNovamente,
    super.key,
  });

  static const espacoParaBotaoFlutuante = 88.0;

  final AsyncValue<Pagina<T>> estado;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final EstadoVazio vazio;
  final ValueChanged<int> aoMudarPagina;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) => estado.when(
    skipLoadingOnReload: true,
    loading: () => const EstadoCarregando(),
    error: (erro, _) => EstadoErro(erro: erro, aoTentarNovamente: aoTentarNovamente),
    data: (pagina) => Column(
      children: [
        SizedBox(height: 4, child: estado.isLoading ? const LinearProgressIndicator() : null),
        Expanded(
          child: pagina.vazia
              ? vazio
              : ListView.separated(
                  padding: const EdgeInsets.only(top: 4, bottom: espacoParaBotaoFlutuante),
                  itemCount: pagina.itens.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, indice) => itemBuilder(context, pagina.itens[indice]),
                ),
        ),
        if (!pagina.vazia || pagina.temAnterior) _ControlePaginacao(pagina: pagina, aoMudarPagina: aoMudarPagina),
      ],
    ),
  );
}

class _ControlePaginacao extends StatelessWidget {
  const _ControlePaginacao({required this.pagina, required this.aoMudarPagina});

  static const _espacoDoBotaoFlutuanteCompacto = 72.0;

  final Pagina<Object?> pagina;
  final ValueChanged<int> aoMudarPagina;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8, right: _espacoDoBotaoFlutuanteCompacto),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Página anterior',
          onPressed: pagina.temAnterior ? () => aoMudarPagina(pagina.numero - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('${pagina.numero + 1} de ${math.max(pagina.totalPaginas, pagina.numero + 1)}'),
        IconButton(
          tooltip: 'Próxima página',
          onPressed: pagina.temProxima ? () => aoMudarPagina(pagina.numero + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            pagina.totalItens == 1 ? '1 registro' : '${pagina.totalItens} registros',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
