import 'package:material_ui/material_ui.dart';

import '../tema/tema.dart';

class AvatarDeIniciais extends StatelessWidget {
  const AvatarDeIniciais(this.nome, {super.key});

  final String nome;

  static String iniciaisDe(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+')).where((parte) => parte.isNotEmpty).toList();
    if (partes.isEmpty) {
      return '?';
    }
    final primeira = partes.first.characters.first;
    final ultima = partes.length > 1 ? partes.last.characters.first : '';
    return '$primeira$ultima'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: DecoratedBox(
      decoration: const BoxDecoration(color: Cores.douradoSuave, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: 40,
        child: Center(
          child: Text(
            iniciaisDe(nome),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Cores.douradoTexto),
          ),
        ),
      ),
    ),
  );
}
