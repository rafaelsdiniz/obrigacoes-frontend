import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/core/tema/preferencia_de_tema.dart';

import '../../apoio.dart';

void main() {
  test('começa no tema salvo e alterna para o oposto do brilho atual, salvando a escolha', () async {
    final armazenamento = ArmazenamentoDoTemaEmMemoria();
    final container = ProviderContainer(
      overrides: [
        armazenamentoDoTemaProvider.overrideWithValue(armazenamento),
        temaInicialProvider.overrideWithValue(ThemeMode.light),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(temaProvider), ThemeMode.light);

    await container.read(temaProvider.notifier).alternar(Brightness.light);
    expect(container.read(temaProvider), ThemeMode.dark);
    expect(armazenamento.salvo, ThemeMode.dark);

    await container.read(temaProvider.notifier).alternar(Brightness.dark);
    expect(container.read(temaProvider), ThemeMode.light);
    expect(armazenamento.salvo, ThemeMode.light);
  });

  testWidgets('o botão da barra superior troca o tema do aplicativo', (tester) async {
    registrarValoresPadrao();
    await abrirApp(tester, tamanho: const Size(1280, 800));
    BuildContext contexto() => tester.element(find.text('Painel').last);

    expect(Theme.of(contexto()).brightness, Brightness.light);

    await tester.tap(find.byTooltip('Usar tema escuro'));
    await tester.pumpAndSettle();

    expect(Theme.of(contexto()).brightness, Brightness.dark);
    expect(find.byTooltip('Usar tema claro'), findsOneWidget);
  });
}
