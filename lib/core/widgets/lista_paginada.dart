import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../http/pagina.dart';
import '../layout/medidas.dart';
import 'estado_carregando.dart';
import 'estado_erro.dart';
import 'estado_vazio.dart';
import 'grupo.dart';
import 'linha_de_cadastro.dart';

class ListaPaginada<T> extends StatelessWidget {
  const ListaPaginada({
    required this.estado,
    required this.itemBuilder,
    required this.vazio,
    required this.aoMudarPagina,
    required this.aoTentarNovamente,
    this.cabecalho,
    super.key,
  });

  final AsyncValue<Pagina<T>> estado;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final EstadoVazio vazio;
  final Widget? cabecalho;
  final ValueChanged<int> aoMudarPagina;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) => estado.when(
    skipLoadingOnReload: true,
    loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 64), child: EstadoCarregando()),
    error: (erro, _) => Grupo(
      child: EstadoErro(erro: erro, aoTentarNovamente: aoTentarNovamente),
    ),
    data: (pagina) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 3, child: estado.isLoading ? const LinearProgressIndicator() : null),
        const SizedBox(height: 8),
        Grupo(
          child: pagina.vazia
              ? vazio
              : LayoutBuilder(
                  builder: (context, restricoes) => Column(
                    children: [
                      if (cabecalho case final cabecalho? when restricoes.maxWidth >= Medidas.larguraParaColunas) ...[
                        cabecalho,
                        const Divider(),
                      ],
                      for (final (indice, item) in pagina.itens.indexed) ...[
                        if (indice > 0) const Divider(indent: LinhaDeCadastro.recuoDoSeparador),
                        itemBuilder(context, item),
                      ],
                    ],
                  ),
                ),
        ),
        if (!pagina.vazia || pagina.temAnterior) _ControlePaginacao(pagina: pagina, aoMudarPagina: aoMudarPagina),
      ],
    ),
  );
}

class _ControlePaginacao extends StatelessWidget {
  const _ControlePaginacao({required this.pagina, required this.aoMudarPagina});

  static const _larguraMaximaDoIndicador = 120.0;

  final Pagina<Object?> pagina;
  final ValueChanged<int> aoMudarPagina;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              pagina.totalItens == 1 ? '1 registro' : '${pagina.totalItens} registros',
              style: tema.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Página anterior',
            onPressed: pagina.temAnterior ? () => aoMudarPagina(pagina.numero - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _larguraMaximaDoIndicador),
            child: Text(
              'Página ${pagina.numero + 1} de ${math.max(pagina.totalPaginas, pagina.numero + 1)}',
              style: tema.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Próxima página',
            onPressed: pagina.temProxima ? () => aoMudarPagina(pagina.numero + 1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
