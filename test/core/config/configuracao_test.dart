import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/config/configuracao.dart';

void main() {
  test('fora da web usa localhost, ou o endereço do host no emulador Android', () async {
    final desktop = await Configuracao.carregar(web: false, plataforma: TargetPlatform.linux);
    final android = await Configuracao.carregar(web: false, plataforma: TargetPlatform.android);

    expect(desktop.urlApi.toString(), 'http://localhost:8080/');
    expect(android.urlApi.toString(), 'http://10.0.2.2:8080/');
  });

  test('na web busca o config.json na raiz do site, independente da rota aberta', () async {
    final servidor = _Servidor(200, jsonEncode({'apiUrl': 'https://api.exemplo.com.br/backend'}));

    final configuracao = await Configuracao.carregar(
      cliente: servidor.cliente,
      web: true,
      enderecoDaPagina: Uri.parse('https://app.exemplo.com.br/empresas/7/editar'),
    );

    expect(servidor.enderecoRequisitado, 'https://app.exemplo.com.br/config.json');
    expect(configuracao.urlApi.resolve('api/v1/').toString(), 'https://api.exemplo.com.br/backend/api/v1/');
  });

  test('na web mantém o padrão quando o arquivo não existe, não é JSON ou traz URL inválida', () async {
    for (final servidor in [
      _Servidor(404, '{}'),
      _Servidor(200, '<!doctype html><html></html>', tipo: 'text/html'),
      _Servidor(200, jsonEncode({'apiUrl': 'http://[invalida'})),
    ]) {
      final configuracao = await Configuracao.carregar(
        cliente: servidor.cliente,
        web: true,
        enderecoDaPagina: Uri.parse('https://app.exemplo.com.br/'),
        plataforma: TargetPlatform.linux,
      );
      expect(configuracao.urlApi.toString(), 'http://localhost:8080/');
    }
  });
}

class _Servidor implements HttpClientAdapter {
  _Servidor(this._status, this._corpo, {this.tipo = 'application/json'});

  final int _status;
  final String _corpo;
  final String tipo;
  String? enderecoRequisitado;

  Dio get cliente => Dio()..httpClientAdapter = this;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    enderecoRequisitado = options.uri.toString();
    return ResponseBody.fromString(
      _corpo,
      _status,
      headers: {
        Headers.contentTypeHeader: [tipo],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
