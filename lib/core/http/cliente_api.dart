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

  Future<Json> get(String caminho, {Map<String, Object?> parametros = const {}}) =>
      _executar(() => _dio.get<Json>(caminho, queryParameters: _semVazios(parametros)));

  Future<List<Json>> getLista(String caminho) async {
    try {
      final resposta = await _dio.get<List<dynamic>>(caminho);
      return (resposta.data ?? const []).cast<Json>();
    } on DioException catch (erro) {
      throw ErroApi.de(erro);
    }
  }

  Future<Json> post(String caminho, {Object? corpo}) => _executar(() => _dio.post<Json>(caminho, data: corpo));

  Future<Json> put(String caminho, Json corpo) => _executar(() => _dio.put<Json>(caminho, data: corpo));

  Future<Json> patch(String caminho, {Json? corpo}) => _executar(() => _dio.patch<Json>(caminho, data: corpo));

  Future<Json> _executar(Future<Response<Json>> Function() requisicao) async {
    try {
      final resposta = await requisicao();
      return resposta.data ?? const {};
    } on DioException catch (erro) {
      throw ErroApi.de(erro);
    }
  }

  static Map<String, Object> _semVazios(Map<String, Object?> parametros) => {
    for (final MapEntry(:key, :value) in parametros.entries)
      if (value != null && value != '' && !(value is List && value.isEmpty)) key: value,
  };
}
