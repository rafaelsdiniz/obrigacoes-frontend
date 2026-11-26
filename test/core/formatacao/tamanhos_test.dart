import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/formatacao/tamanhos.dart';

void main() {
  test('formata tamanhos de arquivo em B, KB e MB', () {
    expect(Tamanhos.formatar(512), '512 B');
    expect(Tamanhos.formatar(184233), '180 KB');
    expect(Tamanhos.formatar(Tamanhos.megabytes(10)), '10 MB');
    expect(Tamanhos.formatar(1572864), '1,5 MB');
  });
}
