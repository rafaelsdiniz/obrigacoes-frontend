import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/http/cliente_api.dart';
import 'package:obrigacoes_app/core/http/erro_api.dart';
import 'package:obrigacoes_app/features/anexos/data/anexo_repository.dart';
import 'package:obrigacoes_app/features/anexos/domain/tipo_de_anexo.dart';

void main() {
  late _Servidor servidor;
  late AnexoRepository repositorio;

  setUp(() {
    servidor = _Servidor();
    repositorio = AnexoRepository(
      ClienteApi(Dio(BaseOptions(baseUrl: 'http://api.teste/api/v1/'))..httpClientAdapter = servidor),
    );
  });

  const json = {
    'id': 7,
    'nomeOriginal': 'relatório outubro.xlsx',
    'tipo': 'XLSX',
    'tipoConteudo': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'tamanho': 2048,
    'hashSha256': 'abc',
    'criadoEm': '2026-11-25T15:10:00Z',
  };

  test('converte a lista de anexos da obrigação', () async {
    servidor.corpo = [json];

    final anexos = await repositorio.listar(10);

    expect(servidor.ultimaRequisicao.uri.path, '/api/v1/obrigacoes/10/anexos');
    expect(anexos.single.nome, 'relatório outubro.xlsx');
    expect(anexos.single.tipo, TipoDeAnexo.xlsx);
    expect(anexos.single.enviadoEm, DateTime.utc(2026, 11, 25, 15, 10));
  });

  test('envia o arquivo em multipart no campo esperado pela API', () async {
    servidor.corpo = json;

    final anexo = await repositorio.enviar(10, nome: 'relatório outubro.xlsx', bytes: Uint8List.fromList([1, 2]));

    final formulario = servidor.ultimaRequisicao.data as FormData;
    expect(servidor.ultimaRequisicao.method, 'POST');
    expect(formulario.files.single.key, 'arquivo');
    expect(formulario.files.single.value.filename, 'relatório outubro.xlsx');
    expect(anexo.id, 7);
  });

  test('exclui pelo endereço do anexo e monta o endereço de download', () async {
    servidor.status = 204;

    await repositorio.excluir(10, 7);

    expect(servidor.ultimaRequisicao.method, 'DELETE');
    expect(servidor.ultimaRequisicao.uri.path, '/api/v1/obrigacoes/10/anexos/7');
    expect(repositorio.enderecoDoArquivo(10, 7).toString(), 'http://api.teste/api/v1/obrigacoes/10/anexos/7');
  });

  test('arquivo recusado pela API chega como ErroApi com o código e a mensagem', () async {
    servidor
      ..status = 413
      ..corpo = {'codigo': 'ARQUIVO_INVALIDO', 'detail': 'O arquivo excede o tamanho máximo de 10MB.'};

    final envio = repositorio.enviar(10, nome: 'grande.pdf', bytes: Uint8List(1));

    await expectLater(
      envio,
      throwsA(
        isA<ErroApi>()
            .having((erro) => erro.codigo, 'codigo', CodigoErro.arquivoInvalido)
            .having((erro) => erro.mensagem, 'mensagem', 'O arquivo excede o tamanho máximo de 10MB.'),
      ),
    );
  });

  test('tipo desconhecido vira arquivo genérico', () {
    expect(TipoDeAnexo.daApi('ZIP'), TipoDeAnexo.outro);
    expect(TipoDeAnexo.extensoesPermitidas, ['pdf', 'png', 'jpg', 'jpeg', 'xml', 'csv', 'xlsx', 'docx']);
  });
}

class _Servidor implements HttpClientAdapter {
  late RequestOptions ultimaRequisicao;
  Object? corpo;
  int status = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    ultimaRequisicao = options;
    final corpo = this.corpo;
    return ResponseBody.fromString(
      corpo == null ? '' : jsonEncode(corpo),
      status,
      headers: {
        if (corpo != null) Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
