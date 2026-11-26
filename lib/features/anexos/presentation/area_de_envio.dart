import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/arquivos/arquivos_do_dispositivo.dart';
import '../../../core/formatacao/tamanhos.dart';
import '../../../core/layout/medidas.dart';
import '../../../core/tema/tema.dart';
import '../../../core/widgets/icone.dart';
import '../domain/anexo.dart';
import '../domain/tipo_de_anexo.dart';

class AreaDeEnvio extends StatefulWidget {
  const AreaDeEnvio({
    required this.enviando,
    required this.habilitada,
    required this.aoEscolher,
    required this.aoSoltar,
    super.key,
  });

  final String? enviando;
  final bool habilitada;
  final VoidCallback aoEscolher;
  final ValueChanged<List<ArquivoEscolhido>> aoSoltar;

  @override
  State<AreaDeEnvio> createState() => _AreaDeEnvioState();
}

class _AreaDeEnvioState extends State<AreaDeEnvio> {
  static const _raio = Raios.cartao;

  bool _arrastando = false;

  void _marcarArraste({required bool arrastando}) {
    if (_arrastando != arrastando) {
      setState(() => _arrastando = arrastando);
    }
  }

  void _soltar(DropDoneDetails detalhes) {
    _marcarArraste(arrastando: false);
    if (widget.habilitada && detalhes.files.isNotEmpty) {
      widget.aoSoltar([for (final arquivo in detalhes.files) arquivoSolto(arquivo)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final tema = Theme.of(context).textTheme;
    final enviando = widget.enviando;
    final destaque = _arrastando && widget.habilitada;
    final titulo = switch ((enviando, destaque)) {
      (final nome?, _) => 'Enviando $nome…',
      (null, true) => 'Solte para anexar',
      _ when Medidas.telaEstreita(context) => 'Toque para escolher um arquivo',
      _ => 'Arraste arquivos para cá ou clique para escolher',
    };
    return DropTarget(
      enable: widget.habilitada,
      onDragEntered: (_) => _marcarArraste(arrastando: true),
      onDragExited: (_) => _marcarArraste(arrastando: false),
      onDragDone: _soltar,
      child: CustomPaint(
        foregroundPainter: _BordaTracejada(cor: destaque ? cores.primaria : cores.contornoVariante, raio: _raio),
        child: Material(
          color: destaque ? cores.secundarioContainer : cores.superficieBaixa.withValues(alpha: 0.5),
          borderRadius: _raio,
          child: InkWell(
            onTap: widget.habilitada ? widget.aoEscolher : null,
            borderRadius: _raio,
            hoverColor: cores.realce,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: cores.superficieMaisBaixa,
                      shape: BoxShape.circle,
                      border: Border.all(color: cores.bordaSuave),
                    ),
                    child: SizedBox.square(
                      dimension: 48,
                      child: Center(
                        child: Icone(Icones.enviarArquivo, tamanho: TamanhosDeIcone.grande, cor: cores.primaria),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Semantics(
                      liveRegion: enviando != null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo, style: tema.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            '${TipoDeAnexo.descricaoDosAceitos}  ·  até ${Tamanhos.formatar(Anexo.tamanhoMaximo)}',
                            style: tema.bodySmall,
                          ),
                          if (enviando != null) ...[const SizedBox(height: 10), const LinearProgressIndicator()],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BordaTracejada extends CustomPainter {
  const _BordaTracejada({required this.cor, required this.raio});

  static const _traco = 6.0;
  static const _intervalo = 4.0;

  final Color cor;
  final BorderRadius raio;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final contorno = Path()..addRRect(raio.toRRect(Offset.zero & size).deflate(0.75));
    for (final PathMetric medida in contorno.computeMetrics()) {
      for (var inicio = 0.0; inicio < medida.length; inicio += _traco + _intervalo) {
        canvas.drawPath(medida.extractPath(inicio, inicio + _traco), pincel);
      }
    }
  }

  @override
  bool shouldRepaint(_BordaTracejada anterior) => anterior.cor != cor || anterior.raio != raio;
}
