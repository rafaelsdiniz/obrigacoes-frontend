import 'package:material_ui/material_ui.dart';

import '../http/erro_api.dart';
import 'aviso_de_estado.dart';
import 'icone.dart';

class EstadoErro extends StatelessWidget {
  const EstadoErro({required this.erro, required this.aoTentarNovamente, super.key});

  final Object erro;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) => AvisoDeEstado(
    icone: Icones.semConexao,
    titulo: 'Não foi possível carregar',
    mensagem: ErroApi.mensagemPara(erro),
    acao: FilledButton.icon(
      onPressed: aoTentarNovamente,
      icon: const Icone(Icones.recarregar, tamanho: 18),
      label: const Text('Tentar novamente'),
    ),
  );
}
