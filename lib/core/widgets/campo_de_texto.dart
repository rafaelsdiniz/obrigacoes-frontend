import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../formatacao/validacoes.dart';
import 'campo_rotulado.dart';

class CampoDeTexto extends StatelessWidget {
  const CampoDeTexto({
    required this.rotulo,
    required this.controlador,
    this.obrigatorio = false,
    this.dica,
    this.ajuda,
    this.validador,
    this.aoAlterar,
    this.aoConfirmar,
    this.teclado,
    this.formatadores,
    this.capitalizacao = TextCapitalization.none,
    this.acaoDoTeclado = TextInputAction.next,
    this.linhas = 1,
    super.key,
  });

  final String rotulo;
  final TextEditingController controlador;
  final bool obrigatorio;
  final String? dica;
  final String? ajuda;
  final Validador? validador;
  final ValueChanged<String>? aoAlterar;
  final ValueChanged<String>? aoConfirmar;
  final TextInputType? teclado;
  final List<TextInputFormatter>? formatadores;
  final TextCapitalization capitalizacao;
  final TextInputAction acaoDoTeclado;
  final int linhas;

  @override
  Widget build(BuildContext context) => CampoRotulado(
    rotulo: rotulo,
    obrigatorio: obrigatorio,
    child: TextFormField(
      controller: controlador,
      decoration: InputDecoration(hintText: dica, helperText: ajuda, helperMaxLines: 2, errorMaxLines: 3),
      validator: validador,
      onChanged: aoAlterar,
      onFieldSubmitted: aoConfirmar,
      keyboardType: linhas > 1 ? TextInputType.multiline : teclado,
      inputFormatters: formatadores,
      textCapitalization: capitalizacao,
      textInputAction: linhas > 1 ? TextInputAction.newline : acaoDoTeclado,
      minLines: linhas,
      maxLines: linhas,
    ),
  );
}
