import 'package:material_ui/material_ui.dart';

import '../http/erro_api.dart';
import 'aviso_de_estado.dart';

class EstadoErro extends StatelessWidget {
  const EstadoErro({required this.erro, required this.aoTentarNovamente, super.key});

  final Object erro;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) => AvisoDeEstado(
    icone: Icons.cloud_off_outlined,
    titulo: 'Não foi possível carregar',
    mensagem: ErroApi.mensagemPara(erro),
    acao: FilledButton.icon(
      onPressed: aoTentarNovamente,
      icon: const Icon(Icons.refresh_rounded, size: 20),
      label: const Text('Tentar novamente'),
    ),
  );
}
