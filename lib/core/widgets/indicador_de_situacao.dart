import 'package:material_ui/material_ui.dart';

import '../dominio/situacao.dart';
import '../dominio/termos_do_cadastro.dart';
import 'icone.dart';
import 'indicador.dart';

class IndicadorDeSituacao extends StatelessWidget {
  const IndicadorDeSituacao({required this.situacao, required this.termos, super.key});

  final Situacao situacao;
  final TermosDoCadastro termos;

  @override
  Widget build(BuildContext context) => situacao == Situacao.ativo
      ? Indicador(icone: Icones.situacaoAtiva, rotulo: termos.situacao(situacao), tom: TomDoIndicador.sucesso)
      : Indicador(icone: Icones.situacaoInativa, rotulo: termos.situacao(situacao), tom: TomDoIndicador.neutro);
}
