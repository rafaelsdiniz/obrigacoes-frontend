import 'package:material_ui/material_ui.dart';

import 'conteudo_limitado.dart';

class PaginaDeListagem extends StatelessWidget {
  const PaginaDeListagem({
    required this.titulo,
    required this.rotuloNovo,
    required this.aoCriarNovo,
    required this.filtros,
    required this.conteudo,
    super.key,
  });

  static const larguraParaBotaoComRotulo = 600.0;

  final String titulo;
  final String rotuloNovo;
  final VoidCallback aoCriarNovo;
  final Widget filtros;
  final Widget conteudo;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(titulo)),
    floatingActionButton: MediaQuery.sizeOf(context).width >= larguraParaBotaoComRotulo
        ? FloatingActionButton.extended(onPressed: aoCriarNovo, icon: const Icon(Icons.add), label: Text(rotuloNovo))
        : FloatingActionButton(onPressed: aoCriarNovo, tooltip: rotuloNovo, child: const Icon(Icons.add)),
    body: ConteudoLimitado(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          filtros,
          const SizedBox(height: 8),
          Expanded(child: conteudo),
        ],
      ),
    ),
  );
}
