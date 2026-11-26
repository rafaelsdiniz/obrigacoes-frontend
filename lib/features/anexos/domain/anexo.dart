import '../../../core/dominio/json.dart';
import '../../../core/formatacao/tamanhos.dart';
import 'tipo_de_anexo.dart';

class Anexo {
  const Anexo({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.tamanho,
    required this.enviadoEm,
  });

  factory Anexo.deJson(Json json) => Anexo(
    id: json['id'] as int,
    nome: json['nomeOriginal'] as String,
    tipo: TipoDeAnexo.daApi(json['tipo']),
    tamanho: json['tamanho'] as int,
    enviadoEm: DateTime.parse(json['criadoEm'] as String),
  );

  static final tamanhoMaximo = Tamanhos.megabytes(10);

  final int id;
  final String nome;
  final TipoDeAnexo tipo;
  final int tamanho;
  final DateTime enviadoEm;
}
