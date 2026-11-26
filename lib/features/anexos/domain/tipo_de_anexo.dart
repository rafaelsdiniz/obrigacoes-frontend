enum TipoDeAnexo {
  pdf('PDF', ['pdf']),
  png('PNG', ['png']),
  jpeg('JPEG', ['jpg', 'jpeg']),
  xml('XML', ['xml']),
  csv('CSV', ['csv']),
  xlsx('XLSX', ['xlsx']),
  docx('DOCX', ['docx']),
  outro('Arquivo', []);

  const TipoDeAnexo(this.rotulo, this.extensoes);

  final String rotulo;
  final List<String> extensoes;

  static List<String> get extensoesPermitidas => [for (final tipo in values) ...tipo.extensoes];

  static String get descricaoDosAceitos {
    final aceitos = [
      for (final tipo in values)
        if (tipo != outro) tipo.rotulo,
    ];
    return '${aceitos.sublist(0, aceitos.length - 1).join(', ')} ou ${aceitos.last}';
  }

  static TipoDeAnexo daApi(Object? valor) => values.firstWhere((tipo) => tipo.rotulo == valor, orElse: () => outro);
}
