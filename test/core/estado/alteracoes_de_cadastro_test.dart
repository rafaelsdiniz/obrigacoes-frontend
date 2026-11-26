import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/features/empresas/data/empresa_repository.dart';
import 'package:obrigacoes_app/features/empresas/presentation/empresas_providers.dart';
import 'package:obrigacoes_app/features/obrigacoes/data/obrigacao_repository.dart';
import 'package:obrigacoes_app/features/obrigacoes/presentation/obrigacoes_providers.dart';
import 'package:obrigacoes_app/features/usuarios/data/usuario_repository.dart';
import 'package:obrigacoes_app/features/usuarios/presentation/usuarios_providers.dart';

import '../../apoio.dart';

void main() {
  setUpAll(registrarValoresPadrao);

  late RepositoriosFalsos falsos;
  late ProviderContainer container;

  setUp(() {
    falsos = repositoriosComDados();
    container = ProviderContainer(
      overrides: [
        empresaRepositoryProvider.overrideWithValue(falsos.empresas),
        usuarioRepositoryProvider.overrideWithValue(falsos.usuarios),
        obrigacaoRepositoryProvider.overrideWithValue(falsos.obrigacoes),
      ],
      retry: (tentativas, erro) => null,
    );
    addTearDown(container.dispose);
  });

  test('inativar uma empresa recarrega as empresas ativas, as obrigações e os próximos vencimentos', () async {
    container
      ..listen(empresasAtivasProvider, (_, _) {})
      ..listen(paginaObrigacoesProvider, (_, _) {})
      ..listen(proximosVencimentosProvider, (_, _) {});
    await container.read(empresasAtivasProvider.future);
    await container.read(paginaObrigacoesProvider.future);
    await container.read(proximosVencimentosProvider.future);
    when(() => falsos.empresas.alterarSituacao(any(), any()))
        .thenAnswer((_) async => empresaDeExemplo(situacao: Situacao.inativo));

    await container.read(cadastroDeEmpresasProvider).alterarSituacao(empresaDeExemplo(), Situacao.inativo);
    await container.read(empresasAtivasProvider.future);
    await container.read(paginaObrigacoesProvider.future);
    await container.read(proximosVencimentosProvider.future);

    verify(() => falsos.empresas.listarAtivas()).called(2);
    verify(() => falsos.obrigacoes.listar(any())).called(2);
    verify(() => falsos.obrigacoes.proximosVencimentos()).called(2);
  });

  test('editar um usuário recarrega os usuários ativos e o detalhe da obrigação aberta', () async {
    container
      ..listen(usuariosAtivosProvider, (_, _) {})
      ..listen(obrigacaoProvider(10), (_, _) {});
    await container.read(usuariosAtivosProvider.future);
    await container.read(obrigacaoProvider(10).future);
    when(() => falsos.usuarios.alterarSituacao(any(), any()))
        .thenAnswer((_) async => usuarioDeExemplo(situacao: Situacao.inativo));

    await container.read(cadastroDeUsuariosProvider).alterarSituacao(usuarioDeExemplo(), Situacao.inativo);
    await container.read(usuariosAtivosProvider.future);
    await container.read(obrigacaoProvider(10).future);

    verify(() => falsos.usuarios.listarAtivos()).called(2);
    verify(() => falsos.obrigacoes.buscar(10)).called(2);
  });
}
