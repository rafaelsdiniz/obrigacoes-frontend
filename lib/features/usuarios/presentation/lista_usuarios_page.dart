import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/alteracao_de_situacao.dart';
import '../../../core/widgets/cabecalho_de_colunas.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../core/widgets/filtros_de_cadastro.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/indicador_de_situacao.dart';
import '../../../core/widgets/linha_de_cadastro.dart';
import '../../../core/widgets/lista_paginada.dart';
import '../../../core/widgets/menu_de_cadastro.dart';
import '../../../core/widgets/pagina_de_listagem.dart';
import '../domain/usuario.dart';
import 'rotas_usuarios.dart';
import 'usuarios_providers.dart';

class ListaUsuariosPage extends ConsumerWidget {
  const ListaUsuariosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.read(filtroUsuariosProvider.notifier);
    return PaginaDeListagem(
      titulo: 'Usuários',
      subtitulo: 'Colaboradores responsáveis pelas obrigações',
      rotuloNovo: 'Novo usuário',
      aoCriarNovo: () => context.go(RotasUsuarios.novo),
      filtros: FiltrosDeCadastro(
        dica: 'Buscar por nome ou e-mail',
        termos: termosDoUsuario,
        filtro: ref.watch(filtroUsuariosProvider),
        aoBuscar: filtro.buscar,
        aoFiltrarPorSituacao: filtro.filtrarPorSituacao,
      ),
      conteudo: ListaPaginada<Usuario>(
        estado: ref.watch(paginaUsuariosProvider),
        cabecalho: const CabecalhoDeColunas(titulo: 'Nome', detalhes: ['E-mail', 'Cargo'], situacao: 'Situação'),
        vazio: const EstadoVazio(
          icone: Icones.usuarios,
          titulo: 'Nenhum usuário encontrado',
          mensagem: 'Cadastre um usuário ou ajuste os filtros.',
        ),
        aoMudarPagina: filtro.irParaPagina,
        aoTentarNovamente: () => ref.invalidate(paginaUsuariosProvider),
        itemBuilder: (context, usuario) => _LinhaUsuario(usuario),
      ),
    );
  }
}

class _LinhaUsuario extends ConsumerWidget {
  const _LinhaUsuario(this.usuario);

  final Usuario usuario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cadastro = ref.watch(cadastroDeUsuariosProvider);
    return LinhaDeCadastro(
      titulo: usuario.nome,
      detalhes: [usuario.email, usuario.cargo ?? ''],
      situacao: IndicadorDeSituacao(situacao: usuario.situacao, termos: termosDoUsuario),
      aoTocar: () => context.go(RotasUsuarios.edicao(usuario.id)),
      menu: MenuDeCadastro(
        nome: usuario.nome,
        situacao: usuario.situacao,
        aoEditar: () => context.go(RotasUsuarios.edicao(usuario.id)),
        aoAlterarSituacao: () => alterarSituacao(
          context,
          nome: usuario.nome,
          atual: usuario.situacao,
          termos: termosDoUsuario,
          consequenciaDaInativacao:
              'O usuário continuará disponível para consulta, mas não poderá ser responsável por novas obrigações.',
          alterar: (nova) => cadastro.alterarSituacao(usuario, nova),
        ),
      ),
    );
  }
}
