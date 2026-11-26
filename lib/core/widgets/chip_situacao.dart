import 'package:material_ui/material_ui.dart';

import '../dominio/situacao.dart';
import '../dominio/termos_do_cadastro.dart';
import 'selo.dart';

class ChipSituacao extends StatelessWidget {
  const ChipSituacao({required this.situacao, required this.termos, super.key});

  final Situacao situacao;
  final TermosDoCadastro termos;

  @override
  Widget build(BuildContext context) =>
      Selo(rotulo: termos.situacao(situacao), tom: situacao == Situacao.ativo ? TomDoSelo.sucesso : TomDoSelo.neutro);
}
