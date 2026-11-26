import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/widgets/icone.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('todo ícone do catálogo tem um SVG empacotado que usa a cor do tema', () async {
    for (final icone in Icones.values) {
      final svg = await rootBundle.loadString(icone.caminho);
      expect(svg, contains('stroke="currentColor"'), reason: icone.caminho);
    }
  });
}
