import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/app/app.dart';
import 'package:obrigacoes_app/core/config/configuracao.dart';
import 'package:obrigacoes_app/core/dominio/filtro_cadastro.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/core/formatacao/datas.dart';
import 'package:obrigacoes_app/core/http/pagina.dart';
import 'package:obrigacoes_app/core/tema/tema.dart';
import 'package:obrigacoes_app/features/empresas/data/empresa_repository.dart';
import 'package:obrigacoes_app/features/empresas/domain/empresa.dart';
import 'package:obrigacoes_app/features/obrigacoes/data/obrigacao_repository.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/filtro_obrigacoes.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/historico_de_status.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/obrigacao.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/resumo_obrigacoes.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/status_obrigacao.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/tipo_obrigacao.dart';
import 'package:obrigacoes_app/features/usuarios/data/usuario_repository.dart';
import 'package:obrigacoes_app/features/usuarios/domain/usuario.dart';

Empresa empresaDeExemplo({int id = 1, Situacao situacao = Situacao.ativo, int versao = 0, String? nomeFantasia}) =>
    Empresa(
      id: id,
      razaoSocial: 'Contábil Alfa LTDA',
      nomeFantasia: nomeFantasia ?? 'Alfa',
      cnpj: '11222333000181',
      email: 'contato@alfa.com.br',
      telefone: '(63) 3333-4444',
      situacao: situacao,
      versao: versao,
    );

Usuario usuarioDeExemplo({int id = 1, Situacao situacao = Situacao.ativo}) => Usuario(
  id: id,
  nome: 'Ana Souza',
  email: 'ana@escritorio.com.br',
  cargo: 'Analista Fiscal',
  situacao: situacao,
  versao: 0,
);

Pagina<T> paginaCom<T>(List<T> itens, {int numero = 0, int? totalItens, int totalPaginas = 1}) =>
    Pagina(itens: itens, numero: numero, totalItens: totalItens ?? itens.length, totalPaginas: totalPaginas);

Future<void> abrirTela(
  WidgetTester tester, {
  required List<Override> overrides,
  required String rotaInicial,
  required List<RouteBase> rotas,
}) async {
  final roteador = GoRouter(initialLocation: rotaInicial, routes: rotas);
  addTearDown(roteador.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      retry: (tentativas, erro) => null,
      child: MaterialApp.router(theme: Tema.claro(), routerConfig: roteador),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> carregarFontesDoApp() async {
  Future<void> carregar(String familia, List<String> arquivos) async {
    final carregador = FontLoader(familia);
    for (final arquivo in arquivos) {
      carregador.addFont(Future.value(ByteData.sublistView(File('assets/fontes/inter/$arquivo').readAsBytesSync())));
    }
    await carregador.load();
  }

  await carregar('Inter', ['Inter-Regular.ttf', 'Inter-Medium.ttf', 'Inter-SemiBold.ttf', 'Inter-Bold.ttf']);
  await carregar('InterDisplay', ['InterDisplay-Bold.ttf']);
}

class EmpresasFalsas extends Mock implements EmpresaRepository {}

class UsuariosFalsos extends Mock implements UsuarioRepository {}

class ObrigacoesFalsas extends Mock implements ObrigacaoRepository {}

void registrarValoresPadrao() {
  registerFallbackValue(const FiltroCadastro());
  registerFallbackValue(const FiltroObrigacoes());
  registerFallbackValue(empresaDeExemplo());
  registerFallbackValue(usuarioDeExemplo());
  registerFallbackValue(obrigacaoDeExemplo());
  registerFallbackValue(StatusObrigacao.pendente);
  registerFallbackValue(Situacao.ativo);
  registerFallbackValue(dadosDeObrigacaoDeExemplo());
}

Obrigacao obrigacaoDeExemplo({
  int id = 10,
  String titulo = 'Entrega da DCTFWeb',
  StatusObrigacao status = StatusObrigacao.pendente,
  int diasParaVencer = 5,
  Situacao situacaoDaEmpresa = Situacao.ativo,
  int empresaId = 1,
  int versao = 0,
  bool? atrasadaNaApi,
}) {
  final vencimento = Datas.hoje().add(Duration(days: diasParaVencer));
  return Obrigacao(
    id: id,
    titulo: titulo,
    descricao: 'Declaração mensal de débitos e créditos tributários federais.',
    tipo: TipoObrigacao.previdenciaria,
    competencia: const Competencia(2026, 10),
    dataVencimento: vencimento,
    status: status,
    proximoStatus: switch (status) {
      StatusObrigacao.pendente => StatusObrigacao.emAndamento,
      StatusObrigacao.emAndamento => StatusObrigacao.concluida,
      StatusObrigacao.concluida => null,
    },
    atrasada: atrasadaNaApi ?? (status != StatusObrigacao.concluida && diasParaVencer < 0),
    empresa: EmpresaDaObrigacao(
      id: empresaId,
      razaoSocial: 'Contábil Alfa LTDA',
      cnpj: '11222333000181',
      situacao: situacaoDaEmpresa,
    ),
    responsavel: const ResponsavelDaObrigacao(
      id: 1,
      nome: 'Ana Souza',
      email: 'ana@escritorio.com.br',
      situacao: Situacao.ativo,
    ),
    versao: versao,
  );
}

DadosObrigacao dadosDeObrigacaoDeExemplo() => DadosObrigacao(
  titulo: 'Entrega da DCTFWeb',
  descricao: '',
  tipo: TipoObrigacao.fiscal,
  competencia: null,
  dataVencimento: Datas.hoje(),
  empresaId: 1,
  responsavelId: 1,
);

typedef RepositoriosFalsos = ({EmpresasFalsas empresas, UsuariosFalsos usuarios, ObrigacoesFalsas obrigacoes});

RepositoriosFalsos repositoriosComDados() {
  final empresas = EmpresasFalsas();
  final usuarios = UsuariosFalsos();
  final obrigacoes = ObrigacoesFalsas();
  final lista = [
    obrigacaoDeExemplo(),
    obrigacaoDeExemplo(id: 11, titulo: 'FGTS Digital', status: StatusObrigacao.emAndamento, diasParaVencer: -3),
    obrigacaoDeExemplo(id: 12, titulo: 'EFD-Reinf', status: StatusObrigacao.concluida, diasParaVencer: -10),
  ];
  when(() => empresas.listar(any()))
      .thenAnswer((_) async => paginaCom([empresaDeExemplo(), empresaDeExemplo(id: 2, situacao: Situacao.inativo)]));
  when(() => empresas.listarAtivas()).thenAnswer((_) async => paginaCom([empresaDeExemplo()]));
  when(() => usuarios.listar(any())).thenAnswer((_) async => paginaCom([usuarioDeExemplo()]));
  when(() => usuarios.listarAtivos()).thenAnswer((_) async => paginaCom([usuarioDeExemplo()]));
  when(() => obrigacoes.listar(any())).thenAnswer((_) async => paginaCom(lista));
  when(() => obrigacoes.proximosVencimentos()).thenAnswer((_) async => paginaCom(lista.take(1).toList()));
  when(() => obrigacoes.resumir())
      .thenAnswer((_) async => const ResumoObrigacoes(pendentes: 1, emAndamento: 1, concluidas: 1, atrasadas: 1));
  when(() => obrigacoes.buscar(any())).thenAnswer((invocacao) async {
    final id = invocacao.positionalArguments.single as int;
    return lista.firstWhere((obrigacao) => obrigacao.id == id);
  });
  when(() => obrigacoes.historico(any())).thenAnswer(
    (_) async => [TransicaoDeStatus(statusNovo: StatusObrigacao.pendente, alteradoEm: DateTime.utc(2026, 11, 20, 13))],
  );
  return (empresas: empresas, usuarios: usuarios, obrigacoes: obrigacoes);
}

Future<ProviderContainer> abrirApp(
  WidgetTester tester, {
  required Size tamanho,
  RepositoriosFalsos? repositorios,
  double escalaDoTexto = 1,
}) async {
  final falsos = repositorios ?? repositoriosComDados();
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = escalaDoTexto;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        configuracaoProvider.overrideWithValue(Configuracao('http://localhost:8080')),
        empresaRepositoryProvider.overrideWithValue(falsos.empresas),
        usuarioRepositoryProvider.overrideWithValue(falsos.usuarios),
        obrigacaoRepositoryProvider.overrideWithValue(falsos.obrigacoes),
      ],
      retry: (tentativas, erro) => null,
      child: const ObrigacoesApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(ObrigacoesApp)));
}
