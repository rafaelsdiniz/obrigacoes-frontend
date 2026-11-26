import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class ServidorDeContrato implements HttpClientAdapter {
  ServidorDeContrato(this.resposta);

  final Object resposta;
  late RequestOptions requisicao;
  Object? corpoRecebido;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requisicao = options;
    if (requestStream != null) {
      final bytes = await requestStream.expand((bloco) => bloco).toList();
      corpoRecebido = bytes.isEmpty ? null : jsonDecode(utf8.decode(bytes));
    }
    return ResponseBody.fromString(
      jsonEncode(resposta),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
