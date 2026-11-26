import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/formatacao/validacoes.dart';

void main() {
  test('obrigatório recusa vazio e espaços e aplica o tamanho máximo', () {
    final validar = Validacoes.obrigatorio('O nome é obrigatório.', maximo: 5);

    expect(validar(null), 'O nome é obrigatório.');
    expect(validar('   '), 'O nome é obrigatório.');
    expect(validar('Ana Souza'), 'Use no máximo 5 caracteres.');
    expect(validar(' Ana '), isNull);
  });

  test('e-mail é opcional, mas precisa ter formato válido quando informado', () {
    expect(Validacoes.email(''), isNull);
    expect(Validacoes.email('ana@escritorio.com.br'), isNull);
    expect(Validacoes.email('ana@escritorio'), 'Informe um e-mail válido.');
  });

  test('CNPJ é obrigatório e precisa ser válido', () {
    expect(Validacoes.cnpj(''), 'O CNPJ é obrigatório.');
    expect(Validacoes.cnpj('11.222.333/0001-82'), 'Informe um CNPJ válido.');
    expect(Validacoes.cnpj('11.222.333/0001-81'), isNull);
  });

  test('todas retorna o primeiro erro encontrado', () {
    final validar = Validacoes.todas([Validacoes.tamanhoMaximo(3), Validacoes.email]);

    expect(validar('abcd'), 'Use no máximo 3 caracteres.');
    expect(validar('abc'), 'Informe um e-mail válido.');
  });
}
