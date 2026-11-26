import 'package:material_ui/material_ui.dart';

import '../dominio/filtro_cadastro.dart';
import '../dominio/situacao.dart';
import '../dominio/termos_do_cadastro.dart';
import 'campo_busca.dart';

class FiltrosDeCadastro extends StatelessWidget {
  const FiltrosDeCadastro({
    required this.dica,
    required this.termos,
    required this.filtro,
    required this.aoBuscar,
    required this.aoFiltrarPorSituacao,
    super.key,
  });

  final String dica;
  final TermosDoCadastro termos;
  final FiltroCadastro filtro;
  final ValueChanged<String> aoBuscar;
  final ValueChanged<Situacao?> aoFiltrarPorSituacao;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 12,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: CampoBusca(dica: dica, valorInicial: filtro.busca, aoBuscar: aoBuscar),
      ),
      SegmentedButton<Situacao?>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(value: null, label: Text(termos.todos)),
          ButtonSegment(value: Situacao.ativo, label: Text(termos.ativos)),
          ButtonSegment(value: Situacao.inativo, label: Text(termos.inativos)),
        ],
        selected: {filtro.situacao},
        onSelectionChanged: (selecao) => aoFiltrarPorSituacao(selecao.single),
      ),
    ],
  );
}
