import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dominio/filtro_cadastro.dart';
import '../../empresas/data/empresa_repository.dart';
import '../../obrigacoes/data/obrigacao_repository.dart';
import '../../obrigacoes/domain/filtro_obrigacoes.dart';
import '../../usuarios/data/usuario_repository.dart';
import '../domain/resultado_da_busca.dart';

const tamanhoMinimoDaBusca = 2;

final resultadoDaBuscaProvider = FutureProvider.autoDispose.family<ResultadoDaBusca, String>((ref, termo) async {
  final (obrigacoes, empresas, usuarios) = await (
    ref.watch(obrigacaoRepositoryProvider).listar(FiltroObrigacoes(busca: termo)),
    ref.watch(empresaRepositoryProvider).listar(FiltroCadastro(busca: termo)),
    ref.watch(usuarioRepositoryProvider).listar(FiltroCadastro(busca: termo)),
  ).wait;
  return ResultadoDaBusca(
    obrigacoes: obrigacoes.itens.take(ResultadoDaBusca.limitePorGrupo).toList(),
    empresas: empresas.itens.take(ResultadoDaBusca.limitePorGrupo).toList(),
    usuarios: usuarios.itens.take(ResultadoDaBusca.limitePorGrupo).toList(),
  );
});
