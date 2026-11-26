import 'package:go_router/go_router.dart';

import '../../../core/widgets/pagina_nao_encontrada.dart';
import 'formulario_usuario_page.dart';
import 'lista_usuarios_page.dart';

abstract final class RotasUsuarios {
  static const lista = '/usuarios';
  static const novo = '$lista/novo';

  static String edicao(int id) => '$lista/$id/editar';

  static final rota = GoRoute(
    path: lista,
    builder: (context, state) => const ListaUsuariosPage(),
    routes: [
      GoRoute(path: 'novo', builder: (context, state) => const FormularioUsuarioPage()),
      GoRoute(
        path: ':id/editar',
        builder: (context, state) => switch (int.tryParse(state.pathParameters['id'] ?? '')) {
          final id? => FormularioUsuarioPage(id: id),
          null => const PaginaNaoEncontrada(),
        },
      ),
    ],
  );
}
