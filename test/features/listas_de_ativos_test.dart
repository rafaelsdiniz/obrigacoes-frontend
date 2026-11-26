import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/http/cliente_api.dart';
import 'package:obrigacoes_app/features/empresas/data/empresa_repository.dart';
import 'package:obrigacoes_app/features/usuarios/data/usuario_repository.dart';

import '../servidor_de_paginas.dart';

void main() {
  late ServidorDePaginas servidor;
  late ClienteApi api;

  setUp(() {
    servidor = ServidorDePaginas();
    api = ClienteApi(Dio(BaseOptions(baseUrl: 'http://api.teste/api/v1/'))..httpClientAdapter = servidor);
  });

  test('as empresas para seleção vêm só ativas, em ordem alfabética e no maior tamanho de página', () async {
    await EmpresaRepository(api).listarAtivas();

    expect(servidor.ultimaRequisicao.uri.queryParameters, {'situacao': 'ATIVO', 'size': '100', 'sort': 'razaoSocial'});
  });

  test('os responsáveis para seleção vêm só ativos e em ordem alfabética', () async {
    await UsuarioRepository(api).listarAtivos();

    expect(servidor.ultimaRequisicao.uri.queryParameters, {'situacao': 'ATIVO', 'size': '100', 'sort': 'nome'});
  });
}
