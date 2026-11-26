import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/http/cliente_api.dart';
import 'package:obrigacoes_app/features/obrigacoes/data/obrigacao_repository.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/filtro_obrigacoes.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/status_obrigacao.dart';

import '../../servidor_de_paginas.dart';

void main() {
  late ServidorDePaginas servidor;
  late ObrigacaoRepository repositorio;

  setUp(() {
    servidor = ServidorDePaginas();
    repositorio = ObrigacaoRepository(
      ClienteApi(Dio(BaseOptions(baseUrl: 'http://api.teste/api/v1/'))..httpClientAdapter = servidor),
    );
  });

  test('envia os filtros escolhidos, repetindo o status quando há mais de um', () async {
    await repositorio.listar(
      const FiltroObrigacoes(
        busca: 'dctf',
        status: {StatusObrigacao.pendente, StatusObrigacao.emAndamento},
        somenteAtrasadas: true,
      ),
    );

    final parametros = servidor.ultimaRequisicao.uri.queryParametersAll;
    expect(parametros['status'], containsAll(['PENDENTE', 'EM_ANDAMENTO']));
    expect(parametros['busca'], ['dctf']);
    expect(parametros['atrasada'], ['true']);
    expect(parametros['sort'], ['dataVencimento']);
  });

  test('não envia filtros vazios', () async {
    await repositorio.listar(const FiltroObrigacoes());

    expect(servidor.ultimaRequisicao.uri.queryParameters.keys, containsAll(['page', 'size', 'sort']));
    expect(servidor.ultimaRequisicao.uri.queryParameters.keys, isNot(contains('status')));
    expect(servidor.ultimaRequisicao.uri.queryParameters.keys, isNot(contains('atrasada')));
  });
}
