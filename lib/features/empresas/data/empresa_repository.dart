import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dominio/filtro_cadastro.dart';
import '../../../core/dominio/situacao.dart';
import '../../../core/http/cliente_api.dart';
import '../../../core/http/pagina.dart';
import '../../../core/http/parametros_de_listagem.dart';
import '../domain/empresa.dart';

final empresaRepositoryProvider = Provider((ref) => EmpresaRepository(ref.watch(clienteApiProvider)));

class EmpresaRepository {
  const EmpresaRepository(this._api);

  static const _recurso = 'empresas';

  final ClienteApi _api;

  Future<Pagina<Empresa>> listar(FiltroCadastro filtro) async => Pagina.deJson(
    await _api.get(_recurso, parametros: parametrosDeListagem(filtro, ordenacao: 'razaoSocial')),
    Empresa.deJson,
  );

  Future<Pagina<Empresa>> listarAtivas() async => Pagina.deJson(
    await _api.get(
      _recurso,
      parametros: {'situacao': Situacao.ativo.valorApi, 'size': tamanhoMaximoDaPagina, 'sort': 'razaoSocial'},
    ),
    Empresa.deJson,
  );

  Future<Empresa> buscar(int id) async => Empresa.deJson(await _api.get('$_recurso/$id'));

  Future<Empresa> cadastrar(DadosEmpresa dados) async =>
      Empresa.deJson(await _api.post(_recurso, corpo: dados.paraJson()));

  Future<Empresa> atualizar(Empresa empresa, DadosEmpresa dados) async =>
      Empresa.deJson(await _api.put('$_recurso/${empresa.id}', dados.paraJson(versao: empresa.versao)));

  Future<Empresa> alterarSituacao(Empresa empresa, Situacao situacao) async =>
      Empresa.deJson(await _api.patch('$_recurso/${empresa.id}/${situacao.acaoApi}'));
}
