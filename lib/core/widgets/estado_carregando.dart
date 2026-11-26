import 'package:material_ui/material_ui.dart';

class EstadoCarregando extends StatelessWidget {
  const EstadoCarregando({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}
