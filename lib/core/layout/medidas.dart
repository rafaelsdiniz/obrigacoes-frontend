import 'package:material_ui/material_ui.dart';

abstract final class Medidas {
  static const larguraParaBarraLateral = 900.0;
  static const alturaParaBarraLateral = 520.0;
  static const larguraParaColunas = 760.0;
  static const larguraDeTelaEstreita = 600.0;
  static const larguraParaMargemAmpla = 1280.0;
  static const larguraMaximaDaPagina = 1600.0;
  static const alturaDoControle = 48.0;
  static const espacoEntreControles = 12.0;

  static const _larguraDaBusca = 400.0;
  static const _larguraParaBuscaCompacta = 680.0;

  static const _margemAmpla = 56.0;
  static const _margemMedia = 32.0;
  static const _margemEstreita = 16.0;
  static const _respiroSuperior = 40.0;
  static const _respiroSuperiorEstreito = 20.0;

  static double larguraDaBusca(double disponivel) =>
      disponivel < _larguraParaBuscaCompacta ? disponivel : _larguraDaBusca;

  static bool telaLarga(BuildContext context) {
    final tamanho = MediaQuery.sizeOf(context);
    return tamanho.width >= larguraParaBarraLateral && tamanho.height >= alturaParaBarraLateral;
  }

  static bool telaEstreita(BuildContext context) => MediaQuery.sizeOf(context).width < larguraDeTelaEstreita;

  static EdgeInsets margemDaPagina(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    final estreita = largura < larguraDeTelaEstreita;
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
