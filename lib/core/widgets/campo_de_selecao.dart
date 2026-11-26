import 'package:material_ui/material_ui.dart';

import 'campo_rotulado.dart';

typedef OpcaoDeSelecao<T> = ({T valor, String rotulo});

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
  final List<OpcaoDeSelecao<T>> opcoes;
  final T? valor;
  final ValueChanged<T?> aoSelecionar;
  final bool obrigatorio;
  final String? dica;
  final String? ajuda;
  final FormFieldValidator<T>? validador;

  @override
  Widget build(BuildContext context) => CampoRotulado(
    rotulo: rotulo,
    obrigatorio: obrigatorio,
    child: DropdownButtonFormField<T>(
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(helperText: ajuda, helperMaxLines: 2),
      hint: dica == null ? null : Text(dica!, style: Theme.of(context).inputDecorationTheme.hintStyle),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
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
