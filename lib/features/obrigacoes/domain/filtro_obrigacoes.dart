import 'package:flutter/foundation.dart';

import 'status_obrigacao.dart';

@immutable
class FiltroObrigacoes {
  const FiltroObrigacoes({this.busca = '', this.status = const {}, this.somenteAtrasadas = false, this.pagina = 0});

  final String busca;
  final Set<StatusObrigacao> status;
  final bool somenteAtrasadas;
  final int pagina;

  FiltroObrigacoes alterar({String? busca, Set<StatusObrigacao>? status, bool? somenteAtrasadas, int? pagina}) =>
      FiltroObrigacoes(
        busca: busca ?? this.busca,
        status: status ?? this.status,
        somenteAtrasadas: somenteAtrasadas ?? this.somenteAtrasadas,
        pagina: pagina ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      other is FiltroObrigacoes &&
      other.busca == busca &&
      setEquals(other.status, status) &&
      other.somenteAtrasadas == somenteAtrasadas &&
      other.pagina == pagina;

  @override
  int get hashCode => Object.hash(busca, Object.hashAllUnordered(status), somenteAtrasadas, pagina);
}
