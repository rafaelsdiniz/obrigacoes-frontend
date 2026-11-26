import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/app/app.dart';
import 'package:obrigacoes_app/app/roteador.dart';
import 'package:obrigacoes_app/core/config/configuracao.dart';
import 'package:obrigacoes_app/core/dominio/filtro_cadastro.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/core/widgets/selo.dart';
import 'package:obrigacoes_app/features/empresas/data/empresa_repository.dart';
import 'package:obrigacoes_app/features/usuarios/data/usuario_repository.dart';

import 'apoio.dart';

class _Empresas extends Mock implements EmpresaRepository {}

class _Usuarios extends Mock implements UsuarioRepository {}

void main() {
  setUpAll(() async {
    registerFallbackValue(const FiltroCadastro());
    await carregarFontesDoApp();
  });

  Future<ProviderContainer> abrir(WidgetTester tester, Size tamanho, {double escalaDoTexto = 1}) async {
    final empresas = _Empresas();
    final usuarios = _Usuarios();
    when(() => empresas.listar(any()))
        .thenAnswer((_) async => paginaCom([empresaDeExemplo(), empresaDeExemplo(id: 2, situacao: Situacao.inativo)]));
    when(() => usuarios.listar(any())).thenAnswer((_) async => paginaCom([usuarioDeExemplo()]));
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = escalaDoTexto;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
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

  const telas = {'celular pequeno': Size(320, 640), 'celular': Size(400, 800), 'tablet': Size(820, 1180)};
  const telasComDesktop = {...telas, 'desktop': Size(1280, 800)};

  for (final MapEntry(key: nome, value: tamanho) in telasComDesktop.entries) {
    testWidgets('listas e formulários cabem no $nome com texto em dobro', (tester) async {
      final container = await abrir(tester, tamanho, escalaDoTexto: 2);

      for (final rota in ['/usuarios', '/empresas/nova', '/usuarios/novo']) {
        container.read(roteadorProvider).go(rota);
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    });
  }

  for (final MapEntry(key: nome, value: tamanho) in telasComDesktop.entries) {
    testWidgets('a lista de empresas atende contraste e alvos de toque no $nome', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester, tamanho);

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantica.dispose();
    });
  }

  testWidgets('no desktop o cabeçalho das colunas fica alinhado com os dados', (tester) async {
    await abrir(tester, const Size(1280, 800));

    expect(tester.getTopLeft(find.text('CNPJ')).dx, tester.getTopLeft(find.text('11.222.333/0001-81').first).dx);
    expect(tester.getTopLeft(find.text('SITUAÇÃO')).dx, tester.getTopLeft(find.byType(Selo).first).dx);
  });
}
