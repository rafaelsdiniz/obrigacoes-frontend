import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final configuracaoProvider = Provider<Configuracao>(
  (ref) => throw StateError('A configuração deve ser carregada antes de iniciar o aplicativo.'),
);

class Configuracao {
  Configuracao(String urlApi) : urlApi = Uri.parse(urlApi.endsWith('/') ? urlApi : '$urlApi/');

  static const _caminhoDoArquivo = '/config.json';
  static const _urlDoBuild = String.fromEnvironment('API_URL');
  static const _urlLocal = 'http://localhost:8080';
  static const _urlLocalNoEmuladorAndroid = 'http://10.0.2.2:8080';

  final Uri urlApi;

  static Future<Configuracao> carregar({
    Dio? cliente,
    bool web = kIsWeb,
    Uri? enderecoDaPagina,
    TargetPlatform? plataforma,
  }) async {
    final padrao = Configuracao(_urlPadrao(plataforma ?? defaultTargetPlatform));
    if (!web) {
      return padrao;
    }
    try {
      final arquivo = (enderecoDaPagina ?? Uri.base).resolve(_caminhoDoArquivo);
      final resposta = await (cliente ?? Dio()).get<Object?>(arquivo.toString());
      final dados = resposta.data;
      final url = dados is Map<String, dynamic> ? dados['apiUrl'] : null;
      return url is String && url.isNotEmpty ? Configuracao(url) : padrao;
    } on DioException {
      return padrao;
    } on FormatException {
      return padrao;
    }
  }

  static String _urlPadrao(TargetPlatform plataforma) {
    if (_urlDoBuild.isNotEmpty) {
      return _urlDoBuild;
    }
    return plataforma == TargetPlatform.android ? _urlLocalNoEmuladorAndroid : _urlLocal;
  }
}
