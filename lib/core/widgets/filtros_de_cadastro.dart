import 'package:material_ui/material_ui.dart';

import '../dominio/filtro_cadastro.dart';
import '../dominio/situacao.dart';
import '../dominio/termos_do_cadastro.dart';
import '../layout/medidas.dart';
import 'campo_busca.dart';
import 'controle_segmentado.dart';

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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, restricoes) => Wrap(
      spacing: Medidas.espacoEntreControles,
      runSpacing: Medidas.espacoEntreControles,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: Medidas.larguraDaBusca(restricoes.maxWidth),
          child: CampoBusca(dica: dica, valorInicial: filtro.busca, aoBuscar: aoBuscar),
        ),
        ControleSegmentado<Situacao?>(
          opcoes: [
            (valor: null, rotulo: termos.todos),
            (valor: Situacao.ativo, rotulo: termos.ativos),
            (valor: Situacao.inativo, rotulo: termos.inativos),
          ],
          selecionado: filtro.situacao,
          aoSelecionar: aoFiltrarPorSituacao,
        ),
      ],
    ),
  );
}
