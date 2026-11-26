import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/core/dominio/filtro_cadastro.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/core/http/erro_api.dart';
import 'package:obrigacoes_app/features/empresas/data/empresa_repository.dart';
import 'package:obrigacoes_app/features/empresas/presentation/lista_empresas_page.dart';

import '../../apoio.dart';

class _RepositorioFalso extends Mock implements EmpresaRepository {}

void main() {
  late _RepositorioFalso repositorio;

  setUpAll(() {
    registerFallbackValue(const FiltroCadastro());
    registerFallbackValue(empresaDeExemplo());
    registerFallbackValue(Situacao.ativo);
  });

  setUp(() => repositorio = _RepositorioFalso());

  Future<void> abrir(WidgetTester tester) => abrirTela(
    tester,
    overrides: [empresaRepositoryProvider.overrideWithValue(repositorio)],
    rotaInicial: '/empresas',
    rotas: [GoRoute(path: '/empresas', builder: (context, state) => const ListaEmpresasPage())],
  );

  Future<void> escolherInativar(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Ações de Contábil Alfa LTDA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inativar'));
    await tester.pumpAndSettle();
  }

  testWidgets('lista as empresas com CNPJ formatado e situação no feminino', (tester) async {
    when(() => repositorio.listar(any())).thenAnswer((_) async => paginaCom([empresaDeExemplo()]));

    await abrir(tester);

    expect(find.text('Contábil Alfa LTDA'), findsOneWidget);
    expect(find.text('11.222.333/0001-81 · Alfa · contato@alfa.com.br'), findsOneWidget);
    expect(find.text('Ativa'), findsOneWidget);
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('1 registro'), findsOneWidget);
  });

  testWidgets('mostra estado vazio quando não há empresas', (tester) async {
    when(() => repositorio.listar(any())).thenAnswer((_) async => paginaCom([]));

    await abrir(tester);

    expect(find.text('Nenhuma empresa encontrada'), findsOneWidget);
    expect(find.byTooltip('Página anterior'), findsNothing);
  });

  testWidgets('mostra o erro e permite tentar novamente', (tester) async {
    when(() => repositorio.listar(any()))
        .thenThrow(const ErroApi(codigo: CodigoErro.semConexao, mensagem: 'Não foi possível conectar ao servidor.'));

    await abrir(tester);
    expect(find.text('Não foi possível conectar ao servidor.'), findsOneWidget);

    when(() => repositorio.listar(any())).thenAnswer((_) async => paginaCom([empresaDeExemplo()]));
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Contábil Alfa LTDA'), findsOneWidget);
  });

  testWidgets('filtra pela situação escolhida', (tester) async {
    when(() => repositorio.listar(any())).thenAnswer((_) async => paginaCom([]));

    await abrir(tester);
    await tester.tap(find.text('Inativas'));
    await tester.pumpAndSettle();

    final filtro = verify(() => repositorio.listar(captureAny())).captured.last as FiltroCadastro;
    expect(filtro.situacao, Situacao.inativo);
  });

  testWidgets('permite voltar quando a página atual ficou vazia', (tester) async {
    when(() => repositorio.listar(any()))
        .thenAnswer((_) async => paginaCom([empresaDeExemplo()], totalItens: 21, totalPaginas: 2));
    await abrir(tester);
    when(() => repositorio.listar(any()))
        .thenAnswer((_) async => paginaCom([], numero: 1, totalItens: 20, totalPaginas: 1));

    await tester.ensureVisible(find.byTooltip('Próxima página'));
    await tester.tap(find.byTooltip('Próxima página'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma empresa encontrada'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Página anterior'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Página anterior'));
    await tester.pumpAndSettle();
    final filtro = verify(() => repositorio.listar(captureAny())).captured.last as FiltroCadastro;
    expect(filtro.pagina, 0);
  });

  testWidgets('não inativa quando o usuário cancela a confirmação', (tester) async {
    when(() => repositorio.listar(any())).thenAnswer((_) async => paginaCom([empresaDeExemplo()]));

    await abrir(tester);
    await escolherInativar(tester);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(() => repositorio.alterarSituacao(any(), any()));
  });

  testWidgets('inativa a empresa após confirmação e recarrega a lista', (tester) async {
    final empresa = empresaDeExemplo();
    when(() => repositorio.listar(any())).thenAnswer((_) async => paginaCom([empresa]));
    when(() => repositorio.alterarSituacao(any(), any()))
        .thenAnswer((_) async => empresaDeExemplo(situacao: Situacao.inativo));

    await abrir(tester);
    await escolherInativar(tester);
    expect(find.text('Inativar Contábil Alfa LTDA?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Inativar'));
    await tester.pumpAndSettle();

    verify(() => repositorio.alterarSituacao(empresa, Situacao.inativo)).called(1);
    verify(() => repositorio.listar(any())).called(2);
    expect(find.text('Empresa inativada.'), findsOneWidget);
  });
}
