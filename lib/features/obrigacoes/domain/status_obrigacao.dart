enum StatusObrigacao {
  pendente('PENDENTE', 'Pendente', 'Iniciar'),
  emAndamento('EM_ANDAMENTO', 'Em andamento', 'Concluir'),
  concluida('CONCLUIDA', 'Concluída', null);

  const StatusObrigacao(this.valorApi, this.rotulo, this.acaoParaAvancar);

  final String valorApi;
  final String rotulo;
  final String? acaoParaAvancar;

  static StatusObrigacao daApi(Object? valor) => values.firstWhere(
    (status) => status.valorApi == valor,
    orElse: () => throw FormatException('Status desconhecido: $valor'),
  );
}
