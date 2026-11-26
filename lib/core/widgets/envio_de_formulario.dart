import 'package:material_ui/material_ui.dart';

import '../formatacao/validacoes.dart';
import '../http/erro_api.dart';
import 'avisos.dart';

mixin EnvioDeFormulario<W extends StatefulWidget> on State<W> {
  final chaveFormulario = GlobalKey<FormState>();
  bool salvando = false;
  Map<String, String> _errosDoServidor = const {};

  Validador validarCampo(String campo, [Validador? validacaoLocal]) =>
      (valor) => _errosDoServidor[campo] ?? validacaoLocal?.call(valor);

  void campoAlterado(String campo) {
    if (_errosDoServidor.containsKey(campo)) {
      _errosDoServidor = {..._errosDoServidor}..remove(campo);
    }
  }

  Future<void> enviar(
    Future<void> Function() acao, {
    required VoidCallback aoConcluir,
    VoidCallback? aoConflitoDeVersao,
  }) async {
    if (salvando) {
      return;
    }
    _errosDoServidor = const {};
    if (!(chaveFormulario.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => salvando = true);
    try {
      await acao();
      if (mounted) {
        aoConcluir();
      }
    } on ErroApi catch (erro, pilha) {
      if (!mounted) {
        return;
      }
      _errosDoServidor = erro.errosPorCampo;
      chaveFormulario.currentState?.validate();
      final conflitoDeVersao = erro.codigo == CodigoErro.conflito && erro.errosPorCampo.isEmpty;
      avisarFalha(
        context,
        erro,
        pilha,
        acao: conflitoDeVersao && aoConflitoDeVersao != null
            ? SnackBarAction(label: 'Recarregar', onPressed: aoConflitoDeVersao)
            : null,
      );
    } catch (erro, pilha) {
      if (mounted) {
        avisarFalha(context, erro, pilha);
      }
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }
}
