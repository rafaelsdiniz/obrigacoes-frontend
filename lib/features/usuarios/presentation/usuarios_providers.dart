import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dominio/filtro_cadastro.dart';
import '../../../core/dominio/situacao.dart';
import '../../../core/estado/alteracoes_de_cadastro.dart';
import '../../../core/estado/filtro_cadastro_notifier.dart';
import '../../../core/http/pagina.dart';
import '../data/usuario_repository.dart';
import '../domain/usuario.dart';

final filtroUsuariosProvider = NotifierProvider<FiltroCadastroNotifier, FiltroCadastro>(FiltroCadastroNotifier.new);

final paginaUsuariosProvider = FutureProvider.autoDispose<Pagina<Usuario>>(
  (ref) => ref.watch(usuarioRepositoryProvider).listar(ref.watch(filtroUsuariosProvider)),
);

final usuarioProvider = FutureProvider.autoDispose.family<Usuario, int>(
  (ref, id) => ref.watch(usuarioRepositoryProvider).buscar(id),
);

final cadastroDeUsuariosProvider = Provider(CadastroDeUsuarios.new);

class CadastroDeUsuarios {
  const CadastroDeUsuarios(this._ref);

  final Ref _ref;

  UsuarioRepository get _repositorio => _ref.read(usuarioRepositoryProvider);

  Future<void> cadastrar(DadosUsuario dados) => _atualizandoLista(() => _repositorio.cadastrar(dados));

  Future<void> atualizar(Usuario usuario, DadosUsuario dados) =>
      _atualizandoLista(() => _repositorio.atualizar(usuario, dados));

  Future<void> alterarSituacao(Usuario usuario, Situacao nova) =>
      _atualizandoLista(() => _repositorio.alterarSituacao(usuario, nova));

  Future<void> _atualizandoLista(Future<Usuario> Function() operacao) async {
    await operacao();
    _ref.invalidate(paginaUsuariosProvider);
    _ref.read(alteracoesDeCadastroProvider.notifier).registrar();
  }
}
