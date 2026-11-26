import 'package:material_ui/material_ui.dart';

import '../http/erro_api.dart';

class ErroEmLinha extends StatelessWidget {
  const ErroEmLinha({required this.erro, required this.aoTentarNovamente, super.key});

  final Object erro;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Semantics(
          liveRegion: true,
          child: Text(ErroApi.mensagemPara(erro), style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
      TextButton(onPressed: aoTentarNovamente, child: const Text('Tentar novamente')),
    ],
  );
}
