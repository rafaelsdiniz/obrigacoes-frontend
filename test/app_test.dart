import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/app/app.dart';
import 'package:obrigacoes_app/app/roteador.dart';
import 'package:obrigacoes_app/core/config/configuracao.dart';
import 'package:obrigacoes_app/core/dominio/filtro_cadastro.dart';
import 'package:obrigacoes_app/features/empresas/data/empresa_repository.dart';
import 'package:obrigacoes_app/features/usuarios/data/usuario_repository.dart';

import 'apoio.dart';

class _Empresas extends Mock implements EmpresaRepository {}

class _Usuarios extends Mock implements UsuarioRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const FiltroCadastro()));

  Future<ProviderContainer> abrir(WidgetTester tester, Size tamanho) async {
    final empresas = _Empresas();
    final usuarios = _Usuarios();
    when(() => empresas.listar(any())).thenAnswer((_) async => paginaCom([empresaDeExemplo()]));
    when(() => usuarios.listar(any())).thenAnswer((_) async => paginaCom([usuarioDeExemplo()]));
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configuracaoProvider.overrideWithValue(Configuracao('http://localhost:8080')),
          empresaRepositoryProvider.overrideWithValue(empresas),
          usuarioRepositoryProvider.overrideWithValue(usuarios),
        ],
        retry: (tentativas, erro) => null,
        child: const ObrigacoesApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(ObrigacoesApp)));
  }

  testWidgets('abre em empresas e navega para usuários pela barra lateral em telas largas', (tester) async {
    await abrir(tester, const Size(1280, 800));

    expect(find.bySemanticsLabel('Player Contabilidade'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Contábil Alfa LTDA'), findsOneWidget);

    await tester.tap(find.widgetWithText(InkWell, 'Usuários'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Souza'), findsOneWidget);
  });

  testWidgets('usa a barra inferior e o botão compacto em telas estreitas', (tester) async {
    await abrir(tester, const Size(400, 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('GESTÃO'), findsNothing);
    expect(find.byTooltip('Nova empresa'), findsOneWidget);
  });

  testWidgets('tocar na seção atual volta para a lista', (tester) async {
    await abrir(tester, const Size(1280, 800));

    await tester.tap(find.text('Nova empresa'));
    await tester.pumpAndSettle();
    expect(find.text('Razão social *'), findsOneWidget);

    await tester.tap(find.widgetWithText(InkWell, 'Empresas'));
    await tester.pumpAndSettle();
    expect(find.text('Contábil Alfa LTDA'), findsOneWidget);
  });

  testWidgets('mostra página não encontrada para endereços desconhecidos', (tester) async {
    final container = await abrir(tester, const Size(1280, 800));

    container.read(roteadorProvider).go('/empresas/abc/editar');
    await tester.pumpAndSettle();
    expect(find.text('Página não encontrada'), findsOneWidget);

    container.read(roteadorProvider).go('/nao-existe');
    await tester.pumpAndSettle();
    expect(find.text('Página não encontrada'), findsOneWidget);
  });
}
