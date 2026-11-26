import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/formatacao/datas.dart';

void main() {
  test('converte e formata datas no padrão da API e do Brasil', () {
    final data = Datas.daApi('2026-11-05');

    expect(data, DateTime(2026, 11, 5));
    expect(Datas.paraApi(data), '2026-11-05');
    expect(Datas.formatar(data), '05/11/2026');
    expect(Datas.diasEntre(DateTime(2026, 11, 5), DateTime(2026, 12, 5)), 30);
  });

  test('formata instantes da API no horário local, por extenso e na forma curta', () {
    final instante = DateTime(2026, 11, 26, 8, 41).toUtc();

    expect(Datas.formatarComHora(instante), '26/11/2026 às 08:41');
    expect(Datas.formatarCurtoComHora(instante), '26/11 · 08:41');
  });

  test('a competência aceita apenas MM/AAAA válido', () {
    expect(Competencia.deTexto('10/2026'), const Competencia(2026, 10));
    expect(Competencia.deTexto('13/2026'), isNull);
    expect(Competencia.deTexto('2026-10'), isNull);
    expect(Competencia.daApi('2026-01').toString(), '01/2026');
    expect(const Competencia(2026, 1).paraApi(), '2026-01');
  });

  test('a máscara da competência insere a barra e limita a seis dígitos', () {
    final valor = MascaraCompetencia().formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '1020269'),
    );

    expect(valor.text, '10/2026');
  });

  test('a máscara da competência mantém o cursor onde a pessoa está digitando', () {
    final valor = MascaraCompetencia().formatEditUpdate(
      const TextEditingValue(text: '10/2026'),
      const TextEditingValue(text: '1/2026', selection: TextSelection.collapsed(offset: 1)),
    );

    expect(valor.text, '12/026');
    expect(valor.selection.baseOffset, 1);
  });
}
