enum Situacao {
  ativo('ATIVO', 'ativar'),
  inativo('INATIVO', 'inativar');

  const Situacao(this.valorApi, this.acaoApi);

  final String valorApi;
  final String acaoApi;

  Situacao get oposta => this == ativo ? inativo : ativo;

  static Situacao daApi(Object? valor) => values.firstWhere(
    (situacao) => situacao.valorApi == valor,
    orElse: () => throw FormatException('Situação desconhecida: $valor'),
  );
}
