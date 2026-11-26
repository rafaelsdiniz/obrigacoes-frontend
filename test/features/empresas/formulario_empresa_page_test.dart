import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/core/http/erro_api.dart';
import 'package:obrigacoes_app/core/widgets/campo_de_texto.dart';
import 'package:obrigacoes_app/features/empresas/data/empresa_repository.dart';
import 'package:obrigacoes_app/features/empresas/domain/empresa.dart';
import 'package:obrigacoes_app/features/empresas/presentation/formulario_empresa_page.dart';

import '../../apoio.dart';

class _RepositorioFalso extends Mock implements EmpresaRepository {}

const _erroDeEmail = ErroApi(
  codigo: CodigoErro.validacao,
  mensagem: 'Um ou mais campos estão inválidos.',
  errosPorCampo: {'email': 'O e-mail informado é inválido.'},
);

void main() {
  late _RepositorioFalso repositorio;

  setUpAll(() {
    registerFallbackValue(const DadosEmpresa(razaoSocial: '', nomeFantasia: '', cnpj: '', email: '', telefone: ''));
    registerFallbackValue(empresaDeExemplo());
  });

  setUp(() => repositorio = _RepositorioFalso());

  Future<void> abrir(WidgetTester tester, {required String rota}) => abrirTela(
    tester,
    overrides: [empresaRepositoryProvider.overrideWithValue(repositorio)],
    rotaInicial: rota,
    rotas: [
      GoRoute(
        path: '/empresas',
        builder: (context, state) => const Scaffold(body: Text('lista de empresas')),
        routes: [
          GoRoute(path: 'nova', builder: (context, state) => const FormularioEmpresaPage()),
          GoRoute(
            path: ':id/editar',
            builder: (context, state) => FormularioEmpresaPage(id: int.parse(state.pathParameters['id']!)),
          ),
        ],
      ),
    ],
  );

  Finder campo(String rotulo) => find.descendant(
    of: find.byWidgetPredicate((widget) => widget is CampoDeTexto && widget.rotulo == rotulo),
    matching: find.byType(TextFormField),
  );

  Future<void> preencherObrigatorios(WidgetTester tester) async {
    await tester.enterText(campo('Razão social'), '  Contábil Alfa LTDA ');
    await tester.enterText(campo('CNPJ'), '11222333000181');
  }

  Future<void> salvar(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
  }

  testWidgets('valida os campos obrigatórios e o CNPJ antes de enviar', (tester) async {
    await abrir(tester, rota: '/empresas/nova');

    await tester.enterText(campo('CNPJ'), '11222333000182');
    await salvar(tester);

    expect(find.text('A razão social é obrigatória.'), findsOneWidget);
    expect(find.text('Informe um CNPJ válido.'), findsOneWidget);
    verifyNever(() => repositorio.cadastrar(any()));
  });

  testWidgets('cadastra a empresa e volta para a lista', (tester) async {
    when(() => repositorio.cadastrar(any())).thenAnswer((_) async => empresaDeExemplo());
    await abrir(tester, rota: '/empresas/nova');

    await preencherObrigatorios(tester);
    await salvar(tester);

    final dados = verify(() => repositorio.cadastrar(captureAny())).captured.single as DadosEmpresa;
    expect(dados.razaoSocial, 'Contábil Alfa LTDA');
    expect(dados.cnpj, '11.222.333/0001-81');
    expect(find.text('lista de empresas'), findsOneWidget);
    expect(find.text('Empresa cadastrada.'), findsOneWidget);
  });

  testWidgets('mostra no campo o erro devolvido pela API e reenvia no primeiro clique', (tester) async {
    when(() => repositorio.cadastrar(any())).thenThrow(_erroDeEmail);
    await abrir(tester, rota: '/empresas/nova');
    await preencherObrigatorios(tester);

    await salvar(tester);
    expect(find.text('O e-mail informado é inválido.'), findsOneWidget);

    when(() => repositorio.cadastrar(any())).thenAnswer((_) async => empresaDeExemplo());
    await tester.enterText(campo('Nome fantasia'), 'Alfa');
    await salvar(tester);

    verify(() => repositorio.cadastrar(any())).called(2);
    expect(find.text('lista de empresas'), findsOneWidget);
  });

  testWidgets('mostra a duplicidade de CNPJ no campo, sem oferecer recarregar', (tester) async {
    when(() => repositorio.cadastrar(any())).thenThrow(
      const ErroApi(
        codigo: CodigoErro.conflito,
        mensagem: 'Já existe uma empresa cadastrada com este CNPJ.',
        errosPorCampo: {'cnpj': 'Já existe uma empresa cadastrada com este CNPJ.'},
      ),
    );
    await abrir(tester, rota: '/empresas/nova');

    await preencherObrigatorios(tester);
    await salvar(tester);

    expect(find.text('Já existe uma empresa cadastrada com este CNPJ.'), findsNWidgets(2));
    expect(find.text('Recarregar'), findsNothing);
  });

  testWidgets('envia uma única vez mesmo com Enter repetido', (tester) async {
    when(() => repositorio.cadastrar(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return empresaDeExemplo();
    });
    await abrir(tester, rota: '/empresas/nova');
    await preencherObrigatorios(tester);

    await tester.showKeyboard(campo('Telefone'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    verify(() => repositorio.cadastrar(any())).called(1);
  });

  testWidgets('edita a empresa enviando a versão lida', (tester) async {
    final empresa = empresaDeExemplo(id: 7);
    when(() => repositorio.buscar(7)).thenAnswer((_) async => empresa);
    when(() => repositorio.atualizar(any(), any())).thenAnswer((_) async => empresa);
    await abrir(tester, rota: '/empresas/7/editar');

    expect(find.text('11.222.333/0001-81'), findsOneWidget);
    await tester.enterText(campo('Nome fantasia'), 'Alfa Contabilidade');
    await salvar(tester);

    final capturados = verify(() => repositorio.atualizar(captureAny(), captureAny())).captured;
    expect(capturados.first, same(empresa));
    expect((capturados.last as DadosEmpresa).nomeFantasia, 'Alfa Contabilidade');
    expect(find.text('Empresa atualizada.'), findsOneWidget);
    verify(() => repositorio.buscar(7)).called(1);
  });

  testWidgets('recarrega a versão atual quando outra pessoa alterou a empresa', (tester) async {
    when(() => repositorio.buscar(7)).thenAnswer((_) async => empresaDeExemplo(id: 7));
    when(() => repositorio.atualizar(any(), any()))
        .thenThrow(const ErroApi(codigo: CodigoErro.conflito, mensagem: 'O registro foi alterado por outra operação.'));
    await abrir(tester, rota: '/empresas/7/editar');
    await salvar(tester);

    when(() => repositorio.buscar(7))
        .thenAnswer((_) async => empresaDeExemplo(id: 7, versao: 1, nomeFantasia: 'Alfa Atualizada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recarregar'));
    await tester.pumpAndSettle();

    expect(find.text('Alfa Atualizada'), findsOneWidget);
  });

  testWidgets('informa quando a empresa a editar não existe', (tester) async {
    when(() => repositorio.buscar(99))
        .thenThrow(const ErroApi(codigo: CodigoErro.recursoNaoEncontrado, mensagem: 'Não existe empresa com o id 99.'));
    await abrir(tester, rota: '/empresas/99/editar');

    expect(find.text('Registro não encontrado'), findsOneWidget);
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('lista de empresas'), findsOneWidget);
  });
}
