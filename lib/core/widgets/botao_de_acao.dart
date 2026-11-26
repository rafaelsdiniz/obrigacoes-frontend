import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';

class BotaoDeAcao extends StatelessWidget {
  const BotaoDeAcao({required this.rotulo, required this.icone, required this.aoPressionar, super.key});

  final String rotulo;
  final IconData icone;
  final VoidCallback? aoPressionar;

  @override
  Widget build(BuildContext context) => Medidas.telaEstreita(context)
      ? IconButton.filled(tooltip: rotulo, onPressed: aoPressionar, icon: Icon(icone))
      : FilledButton.icon(onPressed: aoPressionar, icon: Icon(icone, size: 20), label: Text(rotulo));
}
