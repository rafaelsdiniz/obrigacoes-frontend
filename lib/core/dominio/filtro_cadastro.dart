import 'situacao.dart';

class FiltroCadastro {
  const FiltroCadastro({this.busca = '', this.situacao, this.pagina = 0});

  final String busca;
  final Situacao? situacao;
  final int pagina;

  @override
  bool operator ==(Object other) =>
      other is FiltroCadastro && other.busca == busca && other.situacao == situacao && other.pagina == pagina;

  @override
  int get hashCode => Object.hash(busca, situacao, pagina);
}
