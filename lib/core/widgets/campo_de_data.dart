import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../formatacao/datas.dart';
import '../tema/tema.dart';
import 'campo_rotulado.dart';
import 'icone.dart';

class CampoDeData extends StatefulWidget {
  const CampoDeData({
    required this.rotulo,
    required this.valor,
    required this.aoSelecionar,
    required this.primeiraData,
    required this.ultimaData,
    this.obrigatorio = false,
    this.validador,
    super.key,
  });

  final String rotulo;
  final DateTime? valor;
  final ValueChanged<DateTime> aoSelecionar;
  final DateTime primeiraData;
  final DateTime ultimaData;
  final bool obrigatorio;
  final FormFieldValidator<DateTime>? validador;

  @override
  State<CampoDeData> createState() => _CampoDeDataState();
}

class _CampoDeDataState extends State<CampoDeData> {
  late final _controlador = TextEditingController(text: _texto(widget.valor));

  @override
  void didUpdateWidget(CampoDeData anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.valor != widget.valor) {
      _controlador.text = _texto(widget.valor);
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  static String _texto(DateTime? data) => data == null ? '' : Datas.formatar(data);

  void _abrirCalendario() => unawaited(_escolher());

  Future<void> _escolher() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: widget.valor ?? Datas.hoje(),
      firstDate: widget.primeiraData,
      lastDate: widget.ultimaData,
      helpText: widget.rotulo,
    );
    if (escolhida != null) {
      widget.aoSelecionar(escolhida);
    }
  }

  @override
  Widget build(BuildContext context) => CampoRotulado(
    rotulo: widget.rotulo,
    obrigatorio: widget.obrigatorio,
    child: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): _abrirCalendario,
        const SingleActivator(LogicalKeyboardKey.space): _abrirCalendario,
      },
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: _controlador,
        readOnly: true,
        onTap: _abrirCalendario,
        validator: (_) => widget.validador?.call(widget.valor),
        decoration: InputDecoration(
          hintText: 'dd/mm/aaaa',
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icone(Icones.calendario, tamanho: TamanhosDeIcone.padrao, cor: context.cores.textoVariante),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 44),
        ),
      ),
    ),
  );
}
