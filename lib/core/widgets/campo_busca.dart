import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';
import 'icone.dart';

class CampoBusca extends StatefulWidget {
  const CampoBusca({required this.dica, required this.aoBuscar, this.valorInicial = '', super.key});

  static const espera = Duration(milliseconds: 400);

  final String dica;
  final String valorInicial;
  final ValueChanged<String> aoBuscar;

  @override
  State<CampoBusca> createState() => _CampoBuscaState();
}

class _CampoBuscaState extends State<CampoBusca> {
  late final _controlador = TextEditingController(text: widget.valorInicial);
  Timer? _espera;

  @override
  void didUpdateWidget(CampoBusca anterior) {
    super.didUpdateWidget(anterior);
    if (widget.valorInicial != anterior.valorInicial && widget.valorInicial != _controlador.text) {
      _espera?.cancel();
      _controlador.text = widget.valorInicial;
    }
  }

  @override
  void dispose() {
    _espera?.cancel();
    _controlador.dispose();
    super.dispose();
  }

  void _agendar(String texto) {
    _espera?.cancel();
    _espera = Timer(CampoBusca.espera, () => widget.aoBuscar(texto));
  }

  void _limpar() {
    _espera?.cancel();
    _controlador.clear();
    widget.aoBuscar('');
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controlador,
    onChanged: _agendar,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: widget.dica,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icone(Icones.buscar, tamanho: TamanhosDeIcone.padrao, cor: context.cores.textoVariante),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 44),
      suffixIcon: ListenableBuilder(
        listenable: _controlador,
        builder: (context, _) => _controlador.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                tooltip: 'Limpar busca',
                onPressed: _limpar,
                icon: Icone(Icones.limpar, tamanho: TamanhosDeIcone.padrao, cor: context.cores.textoVariante),
              ),
      ),
    ),
  );
}
