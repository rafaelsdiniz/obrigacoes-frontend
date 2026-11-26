import 'package:flutter_riverpod/flutter_riverpod.dart';

final alteracoesDeCadastroProvider = NotifierProvider<AlteracoesDeCadastro, int>(AlteracoesDeCadastro.new);

class AlteracoesDeCadastro extends Notifier<int> {
  @override
  int build() => 0;

  void registrar() => state++;
}
