import 'package:go_router/go_router.dart';

import 'painel_page.dart';

abstract final class RotasPainel {
  static const inicio = '/painel';

  static final rota = GoRoute(path: inicio, builder: (context, state) => const PainelPage());
}
