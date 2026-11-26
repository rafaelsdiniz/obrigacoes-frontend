import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/configuracao.dart';
import '../dominio/json.dart';
import 'erro_api.dart';

final clienteApiProvider = Provider<ClienteApi>((ref) {
  final configuracao = ref.watch(configuracaoProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: configuracao.urlApi.resolve('api/v1/').toString(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  ref.onDispose(dio.close);
  return ClienteApi(dio);
});

class ClienteApi {
  const ClienteApi(this._dio);

  final Dio _dio;

  Future<Json> get(String caminho, {Map<String, Object?> parametros = const {}}) async =>
      await _executar(() => _dio.get<Json>(caminho, queryParameters: _semVazios(parametros))) ?? const {};

  Future<List<Json>> getLista(String caminho) async =>
      (await _executar(() => _dio.get<List<dynamic>>(caminho)) ?? const []).cast<Json>();

  Future<Json> post(String caminho, {Object? corpo}) async =>
      await _executar(() => _dio.post<Json>(caminho, data: corpo)) ?? const {};

  Future<Json> put(String caminho, Json corpo) async =>
      await _executar(() => _dio.put<Json>(caminho, data: corpo)) ?? const {};

  Future<Json> patch(String caminho, {Json? corpo}) async =>
      await _executar(() => _dio.patch<Json>(caminho, data: corpo)) ?? const {};

  Future<Json> enviarArquivo(
    String caminho, {
    required String campo,
    required String nome,
    required Uint8List bytes,
  }) async =>
      await _executar(
        () => _dio.post<Json>(caminho, data: FormData.fromMap({campo: MultipartFile.fromBytes(bytes, filename: nome)})),
      ) ??
      const {};

  Future<void> delete(String caminho) => _executar(() => _dio.delete<void>(caminho));

  Uri endereco(String caminho) => Uri.parse(_dio.options.baseUrl).resolve(caminho);

  Future<T?> _executar<T>(Future<Response<T>> Function() requisicao) async {
    try {
      final resposta = await requisicao();
      return resposta.data;
    } on DioException catch (erro) {
      throw ErroApi.de(erro);
    }
  }

  static Map<String, Object> _semVazios(Map<String, Object?> parametros) => {
    for (final MapEntry(:key, :value) in parametros.entries)
      if (value != null && value != '' && !(value is List && value.isEmpty)) key: value,
  };
}
