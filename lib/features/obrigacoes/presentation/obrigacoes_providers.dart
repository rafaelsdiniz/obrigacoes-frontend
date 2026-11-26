import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/estado/alteracoes_de_cadastro.dart';
import '../../../core/http/pagina.dart';
import '../../empresas/data/empresa_repository.dart';
import '../../empresas/domain/empresa.dart';
import '../../usuarios/data/usuario_repository.dart';
import '../../usuarios/domain/usuario.dart';
import '../data/obrigacao_repository.dart';
import '../domain/filtro_obrigacoes.dart';
import '../domain/historico_de_status.dart';
import '../domain/obrigacao.dart';
import '../domain/resumo_obrigacoes.dart';
import '../domain/status_obrigacao.dart';

final filtroObrigacoesProvider = NotifierProvider<FiltroObrigacoesNotifier, FiltroObrigacoes>(
  FiltroObrigacoesNotifier.new,
);

final paginaObrigacoesProvider = FutureProvider.autoDispose<Pagina<Obrigacao>>((ref) {
  ref.watch(alteracoesDeCadastroProvider);
  return ref.watch(obrigacaoRepositoryProvider).listar(ref.watch(filtroObrigacoesProvider));
});

final obrigacaoProvider = FutureProvider.autoDispose.family<Obrigacao, int>((ref, id) {
  ref.watch(alteracoesDeCadastroProvider);
  return ref.watch(obrigacaoRepositoryProvider).buscar(id);
});

final historicoDaObrigacaoProvider = FutureProvider.autoDispose.family<List<TransicaoDeStatus>, int>(
  (ref, id) => ref.watch(obrigacaoRepositoryProvider).historico(id),
);

final resumoDasObrigacoesProvider = FutureProvider.autoDispose<ResumoObrigacoes>(
  (ref) => ref.watch(obrigacaoRepositoryProvider).resumir(),
);

final proximosVencimentosProvider = FutureProvider.autoDispose<Pagina<Obrigacao>>((ref) {
  ref.watch(alteracoesDeCadastroProvider);
  return ref.watch(obrigacaoRepositoryProvider).proximosVencimentos();
});

final empresasAtivasProvider = FutureProvider.autoDispose<Pagina<Empresa>>((ref) {
  ref.watch(alteracoesDeCadastroProvider);
  return ref.watch(empresaRepositoryProvider).listarAtivas();
});

final usuariosAtivosProvider = FutureProvider.autoDispose<Pagina<Usuario>>((ref) {
  ref.watch(alteracoesDeCadastroProvider);
  return ref.watch(usuarioRepositoryProvider).listarAtivos();
});

typedef DadosDoFormularioDeObrigacao = ({Obrigacao? obrigacao, Pagina<Empresa> empresas, Pagina<Usuario> usuarios});

final formularioDeObrigacaoProvider = FutureProvider.autoDispose.family<DadosDoFormularioDeObrigacao, int?>((
  ref,
  id,
) async {
  final empresas = ref.watch(empresasAtivasProvider.future);
  final usuarios = ref.watch(usuariosAtivosProvider.future);
  final obrigacao = id == null ? null : ref.watch(obrigacaoProvider(id).future);
  await Future.wait<Object>([empresas, usuarios, ?obrigacao]);
  return (obrigacao: await obrigacao, empresas: await empresas, usuarios: await usuarios);
});

final cadastroDeObrigacoesProvider = Provider(CadastroDeObrigacoes.new);

class FiltroObrigacoesNotifier extends Notifier<FiltroObrigacoes> {
  @override
  FiltroObrigacoes build() => const FiltroObrigacoes();

  void buscar(String texto) {
    if (texto.trim() != state.busca.trim()) {
      state = state.alterar(busca: texto);
    }
  }

  void filtrarPorStatus(StatusObrigacao? status) =>
      state = state.alterar(status: {?status}, somenteAtrasadas: status == StatusObrigacao.concluida ? false : null);

  void mostrarSomenteAtrasadas({required bool ativo}) => state = state.alterar(
    somenteAtrasadas: ativo,
    status: ativo && state.status.contains(StatusObrigacao.concluida) ? const {} : null,
  );

  void exibir({StatusObrigacao? status, bool somenteAtrasadas = false}) =>
      state = FiltroObrigacoes(status: {?status}, somenteAtrasadas: somenteAtrasadas);

  void irParaPagina(int pagina) => state = state.alterar(pagina: pagina);
}

class CadastroDeObrigacoes {
  const CadastroDeObrigacoes(this._ref);

  final Ref _ref;

  ObrigacaoRepository get _repositorio => _ref.read(obrigacaoRepositoryProvider);

  Future<Obrigacao> cadastrar(DadosObrigacao dados) => _atualizandoTelas(() => _repositorio.cadastrar(dados));

  Future<Obrigacao> atualizar(Obrigacao obrigacao, DadosObrigacao dados) =>
      _atualizandoTelas(() => _repositorio.atualizar(obrigacao, dados));

  Future<Obrigacao> avancarStatus(Obrigacao obrigacao, StatusObrigacao novoStatus) =>
      _atualizandoTelas(() => _repositorio.avancarStatus(obrigacao, novoStatus));

  Future<Obrigacao> _atualizandoTelas(Future<Obrigacao> Function() operacao) async {
    final obrigacao = await operacao();
    _ref
      ..invalidate(paginaObrigacoesProvider)
      ..invalidate(resumoDasObrigacoesProvider)
      ..invalidate(proximosVencimentosProvider)
      ..invalidate(obrigacaoProvider(obrigacao.id))
      ..invalidate(historicoDaObrigacaoProvider(obrigacao.id));
    return obrigacao;
  }
}
