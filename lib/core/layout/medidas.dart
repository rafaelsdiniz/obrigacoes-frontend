import 'package:material_ui/material_ui.dart';

abstract final class Medidas {
  static const larguraParaBarraLateral = 900.0;
  static const alturaParaBarraLateral = 520.0;
  static const larguraParaColunas = 760.0;
  static const larguraParaRotulosNosBotoes = 600.0;
  static const larguraParaMargemAmpla = 1280.0;
  static const larguraMaximaDoFormulario = 1120.0;

  static const _margemAmpla = 56.0;
  static const _margemMedia = 32.0;
  static const _margemEstreita = 16.0;
  static const _respiroSuperior = 40.0;
  static const _respiroSuperiorEstreito = 20.0;

  static bool telaLarga(BuildContext context) {
    final tamanho = MediaQuery.sizeOf(context);
    return tamanho.width >= larguraParaBarraLateral && tamanho.height >= alturaParaBarraLateral;
  }

  static bool telaEstreita(BuildContext context) => MediaQuery.sizeOf(context).width < larguraParaRotulosNosBotoes;

  static EdgeInsets margemDaPagina(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    final estreita = largura < larguraParaRotulosNosBotoes;
    final horizontal = largura >= larguraParaMargemAmpla
        ? _margemAmpla
        : estreita
        ? _margemEstreita
        : _margemMedia;
    return EdgeInsets.fromLTRB(
      horizontal,
      estreita ? _respiroSuperiorEstreito : _respiroSuperior,
      horizontal,
      _respiroSuperior,
    );
  }
}
