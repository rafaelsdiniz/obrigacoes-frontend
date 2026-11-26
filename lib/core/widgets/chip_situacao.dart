import 'package:material_ui/material_ui.dart';

import '../dominio/situacao.dart';
import '../dominio/termos_do_cadastro.dart';

class ChipSituacao extends StatelessWidget {
  const ChipSituacao({required this.situacao, required this.termos, super.key});

  final Situacao situacao;
  final TermosDoCadastro termos;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final ativo = situacao == Situacao.ativo;
    return Chip(
      label: Text(termos.situacao(situacao)),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      backgroundColor: ativo ? cores.primaryContainer : cores.surfaceContainerHighest,
      labelStyle: TextStyle(color: ativo ? cores.onPrimaryContainer : cores.onSurfaceVariant),
    );
  }
}
