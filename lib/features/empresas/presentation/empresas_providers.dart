import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dominio/filtro_cadastro.dart';
import '../../../core/dominio/situacao.dart';
import '../../../core/estado/filtro_cadastro_notifier.dart';
import '../../../core/http/pagina.dart';
import '../data/empresa_repository.dart';
import '../domain/empresa.dart';

final filtroEmpresasProvider = NotifierProvider<FiltroCadastroNotifier, FiltroCadastro>(FiltroCadastroNotifier.new);

final paginaEmpresasProvider = FutureProvider.autoDispose<Pagina<Empresa>>(
  (ref) => ref.watch(empresaRepositoryProvider).listar(ref.watch(filtroEmpresasProvider)),
);

final empresaProvider = FutureProvider.autoDispose.family<Empresa, int>(
  (ref, id) => ref.watch(empresaRepositoryProvider).buscar(id),
);

final cadastroDeEmpresasProvider = Provider(CadastroDeEmpresas.new);

class CadastroDeEmpresas {
  const CadastroDeEmpresas(this._ref);

  final Ref _ref;

  EmpresaRepository get _repositorio => _ref.read(empresaRepositoryProvider);

  Future<void> cadastrar(DadosEmpresa dados) => _atualizandoLista(() => _repositorio.cadastrar(dados));

  Future<void> atualizar(Empresa empresa, DadosEmpresa dados) =>
      _atualizandoLista(() => _repositorio.atualizar(empresa, dados));

  Future<void> alterarSituacao(Empresa empresa, Situacao nova) =>
      _atualizandoLista(() => _repositorio.alterarSituacao(empresa, nova));

  Future<void> _atualizandoLista(Future<Empresa> Function() operacao) async {
    await operacao();
    _ref.invalidate(paginaEmpresasProvider);
  }
}
