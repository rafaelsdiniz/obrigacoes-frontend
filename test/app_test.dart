import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/app/app.dart';

void main() {
  testWidgets('inicializa a aplicação', (tester) async {
    await tester.pumpWidget(const ObrigacoesApp());

    expect(find.text('Gerenciamento de Obrigações'), findsOneWidget);
  });
}
