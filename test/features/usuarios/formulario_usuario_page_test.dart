import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/core/widgets/campo_de_texto.dart';
import 'package:obrigacoes_app/features/usuarios/data/usuario_repository.dart';
import 'package:obrigacoes_app/features/usuarios/domain/usuario.dart';
import 'package:obrigacoes_app/features/usuarios/presentation/formulario_usuario_page.dart';

import '../../apoio.dart';

class _RepositorioFalso extends Mock implements UsuarioRepository {}

void main() {
  late _RepositorioFalso repositorio;

  setUpAll(() {
    registerFallbackValue(const DadosUsuario(nome: '', email: '', cargo: ''));
    registerFallbackValue(usuarioDeExemplo());
  });

  setUp(() => repositorio = _RepositorioFalso());

  Future<void> abrir(WidgetTester tester, {required String rota}) => abrirTela(
    tester,
    overrides: [usuarioRepositoryProvider.overrideWithValue(repositorio)],
    rotaInicial: rota,
    rotas: [
      GoRoute(
        path: '/usuarios',
        builder: (context, state) => const Scaffold(body: Text('lista de usuários')),
        routes: [
          GoRoute(path: 'novo', builder: (context, state) => const FormularioUsuarioPage()),
          GoRoute(path: ':id/editar', builder: (context, state) => const FormularioUsuarioPage(id: 1)),
        ],
      ),
    ],
  );

  Finder campo(String rotulo) => find.descendant(
    of: find.byWidgetPredicate((widget) => widget is CampoDeTexto && widget.rotulo == rotulo),
    matching: find.byType(TextFormField),
  );

  testWidgets('exige nome e e-mail válido', (tester) async {
    await abrir(tester, rota: '/usuarios/novo');

    await tester.enterText(campo('E-mail'), 'ana@escritorio');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('O nome é obrigatório.'), findsOneWidget);
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    verifyNever(() => repositorio.cadastrar(any()));
  });

  testWidgets('cadastra o usuário e volta para a lista', (tester) async {
    when(() => repositorio.cadastrar(any())).thenAnswer((_) async => usuarioDeExemplo());
    await abrir(tester, rota: '/usuarios/novo');

    await tester.enterText(campo('Nome'), 'Ana Souza');
    await tester.enterText(campo('E-mail'), 'ana@escritorio.com.br');
    await tester.enterText(campo('Cargo'), 'Analista Fiscal');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final dados = verify(() => repositorio.cadastrar(captureAny())).captured.single as DadosUsuario;
    expect((dados.nome, dados.email, dados.cargo), ('Ana Souza', 'ana@escritorio.com.br', 'Analista Fiscal'));
    expect(find.text('Usuário cadastrado.'), findsOneWidget);
  });

  testWidgets('edita o usuário carregado', (tester) async {
    final usuario = usuarioDeExemplo();
    when(() => repositorio.buscar(1)).thenAnswer((_) async => usuario);
    when(() => repositorio.atualizar(any(), any())).thenAnswer((_) async => usuario);
    await abrir(tester, rota: '/usuarios/1/editar');

    expect(find.text('ana@escritorio.com.br'), findsOneWidget);
    await tester.enterText(campo('Cargo'), 'Coordenadora Fiscal');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final dados = verify(() => repositorio.atualizar(usuario, captureAny())).captured.single as DadosUsuario;
    expect(dados.cargo, 'Coordenadora Fiscal');
    expect(find.text('Usuário atualizado.'), findsOneWidget);
  });
}
