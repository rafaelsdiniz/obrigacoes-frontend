enum TipoObrigacao {
  fiscal('FISCAL', 'Fiscal'),
  contabil('CONTABIL', 'Contábil'),
  trabalhista('TRABALHISTA', 'Trabalhista'),
  previdenciaria('PREVIDENCIARIA', 'Previdenciária'),
  societaria('SOCIETARIA', 'Societária'),
  outra('OUTRA', 'Outra');

  const TipoObrigacao(this.valorApi, this.rotulo);

  final String valorApi;
  final String rotulo;

  static TipoObrigacao daApi(Object? valor) => values.firstWhere(
    (tipo) => tipo.valorApi == valor,
    orElse: () => throw FormatException('Tipo desconhecido: $valor'),
  );
}
