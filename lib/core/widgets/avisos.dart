import 'package:material_ui/material_ui.dart';

import '../http/erro_api.dart';

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String acao,
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(acao)),
      ],
    ),
  );
  return confirmado ?? false;
}

void avisarSucesso(BuildContext context, String mensagem) => _avisar(context, mensagem);

void avisarFalha(BuildContext context, Object erro, StackTrace pilha, {SnackBarAction? acao}) {
  if (erro is! ErroApi) {
    FlutterError.reportError(FlutterErrorDetails(exception: erro, stack: pilha, library: 'obrigacoes_app'));
  }
  _avisar(context, ErroApi.mensagemPara(erro), cor: Theme.of(context).colorScheme.error, acao: acao);
}

void _avisar(BuildContext context, String mensagem, {Color? cor, SnackBarAction? acao}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: cor, action: acao, behavior: SnackBarBehavior.floating),
    );
}
