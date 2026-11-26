import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class ServidorDePaginas implements HttpClientAdapter {
  late RequestOptions ultimaRequisicao;
  Object respostaPadrao = {'conteudo': <Object>[], 'pagina': 0, 'tamanho': 20, 'totalElementos': 0, 'totalPaginas': 0};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    ultimaRequisicao = options;
    return ResponseBody.fromString(
      jsonEncode(respostaPadrao),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
