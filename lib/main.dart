import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'core/config/configuracao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final configuracao = await Configuracao.carregar();
  runApp(
    ProviderScope(
      overrides: [configuracaoProvider.overrideWithValue(configuracao)],
      retry: (tentativas, erro) => null,
      child: const ObrigacoesApp(),
    ),
  );
}
