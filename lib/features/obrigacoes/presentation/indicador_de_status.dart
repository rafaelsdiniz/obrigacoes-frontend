import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/icone.dart';
import '../../../core/widgets/indicador.dart';
import '../domain/status_obrigacao.dart';

class IndicadorDeStatus extends StatelessWidget {
  const IndicadorDeStatus(this.status, {super.key});

  final StatusObrigacao status;

  @override
  Widget build(BuildContext context) => switch (status) {
    StatusObrigacao.pendente => Indicador(
      icone: Icones.statusPendente,
      rotulo: status.rotulo,
      tom: TomDoIndicador.atencao,
    ),
    StatusObrigacao.emAndamento => Indicador(
      icone: Icones.statusEmAndamento,
      rotulo: status.rotulo,
      tom: TomDoIndicador.informacao,
    ),
    StatusObrigacao.concluida => Indicador(
      icone: Icones.statusConcluida,
      rotulo: status.rotulo,
      tom: TomDoIndicador.sucesso,
    ),
  };
}
