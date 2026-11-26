import 'package:material_ui/material_ui.dart';

import '../dominio/situacao.dart';
import '../dominio/termos_do_cadastro.dart';
import 'avisos.dart';

Future<void> alterarSituacao(
  BuildContext context, {
  required String nome,
  required Situacao atual,
  required TermosDoCadastro termos,
  required String consequenciaDaInativacao,
  required Future<void> Function(Situacao nova) alterar,
}) async {
  final nova = atual.oposta;
  if (nova == Situacao.inativo) {
    final confirmado = await confirmar(
      context,
      titulo: 'Inativar $nome?',
      mensagem: consequenciaDaInativacao,
      acao: 'Inativar',
    );
    if (!confirmado) {
      return;
    }
  }
  try {
    await alterar(nova);
    if (context.mounted) {
      avisarSucesso(context, termos.alteracaoConcluida(nova));
    }
  } catch (erro, pilha) {
    if (context.mounted) {
      avisarFalha(context, erro, pilha);
    }
  }
}
