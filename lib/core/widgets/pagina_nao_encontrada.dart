import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'aviso_de_estado.dart';
import 'icone.dart';

class PaginaNaoEncontrada extends StatelessWidget {
  const PaginaNaoEncontrada({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: AvisoDeEstado(
        icone: Icones.naoEncontrado,
        titulo: 'Página não encontrada',
        mensagem: 'O endereço acessado não existe ou foi removido.',
        acao: FilledButton(onPressed: () => context.go('/'), child: const Text('Ir para o início')),
      ),
    ),
  );
}
