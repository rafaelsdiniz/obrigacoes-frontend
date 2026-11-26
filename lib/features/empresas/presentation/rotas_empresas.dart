import 'package:go_router/go_router.dart';

import '../../../core/widgets/pagina_nao_encontrada.dart';
import 'formulario_empresa_page.dart';
import 'lista_empresas_page.dart';

abstract final class RotasEmpresas {
  static const lista = '/empresas';
  static const nova = '$lista/nova';

  static String edicao(int id) => '$lista/$id/editar';

  static final rota = GoRoute(
    path: lista,
    builder: (context, state) => const ListaEmpresasPage(),
    routes: [
      GoRoute(path: 'nova', builder: (context, state) => const FormularioEmpresaPage()),
      GoRoute(
        path: ':id/editar',
        builder: (context, state) => switch (int.tryParse(state.pathParameters['id'] ?? '')) {
          final id? => FormularioEmpresaPage(id: id),
          null => const PaginaNaoEncontrada(),
        },
      ),
    ],
  );
}
