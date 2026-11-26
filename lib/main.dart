import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'core/config/configuracao.dart';
import 'core/tema/preferencia_de_tema.dart';

const _arquivosDeLicencaDasFontes = {
  'Inter': 'assets/fontes/inter/LICENSE.txt',
  'Spline Sans Mono': 'assets/fontes/spline-sans-mono/OFL.txt',
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  LicenseRegistry.addLicense(_licencasDeFontes);
  final configuracao = await Configuracao.carregar();
  final armazenamentoDoTema = ArmazenamentoDoTemaLocal();
  final tema = await armazenamentoDoTema.ler();
  runApp(
    ProviderScope(
      overrides: [
        configuracaoProvider.overrideWithValue(configuracao),
        armazenamentoDoTemaProvider.overrideWithValue(armazenamentoDoTema),
        temaInicialProvider.overrideWithValue(tema),
      ],
      retry: (tentativas, erro) => null,
      child: const ObrigacoesApp(),
    ),
  );
}

Stream<LicenseEntry> _licencasDeFontes() async* {
  for (final MapEntry(key: familia, value: arquivo) in _arquivosDeLicencaDasFontes.entries) {
    yield LicenseEntryWithLineBreaks([familia], await rootBundle.loadString(arquivo));
  }
}
