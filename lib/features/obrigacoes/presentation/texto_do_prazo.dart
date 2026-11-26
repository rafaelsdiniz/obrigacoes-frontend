import 'package:material_ui/material_ui.dart';

import '../../../core/tema/tema.dart';
import '../../../core/widgets/icone.dart';
import '../domain/prazo.dart';

class TextoDoPrazo extends StatelessWidget {
  const TextoDoPrazo(this.prazo, {super.key});

  final Prazo prazo;

  @override
  Widget build(BuildContext context) {
    final cor = switch (prazo.urgencia) {
      UrgenciaDoPrazo.atrasada => Cores.erro,
      UrgenciaDoPrazo.venceHoje || UrgenciaDoPrazo.proxima => Cores.atencao,
      UrgenciaDoPrazo.tranquila || UrgenciaDoPrazo.concluida => Cores.textoSecundario,
    };
    final estilo = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: cor, fontWeight: prazo.urgencia == UrgenciaDoPrazo.atrasada ? FontWeight.w600 : null);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prazo.urgencia == UrgenciaDoPrazo.atrasada) ...[
          Icone(Icones.statusAtrasada, tamanho: 14, cor: cor),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(prazo.descricao, style: estilo, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
