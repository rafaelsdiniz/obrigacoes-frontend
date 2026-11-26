import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/dominio/termos_do_cadastro.dart';
import '../../../core/widgets/alteracao_de_situacao.dart';
import '../../../core/widgets/chip_situacao.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../core/widgets/filtros_de_cadastro.dart';
import '../../../core/widgets/lista_paginada.dart';
import '../../../core/widgets/menu_de_cadastro.dart';
import '../../../core/widgets/pagina_de_listagem.dart';
import '../domain/usuario.dart';
import 'rotas_usuarios.dart';
import 'usuarios_providers.dart';

const _termos = TermosDoCadastro(substantivo: 'Usuário', genero: Genero.masculino);

class ListaUsuariosPage extends ConsumerWidget {
  const ListaUsuariosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.read(filtroUsuariosProvider.notifier);
    return PaginaDeListagem(
      titulo: 'Usuários',
      rotuloNovo: 'Novo usuário',
      aoCriarNovo: () => context.go(RotasUsuarios.novo),
      filtros: FiltrosDeCadastro(
        dica: 'Buscar por nome ou e-mail',
        termos: _termos,
        filtro: ref.watch(filtroUsuariosProvider),
        aoBuscar: filtro.buscar,
        aoFiltrarPorSituacao: filtro.filtrarPorSituacao,
      ),
      conteudo: ListaPaginada<Usuario>(
        estado: ref.watch(paginaUsuariosProvider),
        vazio: const EstadoVazio(
          icone: Icons.people_outline,
          titulo: 'Nenhum usuário encontrado',
          mensagem: 'Cadastre um usuário ou ajuste os filtros.',
        ),
        aoMudarPagina: filtro.irParaPagina,
        aoTentarNovamente: () => ref.invalidate(paginaUsuariosProvider),
        itemBuilder: (context, usuario) => _CartaoUsuario(usuario),
      ),
    );
  }
}

class _CartaoUsuario extends ConsumerWidget {
  const _CartaoUsuario(this.usuario);

  final Usuario usuario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cadastro = ref.watch(cadastroDeUsuariosProvider);
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(usuario.nome.characters.first.toUpperCase())),
        title: Text(usuario.nome),
        subtitle: Text([usuario.email, ?usuario.cargo].join(' · ')),
        onTap: () => context.go(RotasUsuarios.edicao(usuario.id)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChipSituacao(situacao: usuario.situacao, termos: _termos),
            MenuDeCadastro(
              nome: usuario.nome,
              situacao: usuario.situacao,
              aoEditar: () => context.go(RotasUsuarios.edicao(usuario.id)),
              aoAlterarSituacao: () => alterarSituacao(
                context,
                nome: usuario.nome,
                atual: usuario.situacao,
                termos: _termos,
                consequenciaDaInativacao: 'O usuário continuará disponível para consulta, mas não poderá ser responsável por novas obrigações.',
                alterar: (nova) => cadastro.alterarSituacao(usuario, nova),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
