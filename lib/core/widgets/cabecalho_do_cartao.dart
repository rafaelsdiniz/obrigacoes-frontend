import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';
import 'icone.dart';

class CabecalhoDoCartao extends StatelessWidget {
  const CabecalhoDoCartao({required this.titulo, this.icone, this.detalhe, this.acao, super.key});

  final String titulo;
  final Icones? icone;
  final String? detalhe;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final icone = this.icone;
    final detalhe = this.detalhe;
    final acao = this.acao;
    final titulo = Wrap(
      spacing: 10,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Semantics(
          header: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icone != null) ...[
                Icone(icone, tamanho: TamanhosDeIcone.padrao, cor: cores.textoVariante),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(this.titulo, style: Theme.of(context).textTheme.titleMedium)),
            ],
          ),
        ),
        if (detalhe != null) Text(detalhe, style: Tema.mono(context, cor: cores.textoVariante)),
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cores.bordaSuave)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, acao == null ? 16 : 10, acao == null ? 20 : 12, acao == null ? 16 : 10),
        child: acao == null
            ? titulo
            : Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [titulo, acao],
              ),
      ),
    );
  }
}
