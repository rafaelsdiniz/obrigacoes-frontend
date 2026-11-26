enum StatusObrigacao {
  pendente('PENDENTE', 'Pendente'),
  emAndamento('EM_ANDAMENTO', 'Em andamento'),
  concluida('CONCLUIDA', 'Concluída');

  const StatusObrigacao(this.valorApi, this.rotulo);

  final String valorApi;
  final String rotulo;

  static StatusObrigacao daApi(Object? valor) => values.firstWhere(
    (status) => status.valorApi == valor,
    orElse: () => throw FormatException('Status desconhecido: $valor'),
  );
}
