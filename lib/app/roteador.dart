import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/pagina_nao_encontrada.dart';
import '../features/empresas/presentation/rotas_empresas.dart';
import '../features/usuarios/presentation/rotas_usuarios.dart';
import 'estrutura_navegacao.dart';

final roteadorProvider = Provider<GoRouter>((ref) {
  final roteador = GoRouter(
    initialLocation: RotasEmpresas.lista,
    redirect: (context, state) => state.uri.path == '/' ? RotasEmpresas.lista : null,
    errorBuilder: (context, state) => const PaginaNaoEncontrada(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navegacao) => EstruturaNavegacao(navegacao: navegacao),
        branches: [
          StatefulShellBranch(routes: [RotasEmpresas.rota]),
          StatefulShellBranch(routes: [RotasUsuarios.rota]),
        ],
      ),
    ],
  );
  ref.onDispose(roteador.dispose);
  return roteador;
});
