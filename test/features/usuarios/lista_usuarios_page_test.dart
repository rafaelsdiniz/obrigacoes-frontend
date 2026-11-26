import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/core/dominio/filtro_cadastro.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/features/usuarios/data/usuario_repository.dart';
import 'package:obrigacoes_app/features/usuarios/presentation/lista_usuarios_page.dart';

import '../../apoio.dart';

class _RepositorioFalso extends Mock implements UsuarioRepository {}

void main() {
  late _RepositorioFalso repositorio;

  setUpAll(() {
    registerFallbackValue(const FiltroCadastro());
    registerFallbackValue(usuarioDeExemplo());
    registerFallbackValue(Situacao.ativo);
  });

  setUp(() => repositorio = _RepositorioFalso());

  Future<void> abrir(WidgetTester tester) => abrirTela(
    tester,
    overrides: [usuarioRepositoryProvider.overrideWithValue(repositorio)],
    rotaInicial: '/usuarios',
    rotas: [GoRoute(path: '/usuarios', builder: (context, state) => const ListaUsuariosPage())],
  );

  testWidgets('lista os usuários com cargo e situação no masculino', (tester) async {
    when(() => repositorio.listar(any())).thenAnswer((_) async => paginaCom([usuarioDeExemplo()]));

    await abrir(tester);

    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('ana@escritorio.com.br · Analista Fiscal'), findsOneWidget);
    expect(find.text('Ativo'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);
  });

  testWidgets('reativa um usuário inativo sem pedir confirmação', (tester) async {
    final usuario = usuarioDeExemplo(situacao: Situacao.inativo);
    when(() => repositorio.listar(any())).thenAnswer((_) async => paginaCom([usuario]));
    when(() => repositorio.alterarSituacao(any(), any())).thenAnswer((_) async => usuarioDeExemplo());

    await abrir(tester);
    await tester.tap(find.byTooltip('Ações de Ana Souza'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ativar'));
    await tester.pumpAndSettle();

    verify(() => repositorio.alterarSituacao(usuario, Situacao.ativo)).called(1);
    expect(find.text('Usuário ativado.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
