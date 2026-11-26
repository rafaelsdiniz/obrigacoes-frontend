import 'package:material_ui/material_ui.dart';

class AvisoDeEstado extends StatelessWidget {
  const AvisoDeEstado({required this.icone, required this.titulo, required this.mensagem, this.acao, super.key});

  final IconData icone;
  final String titulo;
  final String mensagem;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: tema.colorScheme.outline),
            const SizedBox(height: 16),
            Text(titulo, style: tema.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(mensagem, style: tema.textTheme.bodyMedium, textAlign: TextAlign.center),
            if (acao case final acao?) ...[const SizedBox(height: 20), acao],
          ],
        ),
      ),
    );
  }
}
