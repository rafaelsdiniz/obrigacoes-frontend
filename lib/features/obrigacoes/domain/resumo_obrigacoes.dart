import '../../../core/dominio/json.dart';

class ResumoObrigacoes {
  const ResumoObrigacoes({
    required this.pendentes,
    required this.emAndamento,
    required this.concluidas,
    required this.atrasadas,
  });

  factory ResumoObrigacoes.deJson(Json json) => ResumoObrigacoes(
    pendentes: json['pendentes'] as int,
    emAndamento: json['emAndamento'] as int,
    concluidas: json['concluidas'] as int,
    atrasadas: json['atrasadas'] as int,
  );

  final int pendentes;
  final int emAndamento;
  final int concluidas;
  final int atrasadas;

  int get emAberto => pendentes + emAndamento;
}
