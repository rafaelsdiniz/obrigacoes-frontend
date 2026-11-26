import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dominio/filtro_cadastro.dart';
import '../dominio/situacao.dart';

class FiltroCadastroNotifier extends Notifier<FiltroCadastro> {
  @override
  FiltroCadastro build() => const FiltroCadastro();

  void buscar(String texto) {
    if (texto.trim() != state.busca.trim()) {
      state = FiltroCadastro(busca: texto, situacao: state.situacao);
    }
  }

  void filtrarPorSituacao(Situacao? situacao) {
    if (situacao != state.situacao) {
      state = FiltroCadastro(busca: state.busca, situacao: situacao);
    }
  }

  void irParaPagina(int pagina) => state = FiltroCadastro(busca: state.busca, situacao: state.situacao, pagina: pagina);
}
