import 'situacao.dart';

enum Genero {
  masculino('o'),
  feminino('a');

  const Genero(this.terminacao);

  final String terminacao;
}

class TermosDoCadastro {
  const TermosDoCadastro({required this.substantivo, required this.genero});

  final String substantivo;
  final Genero genero;

  String get todos => 'Tod${genero.terminacao}s';

  String get ativos => 'Ativ${genero.terminacao}s';

  String get inativos => 'Inativ${genero.terminacao}s';

  String situacao(Situacao situacao) =>
      situacao == Situacao.ativo ? 'Ativ${genero.terminacao}' : 'Inativ${genero.terminacao}';

  String alteracaoConcluida(Situacao nova) =>
      '$substantivo ${nova == Situacao.ativo ? 'ativad' : 'inativad'}${genero.terminacao}.';
}
