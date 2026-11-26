import 'cnpj.dart';

typedef Validador = String? Function(String? valor);

abstract final class Validacoes {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static Validador obrigatorio(String mensagem, {int? maximo}) => (valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) {
      return mensagem;
    }
    return maximo == null ? null : tamanhoMaximo(maximo)(texto);
  };

  static Validador tamanhoMaximo(int maximo) =>
      (valor) => (valor?.trim().length ?? 0) > maximo ? 'Use no máximo $maximo caracteres.' : null;

  static String? email(String? valor) {
    final texto = valor?.trim() ?? '';
    return texto.isEmpty || _email.hasMatch(texto) ? null : 'Informe um e-mail válido.';
  }

  static String? cnpj(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O CNPJ é obrigatório.';
    }
    return Cnpj.valido(valor) ? null : 'Informe um CNPJ válido.';
  }

  static Validador todas(List<Validador> validadores) => (valor) {
    for (final validador in validadores) {
      final erro = validador(valor);
      if (erro != null) {
        return erro;
      }
    }
    return null;
  };
}
