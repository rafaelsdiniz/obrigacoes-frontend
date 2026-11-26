import 'package:material_ui/material_ui.dart';

import 'icone.dart';

class ProgressoNoBotao extends StatelessWidget {
  const ProgressoNoBotao({this.cor, this.rotulo, super.key});

  final Color? cor;
  final String? rotulo;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: TamanhosDeIcone.padrao,
    child: CircularProgressIndicator(strokeWidth: 2, color: cor, semanticsLabel: rotulo),
  );
}
