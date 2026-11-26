import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import '../tema/tema.dart';
import 'campo_do_formulario.dart';

class SecaoDoFormulario extends StatelessWidget {
  const SecaoDoFormulario({required this.titulo, required this.descricao, required this.campos, super.key});

  static const _larguraDaDescricao = 240.0;
  static const _larguraParaDuasColunasDeCampos = 480.0;
  static const _espacamento = 20.0;

  final String titulo;
  final String descricao;
  final List<CampoDoFormulario> campos;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, restricoes) {
      final lado = restricoes.maxWidth >= Medidas.larguraParaColunas;
      final cabecalho = _CabecalhoDaSecao(titulo: titulo, descricao: descricao);
      final grade = _GradeDeCampos(campos: campos);
      if (!lado) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [cabecalho, const SizedBox(height: 20), grade],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: _larguraDaDescricao, child: cabecalho),
          const SizedBox(width: 40),
          Expanded(child: grade),
        ],
      );
    },
  );
}

class _CabecalhoDaSecao extends StatelessWidget {
  const _CabecalhoDaSecao({required this.titulo, required this.descricao});

  final String titulo;
  final String descricao;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(header: true, child: Text(titulo, style: Theme.of(context).textTheme.titleMedium)),
      const SizedBox(height: 4),
      Text(descricao, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario)),
    ],
  );
}

class _GradeDeCampos extends StatelessWidget {
  const _GradeDeCampos({required this.campos});

  final List<CampoDoFormulario> campos;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, restricoes) {
      final duasColunas = restricoes.maxWidth >= SecaoDoFormulario._larguraParaDuasColunasDeCampos;
      final meiaLargura = (restricoes.maxWidth - SecaoDoFormulario._espacamento) / 2;
      return Wrap(
        spacing: SecaoDoFormulario._espacamento,
        runSpacing: SecaoDoFormulario._espacamento,
        children: [
          for (final campo in campos)
            SizedBox(
              width: duasColunas && !campo.larguraInteira ? meiaLargura : restricoes.maxWidth,
              child: campo.campo,
            ),
        ],
      );
    },
  );
}
