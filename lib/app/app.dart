import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/tema/tema.dart';
import 'roteador.dart';

class ObrigacoesApp extends ConsumerWidget {
  const ObrigacoesApp({super.key});

  static const portuguesDoBrasil = Locale('pt', 'BR');

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Obrigações',
    debugShowCheckedModeBanner: false,
    theme: Tema.claro(),
    locale: portuguesDoBrasil,
    supportedLocales: const [portuguesDoBrasil],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    routerConfig: ref.watch(roteadorProvider),
  );
}
