import 'package:material_ui/material_ui.dart';

import 'aviso_de_estado.dart';
import 'icone.dart';

class EstadoVazio extends StatelessWidget {
  const EstadoVazio({required this.icone, required this.titulo, required this.mensagem, super.key});

  final Icones icone;
  final String titulo;
  final String mensagem;

  @override
  Widget build(BuildContext context) => AvisoDeEstado(icone: icone, titulo: titulo, mensagem: mensagem);
}
