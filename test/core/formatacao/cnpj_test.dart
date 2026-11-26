import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/formatacao/cnpj.dart';

void main() {
  group('Cnpj.valido', () {
    test('aceita CNPJ numérico com ou sem máscara', () {
      expect(Cnpj.valido('11.222.333/0001-81'), isTrue);
      expect(Cnpj.valido('11222333000181'), isTrue);
    });

    test('aceita CNPJ alfanumérico em qualquer caixa', () {
      expect(Cnpj.valido('12.ABC.345/01DE-35'), isTrue);
      expect(Cnpj.valido('12abc34501de35'), isTrue);
    });

    test('recusa dígitos verificadores errados, tamanho errado e sequências repetidas', () {
      expect(Cnpj.valido('11.222.333/0001-82'), isFalse);
      expect(Cnpj.valido('1122233300018'), isFalse);
      expect(Cnpj.valido('00000000000000'), isFalse);
      expect(Cnpj.valido('12.ABC.345/01DE-3A'), isFalse);
    });
  });

  test('formata com máscara a partir do valor normalizado', () {
    expect(Cnpj.formatar('12abc34501de35'), '12.ABC.345/01DE-35');
    expect(Cnpj.formatar('1122'), '11.22');
  });

  test('a máscara converte para maiúsculas, insere separadores e limita a 14 caracteres', () {
    final valor = MascaraCnpj().formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '12abc34501de35999'),
    );

    expect(valor.text, '12.ABC.345/01DE-35');
    expect(valor.selection.baseOffset, valor.text.length);
  });

  test('a máscara mantém o cursor no ponto de edição', () {
    final valor = MascaraCnpj().formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '11.2X22.333/0001-81', selection: TextSelection.collapsed(offset: 5)),
    );

    expect(valor.text, '11.2X2.233/3000-18');
    expect(valor.selection.baseOffset, 5);
  });
}
