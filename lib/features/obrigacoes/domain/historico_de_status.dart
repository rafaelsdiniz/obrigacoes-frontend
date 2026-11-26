import '../../../core/dominio/json.dart';
import 'status_obrigacao.dart';

class TransicaoDeStatus {
  const TransicaoDeStatus({required this.statusNovo, required this.alteradoEm, this.statusAnterior});

  factory TransicaoDeStatus.deJson(Json json) => TransicaoDeStatus(
    statusAnterior: json['statusAnterior'] == null ? null : StatusObrigacao.daApi(json['statusAnterior']),
    statusNovo: StatusObrigacao.daApi(json['statusNovo']),
    alteradoEm: DateTime.parse(json['alteradoEm'] as String),
  );

  final StatusObrigacao? statusAnterior;
  final StatusObrigacao statusNovo;
  final DateTime alteradoEm;
}
