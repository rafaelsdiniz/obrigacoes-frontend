import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/core/dominio/termos_do_cadastro.dart';

void main() {
  test('flexiona os termos conforme o gênero do cadastro', () {
    const empresa = TermosDoCadastro(substantivo: 'Empresa', genero: Genero.feminino);
    const usuario = TermosDoCadastro(substantivo: 'Usuário', genero: Genero.masculino);

    expect([empresa.todos, empresa.ativos, empresa.inativos], ['Todas', 'Ativas', 'Inativas']);
    expect([usuario.todos, usuario.ativos, usuario.inativos], ['Todos', 'Ativos', 'Inativos']);
    expect(empresa.situacao(Situacao.inativo), 'Inativa');
    expect(usuario.situacao(Situacao.ativo), 'Ativo');
    expect(empresa.alteracaoConcluida(Situacao.inativo), 'Empresa inativada.');
    expect(usuario.alteracaoConcluida(Situacao.ativo), 'Usuário ativado.');
  });

  test('converte a situação da API e recusa valores desconhecidos', () {
    expect(Situacao.daApi('INATIVO'), Situacao.inativo);
    expect(Situacao.ativo.oposta, Situacao.inativo);
    expect(Situacao.inativo.acaoApi, 'inativar');
    expect(() => Situacao.daApi('BLOQUEADO'), throwsFormatException);
  });
}
