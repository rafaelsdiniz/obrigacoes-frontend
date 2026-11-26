import '../../../core/widgets/icone.dart';

enum TipoDeAnexo {
  pdf('PDF', Icones.arquivoPdf, ['pdf']),
  png('PNG', Icones.arquivoImagem, ['png']),
  jpeg('JPEG', Icones.arquivoImagem, ['jpg', 'jpeg']),
  xml('XML', Icones.arquivoXml, ['xml']),
  csv('CSV', Icones.arquivoPlanilha, ['csv']),
  xlsx('XLSX', Icones.arquivoPlanilha, ['xlsx']),
  docx('DOCX', Icones.arquivoTexto, ['docx']),
  outro('Arquivo', Icones.arquivo, []);

  const TipoDeAnexo(this.rotulo, this.icone, this.extensoes);

  final String rotulo;
  final Icones icone;
  final List<String> extensoes;

  static List<String> get extensoesPermitidas => [for (final tipo in values) ...tipo.extensoes];

  static TipoDeAnexo daApi(Object? valor) => values.firstWhere((tipo) => tipo.rotulo == valor, orElse: () => outro);
}
