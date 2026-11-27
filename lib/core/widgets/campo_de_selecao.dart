import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';
import 'campo_rotulado.dart';
import 'opcao.dart';

class CampoDeSelecao<T> extends StatelessWidget {
  const CampoDeSelecao({
    required this.rotulo,
    required this.opcoes,
    required this.valor,
    required this.aoSelecionar,
    this.obrigatorio = false,
    this.dica,
    this.ajuda,
    this.validador,
    super.key,
  });

  final String rotulo;
  final List<Opcao<T>> opcoes;
  final T? valor;
  final ValueChanged<T?> aoSelecionar;
  final bool obrigatorio;
  final String? dica;
  final String? ajuda;
  final FormFieldValidator<T>? validador;

  T? get _valorEntreAsOpcoes => opcoes.any((opcao) => opcao.valor == valor) ? valor : null;

  @override
  Widget build(BuildContext context) => CampoRotulado(
    rotulo: rotulo,
    obrigatorio: obrigatorio,
    child: DropdownButtonFormField<T>(
      key: ValueKey(_valorEntreAsOpcoes != null),
      initialValue: _valorEntreAsOpcoes,
      isExpanded: true,
      decoration: InputDecoration(helperText: ajuda, helperMaxLines: 2),
      hint: dica == null ? null : Text(dica!, style: Theme.of(context).inputDecorationTheme.hintStyle),
      borderRadius: Raios.cartao,
      items: [
        for (final opcao in opcoes)
          DropdownMenuItem(
            value: opcao.valor,
            child: Text(opcao.rotulo, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: aoSelecionar,
      validator: validador,
    ),
  );
}
