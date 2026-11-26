import 'package:go_router/go_router.dart';

import '../../../core/widgets/pagina_nao_encontrada.dart';
import 'detalhe_obrigacao_page.dart';
import 'formulario_obrigacao_page.dart';
import 'lista_obrigacoes_page.dart';

abstract final class RotasObrigacoes {
  static const lista = '/obrigacoes';
  static const nova = '$lista/nova';

  static String detalhe(int id) => '$lista/$id';

  static String edicao(int id) => '$lista/$id/editar';

  static final rota = GoRoute(
    path: lista,
    builder: (context, state) => const ListaObrigacoesPage(),
    routes: [
      GoRoute(path: 'nova', builder: (context, state) => const FormularioObrigacaoPage()),
      GoRoute(
        path: ':id',
        builder: (context, state) => switch (int.tryParse(state.pathParameters['id'] ?? '')) {
          final id? => DetalheObrigacaoPage(id: id),
          null => const PaginaNaoEncontrada(),
        },
        routes: [
          GoRoute(
            path: 'editar',
            builder: (context, state) => switch (int.tryParse(state.pathParameters['id'] ?? '')) {
              final id? => FormularioObrigacaoPage(id: id),
              null => const PaginaNaoEncontrada(),
            },
          ),
        ],
      ),
    ],
  );
}
