import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import '../tema/tema.dart';
import 'icone.dart';

class BotaoDeAcao extends StatelessWidget {
  const BotaoDeAcao({required this.rotulo, required this.icone, required this.aoPressionar, super.key});

  final String rotulo;
  final Icones icone;
  final VoidCallback? aoPressionar;

  @override
  Widget build(BuildContext context) => Medidas.telaEstreita(context)
      ? IconButton.filled(
          tooltip: rotulo,
          onPressed: aoPressionar,
          style: IconButton.styleFrom(backgroundColor: Cores.grafite, foregroundColor: Colors.white),
          icon: Icone(icone),
        )
      : FilledButton.icon(onPressed: aoPressionar, icon: Icone(icone, tamanho: 18), label: Text(rotulo));
}
