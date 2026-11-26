import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/dominio/termos_do_cadastro.dart';
import '../../../core/formatacao/cnpj.dart';
import '../../../core/widgets/alteracao_de_situacao.dart';
import '../../../core/widgets/chip_situacao.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../../core/widgets/filtros_de_cadastro.dart';
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
        vazio: const EstadoVazio(
          icone: Icons.business_outlined,
          titulo: 'Nenhuma empresa encontrada',
          mensagem: 'Cadastre uma empresa ou ajuste os filtros.',
        ),
        aoMudarPagina: filtro.irParaPagina,
        aoTentarNovamente: () => ref.invalidate(paginaEmpresasProvider),
        itemBuilder: (context, empresa) => _CartaoEmpresa(empresa),
      ),
    );
  }
}

class _CartaoEmpresa extends ConsumerWidget {
  const _CartaoEmpresa(this.empresa);

  final Empresa empresa;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cadastro = ref.watch(cadastroDeEmpresasProvider);
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.business)),
        title: Text(empresa.razaoSocial),
        subtitle: Text([Cnpj.formatar(empresa.cnpj), ?empresa.nomeFantasia].join(' · ')),
        onTap: () => context.go(RotasEmpresas.edicao(empresa.id)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChipSituacao(situacao: empresa.situacao, termos: _termos),
            MenuDeCadastro(
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
          ],
        ),
      ),
    );
  }
}
