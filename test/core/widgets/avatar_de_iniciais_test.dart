import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/widgets/avatar_de_iniciais.dart';

void main() {
  test('usa a primeira letra do primeiro e do último nome', () {
    expect(AvatarDeIniciais.iniciaisDe('Ana Souza'), 'AS');
    expect(AvatarDeIniciais.iniciaisDe('  carla   de   mendes '), 'CM');
    expect(AvatarDeIniciais.iniciaisDe('Bruno'), 'B');
    expect(AvatarDeIniciais.iniciaisDe('Élio Ávila'), 'ÉÁ');
    expect(AvatarDeIniciais.iniciaisDe('   '), '?');
  });
}
