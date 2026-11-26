import 'package:flutter/foundation.dart';

import 'status_obrigacao.dart';
import 'tipo_obrigacao.dart';

typedef IntervaloDeDatas = ({DateTime de, DateTime ate});

enum PeriodoDeVencimento {
  proximos7Dias('Próximos 7 dias'),
  proximos30Dias('Próximos 30 dias'),
  esteMes('Este mês'),
  mesPassado('Mês passado');

  const PeriodoDeVencimento(this.rotulo);

  final String rotulo;

  IntervaloDeDatas intervalo(DateTime hoje) => switch (this) {
    proximos7Dias => (de: hoje, ate: DateTime(hoje.year, hoje.month, hoje.day + 7)),
    proximos30Dias => (de: hoje, ate: DateTime(hoje.year, hoje.month, hoje.day + 30)),
    esteMes => (de: DateTime(hoje.year, hoje.month), ate: DateTime(hoje.year, hoje.month + 1, 0)),
    mesPassado => (de: DateTime(hoje.year, hoje.month - 1), ate: DateTime(hoje.year, hoje.month, 0)),
  };
}

enum OrdemDasObrigacoes {
  vencimentoMaisAntigo('Vencimento mais antigo', 'dataVencimento'),
  vencimentoMaisDistante('Vencimento mais distante', 'dataVencimento,desc'),
  cadastroMaisRecente('Cadastro mais recente', 'criadoEm,desc'),
  titulo('Título (A–Z)', 'titulo');

  const OrdemDasObrigacoes(this.rotulo, this.valorApi);

  final String rotulo;
  final String valorApi;
}

@immutable
class FiltroObrigacoes {
  const FiltroObrigacoes({
    this.busca = '',
    this.status = const {},
    this.somenteAtrasadas = false,
    this.tipo,
    this.empresaId,
    this.responsavelId,
    this.periodo,
    this.ordem = OrdemDasObrigacoes.vencimentoMaisAntigo,
    this.pagina = 0,
  });

  final String busca;
  final Set<StatusObrigacao> status;
  final bool somenteAtrasadas;
  final TipoObrigacao? tipo;
  final int? empresaId;
  final int? responsavelId;
  final PeriodoDeVencimento? periodo;
  final OrdemDasObrigacoes ordem;
  final int pagina;

  bool get temFiltrosAdicionais => tipo != null || empresaId != null || responsavelId != null || periodo != null;

  bool get contagemPorStatusValida => busca.trim().isEmpty && tipo == null && periodo == null;

  FiltroObrigacoes alterar({
    String? busca,
    Set<StatusObrigacao>? status,
    bool? somenteAtrasadas,
    ValueGetter<TipoObrigacao?>? tipo,
    ValueGetter<int?>? empresaId,
    ValueGetter<int?>? responsavelId,
    ValueGetter<PeriodoDeVencimento?>? periodo,
    OrdemDasObrigacoes? ordem,
    int? pagina,
  }) => FiltroObrigacoes(
    busca: busca ?? this.busca,
    status: status ?? this.status,
    somenteAtrasadas: somenteAtrasadas ?? this.somenteAtrasadas,
    tipo: tipo != null ? tipo() : this.tipo,
    empresaId: empresaId != null ? empresaId() : this.empresaId,
    responsavelId: responsavelId != null ? responsavelId() : this.responsavelId,
    periodo: periodo != null ? periodo() : this.periodo,
    ordem: ordem ?? this.ordem,
    pagina: pagina ?? 0,
  );

  FiltroObrigacoes semFiltrosAdicionais() =>
      FiltroObrigacoes(busca: busca, status: status, somenteAtrasadas: somenteAtrasadas, ordem: ordem);

  @override
  bool operator ==(Object other) =>
      other is FiltroObrigacoes &&
      other.busca == busca &&
      setEquals(other.status, status) &&
      other.somenteAtrasadas == somenteAtrasadas &&
      other.tipo == tipo &&
      other.empresaId == empresaId &&
      other.responsavelId == responsavelId &&
      other.periodo == periodo &&
      other.ordem == ordem &&
      other.pagina == pagina;

  @override
  int get hashCode => Object.hash(
    busca,
    Object.hashAllUnordered(status),
    somenteAtrasadas,
    tipo,
    empresaId,
    responsavelId,
    periodo,
    ordem,
    pagina,
  );
}
