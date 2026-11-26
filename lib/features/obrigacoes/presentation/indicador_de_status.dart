import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/icone.dart';
import '../../../core/widgets/indicador.dart';
import '../domain/status_obrigacao.dart';

extension AparenciaDoStatus on StatusObrigacao {
  Icones get icone => switch (this) {
    StatusObrigacao.pendente => Icones.statusPendente,
    StatusObrigacao.emAndamento => Icones.statusEmAndamento,
    StatusObrigacao.concluida => Icones.statusConcluida,
  };

  TomDoIndicador get tom => switch (this) {
    StatusObrigacao.pendente => TomDoIndicador.atencao,
    StatusObrigacao.emAndamento => TomDoIndicador.informacao,
    StatusObrigacao.concluida => TomDoIndicador.sucesso,
  };
}

class IndicadorDeStatus extends StatelessWidget {
  const IndicadorDeStatus(this.status, {super.key});

  final StatusObrigacao status;

  @override
  Widget build(BuildContext context) => Indicador(icone: status.icone, rotulo: status.rotulo, tom: status.tom);
}
