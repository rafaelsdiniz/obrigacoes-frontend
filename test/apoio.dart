import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/core/http/pagina.dart';
import 'package:obrigacoes_app/core/tema/tema.dart';
import 'package:obrigacoes_app/features/empresas/domain/empresa.dart';
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
