import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dominio/filtro_cadastro.dart';
import '../../../core/dominio/situacao.dart';
import '../../../core/http/cliente_api.dart';
import '../../../core/http/pagina.dart';
import '../../../core/http/parametros_de_listagem.dart';
import '../domain/usuario.dart';

final usuarioRepositoryProvider = Provider((ref) => UsuarioRepository(ref.watch(clienteApiProvider)));

class UsuarioRepository {
  const UsuarioRepository(this._api);

  static const _recurso = 'usuarios';

  final ClienteApi _api;

  Future<Pagina<Usuario>> listar(FiltroCadastro filtro) async => Pagina.deJson(
    await _api.get(_recurso, parametros: parametrosDeListagem(filtro, ordenacao: 'nome')),
    Usuario.deJson,
  );

  Future<Pagina<Usuario>> listarAtivos() async => Pagina.deJson(
    await _api.get(
      _recurso,
      parametros: {'situacao': Situacao.ativo.valorApi, 'size': tamanhoMaximoDaPagina, 'sort': 'nome'},
    ),
    Usuario.deJson,
  );

  Future<Pagina<Usuario>> listarTodos() async => Pagina.deJson(
    await _api.get(_recurso, parametros: {'size': tamanhoMaximoDaPagina, 'sort': 'nome'}),
    Usuario.deJson,
  );

  Future<Usuario> buscar(int id) async => Usuario.deJson(await _api.get('$_recurso/$id'));

  Future<Usuario> cadastrar(DadosUsuario dados) async =>
      Usuario.deJson(await _api.post(_recurso, corpo: dados.paraJson()));

  Future<Usuario> atualizar(Usuario usuario, DadosUsuario dados) async =>
      Usuario.deJson(await _api.put('$_recurso/${usuario.id}', dados.paraJson(versao: usuario.versao)));

  Future<Usuario> alterarSituacao(Usuario usuario, Situacao situacao) async =>
      Usuario.deJson(await _api.patch('$_recurso/${usuario.id}/${situacao.acaoApi}'));
}
