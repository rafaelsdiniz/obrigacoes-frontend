import 'package:flutter/services.dart';

abstract final class Cnpj {
  static const tamanho = 14;

  static final _naoAlfanumerico = RegExp('[^0-9A-Za-z]');
  static final _formato = RegExp(r'^[0-9A-Z]{12}[0-9]{2}$');
  static const _pesosPrimeiroDigito = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  static const _pesosSegundoDigito = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  static const _separadores = {2: '.', 5: '.', 8: '/', 12: '-'};

  static String normalizar(String cnpj) => cnpj.replaceAll(_naoAlfanumerico, '').toUpperCase();

  static bool valido(String cnpj) {
    final valor = normalizar(cnpj);
    if (!_formato.hasMatch(valor) || valor.split('').toSet().length == 1) {
      return false;
    }
    return _digito(valor, _pesosPrimeiroDigito) == _valor(valor.codeUnitAt(12)) &&
        _digito(valor, _pesosSegundoDigito) == _valor(valor.codeUnitAt(13));
  }

  static String formatar(String cnpj) {
    final valor = normalizar(cnpj);
    final saida = StringBuffer();
    for (var i = 0; i < valor.length; i++) {
      saida.write(_separadores[i] ?? '');
      saida.write(valor[i]);
    }
    return saida.toString();
  }

  static int _digito(String cnpj, List<int> pesos) {
    var soma = 0;
    for (var i = 0; i < pesos.length; i++) {
      soma += _valor(cnpj.codeUnitAt(i)) * pesos[i];
    }
    final resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }

  static int _valor(int codigoCaractere) => codigoCaractere - '0'.codeUnitAt(0);
}

class MascaraCnpj extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue anterior, TextEditingValue atual) {
    final normalizado = Cnpj.normalizar(atual.text);
    final limitado = normalizado.length > Cnpj.tamanho ? normalizado.substring(0, Cnpj.tamanho) : normalizado;
    final formatado = Cnpj.formatar(limitado);
    final cursor = atual.selection.isValid ? atual.selection.baseOffset.clamp(0, atual.text.length) : atual.text.length;
    final caracteresAntesDoCursor = Cnpj.normalizar(atual.text.substring(0, cursor)).length;
    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(offset: _posicaoNoFormatado(formatado, caracteresAntesDoCursor)),
    );
  }

  static int _posicaoNoFormatado(String formatado, int caracteres) {
    if (caracteres == 0) {
      return 0;
    }
    var encontrados = 0;
    for (var i = 0; i < formatado.length; i++) {
      if (Cnpj.normalizar(formatado[i]).isNotEmpty && ++encontrados == caracteres) {
        return i + 1;
      }
    }
    return formatado.length;
  }
}
