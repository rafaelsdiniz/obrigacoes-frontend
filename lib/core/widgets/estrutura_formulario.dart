import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'conteudo_limitado.dart';

class EstruturaFormulario extends StatelessWidget {
  const EstruturaFormulario({
    required this.titulo,
    required this.chave,
    required this.campos,
    required this.salvando,
    required this.aoSalvar,
    super.key,
  });

  final String titulo;
  final GlobalKey<FormState> chave;
  final List<Widget> campos;
  final bool salvando;
  final Future<void> Function() aoSalvar;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(titulo)),
    body: Form(
      key: chave,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ConteudoLimitado(
        larguraMaxima: 720,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            for (final campo in campos) Padding(padding: const EdgeInsets.only(bottom: 16), child: campo),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: salvando ? null : () => unawaited(aoSalvar()),
                icon: salvando
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check),
                label: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
