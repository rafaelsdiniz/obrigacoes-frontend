import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/http/cliente_api.dart';
import 'package:obrigacoes_app/core/http/erro_api.dart';
import 'package:obrigacoes_app/core/http/pagina.dart';

void main() {
  late _ServidorFalso servidor;
  late ClienteApi api;

  setUp(() {
    servidor = _ServidorFalso();
    api = ClienteApi(Dio(BaseOptions(baseUrl: 'http://api.teste/api/v1/'))..httpClientAdapter = servidor);
  });

  test('envia apenas os parâmetros preenchidos', () async {
    servidor.responder(200, {'ok': true});

    await api.get('empresas', parametros: {'busca': '', 'situacao': null, 'page': 0});

    expect(servidor.ultimaRequisicao.uri.toString(), 'http://api.teste/api/v1/empresas?page=0');
  });

  test('converte a página da API', () async {
    servidor.responder(200, {
      'conteudo': [
        {'nome': 'Ana'},
      ],
      'pagina': 0,
      'tamanho': 20,
      'totalElementos': 21,
      'totalPaginas': 2,
    });

    final pagina = Pagina.deJson(await api.get('usuarios'), (json) => json['nome'] as String);

    expect(pagina.itens, ['Ana']);
    expect(pagina.temAnterior, isFalse);
    expect(pagina.temProxima, isTrue);
  });

  test('traduz Problem Details em ErroApi com os erros por campo', () async {
    servidor.responder(400, {
      'title': 'Dados inválidos',
      'detail': 'Um ou mais campos estão inválidos.',
      'codigo': 'VALIDACAO',
      'erros': [
        {'campo': 'cnpj', 'mensagem': 'O CNPJ informado é inválido.'},
      ],
    });

    final erro = await _capturar(() => api.post('empresas', corpo: {}));

    expect(erro.codigo, CodigoErro.validacao);
    expect(erro.mensagem, 'Um ou mais campos estão inválidos.');
    expect(erro.errosPorCampo, {'cnpj': 'O CNPJ informado é inválido.'});
  });

  test('informa falta de conexão quando o servidor não responde', () async {
    servidor.falharConexao();

    final erro = await _capturar(() => api.get('empresas'));

    expect(erro.codigo, CodigoErro.semConexao);
    expect(erro.mensagem, contains('Não foi possível conectar ao servidor'));
  });

  test('usa mensagem genérica quando o erro não vem no formato Problem Details', () async {
    servidor.responderTexto(502, '<html>Bad Gateway</html>');

    final erro = await _capturar(() => api.get('empresas'));

    expect(erro.codigo, CodigoErro.desconhecido);
    expect(erro.mensagem, 'Ocorreu um erro inesperado. Tente novamente.');
  });

  test('a mensagem para erros que não são da API é genérica', () {
    expect(ErroApi.mensagemPara(const FormatException('type Null is not a subtype')), isNot(contains('Null')));
  });
}

Future<ErroApi> _capturar(Future<Object?> Function() chamada) async {
  try {
    await chamada();
  } on ErroApi catch (erro) {
    return erro;
  }
  throw StateError('Era esperado um ErroApi.');
}

class _ServidorFalso implements HttpClientAdapter {
  late RequestOptions ultimaRequisicao;
  int _status = 200;
  Object? _corpo;
  bool _semConexao = false;

  void responder(int status, Object corpo) {
    _status = status;
    _corpo = corpo;
  }

  void responderTexto(int status, String corpo) {
    _status = status;
    _corpo = corpo;
  }

  void falharConexao() => _semConexao = true;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    ultimaRequisicao = options;
    if (_semConexao) {
      throw DioException.connectionError(requestOptions: options, reason: 'recusada');
    }
    final corpo = _corpo;
    return ResponseBody.fromString(
      corpo is String ? corpo : jsonEncode(corpo),
      _status,
      headers: {
        Headers.contentTypeHeader: [corpo is String ? 'text/html' : Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
