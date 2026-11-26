import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';
import 'icone.dart';

class AvisoDeEstado extends StatelessWidget {
  const AvisoDeEstado({required this.icone, required this.titulo, required this.mensagem, this.acao, super.key});

  final Icones icone;
  final String titulo;
  final String mensagem;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(color: Cores.fundo, shape: BoxShape.circle),
              child: SizedBox.square(
                dimension: 72,
                child: Center(child: Icone(icone, tamanho: 30, cor: Cores.textoSecundario)),
              ),
            ),
            const SizedBox(height: 20),
            Text(titulo, style: tema.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                mensagem,
                style: tema.bodyMedium?.copyWith(color: Cores.textoSecundario),
                textAlign: TextAlign.center,
              ),
            ),
            if (acao case final acao?) ...[const SizedBox(height: 24), acao],
          ],
        ),
      ),
    );
  }
}
