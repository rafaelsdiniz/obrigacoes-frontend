import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/dominio/termos_do_cadastro.dart';
import '../../../core/formatacao/cnpj.dart';
import '../../../core/widgets/alteracao_de_situacao.dart';
import '../../../core/widgets/cabecalho_de_colunas.dart';
import '../../../core/widgets/chip_situacao.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../core/widgets/filtros_de_cadastro.dart';
import '../../../core/widgets/icone_em_quadro.dart';
import '../../../core/widgets/linha_de_cadastro.dart';
import '../../../core/widgets/lista_paginada.dart';
import '../../../core/widgets/menu_de_cadastro.dart';
import '../../../core/widgets/pagina_de_listagem.dart';
import '../domain/empresa.dart';
import 'empresas_providers.dart';
import 'rotas_empresas.dart';

const _termos = TermosDoCadastro(substantivo: 'Empresa', genero: Genero.feminino);

class ListaEmpresasPage extends ConsumerWidget {
  const ListaEmpresasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.read(filtroEmpresasProvider.notifier);
    return PaginaDeListagem(
      titulo: 'Empresas',
      subtitulo: 'Empresas clientes do escritório',
      rotuloNovo: 'Nova empresa',
      aoCriarNovo: () => context.go(RotasEmpresas.nova),
      filtros: FiltrosDeCadastro(
        dica: 'Buscar por razão social, nome fantasia ou CNPJ',
        termos: _termos,
        filtro: ref.watch(filtroEmpresasProvider),
        aoBuscar: filtro.buscar,
        aoFiltrarPorSituacao: filtro.filtrarPorSituacao,
      ),
      conteudo: ListaPaginada<Empresa>(
        estado: ref.watch(paginaEmpresasProvider),
        cabecalho: const CabecalhoDeColunas(
          titulo: 'Empresa',
          detalhes: ['CNPJ', 'Nome fantasia', 'E-mail'],
          selo: 'Situação',
        ),
        vazio: const EstadoVazio(
          icone: Icons.apartment_rounded,
          titulo: 'Nenhuma empresa encontrada',
          mensagem: 'Cadastre uma empresa ou ajuste os filtros.',
        ),
        aoMudarPagina: filtro.irParaPagina,
        aoTentarNovamente: () => ref.invalidate(paginaEmpresasProvider),
        itemBuilder: (context, empresa) => _LinhaEmpresa(empresa),
      ),
    );
  }
}

class _LinhaEmpresa extends ConsumerWidget {
  const _LinhaEmpresa(this.empresa);

  final Empresa empresa;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cadastro = ref.watch(cadastroDeEmpresasProvider);
    return LinhaDeCadastro(
      avatar: const IconeEmQuadro(Icons.apartment_rounded),
      titulo: empresa.razaoSocial,
      detalhes: [Cnpj.formatar(empresa.cnpj), empresa.nomeFantasia ?? '', empresa.email ?? ''],
      selo: ChipSituacao(situacao: empresa.situacao, termos: _termos),
      aoTocar: () => context.go(RotasEmpresas.edicao(empresa.id)),
      menu: MenuDeCadastro(
        nome: empresa.razaoSocial,
        situacao: empresa.situacao,
        aoEditar: () => context.go(RotasEmpresas.edicao(empresa.id)),
        aoAlterarSituacao: () => alterarSituacao(
          context,
          nome: empresa.razaoSocial,
          atual: empresa.situacao,
          termos: _termos,
          consequenciaDaInativacao:
              'A empresa continuará disponível para consulta, mas não poderá receber novas obrigações.',
          alterar: (nova) => cadastro.alterarSituacao(empresa, nova),
        ),
      ),
    );
  }
}
