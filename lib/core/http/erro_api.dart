import 'package:dio/dio.dart';

enum CodigoErro {
  validacao,
  requisicaoInvalida,
  recursoNaoEncontrado,
  conflito,
  regraNegocio,
  arquivoInvalido,
  erroInterno,
  semConexao,
  desconhecido;

  static CodigoErro daApi(Object? valor) => switch (valor) {
    'VALIDACAO' => validacao,
    'REQUISICAO_INVALIDA' => requisicaoInvalida,
    'RECURSO_NAO_ENCONTRADO' => recursoNaoEncontrado,
    'CONFLITO' => conflito,
    'REGRA_NEGOCIO' => regraNegocio,
    'ARQUIVO_INVALIDO' => arquivoInvalido,
    'ERRO_INTERNO' => erroInterno,
    _ => desconhecido,
  };
}

class ErroApi implements Exception {
  const ErroApi({required this.codigo, required this.mensagem, this.errosPorCampo = const {}});

  factory ErroApi.de(DioException erro) {
    final corpo = erro.response?.data;
    if (corpo is Map<String, dynamic>) {
      return ErroApi(
        codigo: CodigoErro.daApi(corpo['codigo']),
        mensagem: corpo['detail'] as String? ?? _mensagemPadrao,
        errosPorCampo: _errosPorCampo(corpo['erros']),
      );
    }
    return switch (erro.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const ErroApi(
        codigo: CodigoErro.semConexao,
        mensagem: 'Não foi possível conectar ao servidor. Verifique a conexão e tente novamente.',
      ),
      _ => const ErroApi(codigo: CodigoErro.desconhecido, mensagem: _mensagemPadrao),
    };
  }

  static const _mensagemPadrao = 'Ocorreu um erro inesperado. Tente novamente.';

  final CodigoErro codigo;
  final String mensagem;
  final Map<String, String> errosPorCampo;

  static Map<String, String> _errosPorCampo(Object? erros) {
    if (erros is! List<dynamic>) {
      return const {};
    }
    return {
      for (final erro in erros.whereType<Map<String, dynamic>>())
        if (erro['campo'] case final String campo) campo: erro['mensagem'] as String? ?? 'Valor inválido.',
    };
  }

  static String mensagemPara(Object erro) => erro is ErroApi ? erro.mensagem : _mensagemPadrao;

  @override
  String toString() => mensagem;
}
