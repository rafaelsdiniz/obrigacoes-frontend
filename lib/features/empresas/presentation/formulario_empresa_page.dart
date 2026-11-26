import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/formatacao/cnpj.dart';
import '../../../core/formatacao/validacoes.dart';
import '../../../core/widgets/avisos.dart';
import '../../../core/widgets/campo_de_texto.dart';
import '../../../core/widgets/campo_do_formulario.dart';
import '../../../core/widgets/envio_de_formulario.dart';
import '../../../core/widgets/estrutura_formulario.dart';
import '../../../core/widgets/registro_com_carregamento.dart';
import '../../../core/widgets/secao_do_formulario.dart';
import '../domain/empresa.dart';
import 'empresas_providers.dart';
import 'rotas_empresas.dart';

class FormularioEmpresaPage extends ConsumerWidget {
  const FormularioEmpresaPage({this.id, super.key});

  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = this.id;
    if (id == null) {
      return const _FormularioEmpresa();
    }
    return RegistroComCarregamento<Empresa>(
      titulo: 'Editar empresa',
      registro: ref.watch(empresaProvider(id)),
      aoTentarNovamente: () => ref.invalidate(empresaProvider(id)),
      retorno: (rotulo: 'Empresas', aoVoltar: () => context.go(RotasEmpresas.lista)),
      builder: (empresa) => _FormularioEmpresa(key: ValueKey(empresa.versao), empresa: empresa),
    );
  }
}

class _FormularioEmpresa extends ConsumerStatefulWidget {
  const _FormularioEmpresa({this.empresa, super.key});

  final Empresa? empresa;

  @override
  ConsumerState<_FormularioEmpresa> createState() => _FormularioEmpresaState();
}

class _FormularioEmpresaState extends ConsumerState<_FormularioEmpresa> with EnvioDeFormulario {
  late final _razaoSocial = TextEditingController(text: widget.empresa?.razaoSocial);
  late final _nomeFantasia = TextEditingController(text: widget.empresa?.nomeFantasia);
  late final _cnpj = TextEditingController(text: Cnpj.formatar(widget.empresa?.cnpj ?? ''));
  late final _email = TextEditingController(text: widget.empresa?.email);
  late final _telefone = TextEditingController(text: widget.empresa?.telefone);

  @override
  void dispose() {
    for (final controlador in [_razaoSocial, _nomeFantasia, _cnpj, _email, _telefone]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() {
    final empresa = widget.empresa;
    final cadastro = ref.read(cadastroDeEmpresasProvider);
    final dados = DadosEmpresa(
      razaoSocial: _razaoSocial.text.trim(),
      nomeFantasia: _nomeFantasia.text.trim(),
      cnpj: _cnpj.text,
      email: _email.text.trim(),
      telefone: _telefone.text.trim(),
    );
    return enviar(
      () => empresa == null ? cadastro.cadastrar(dados) : cadastro.atualizar(empresa, dados),
      aoConcluir: () {
        avisarSucesso(context, empresa == null ? 'Empresa cadastrada.' : 'Empresa atualizada.');
        context.go(RotasEmpresas.lista);
      },
      aoConflitoDeVersao: empresa == null ? null : () => ref.invalidate(empresaProvider(empresa.id)),
    );
  }

  @override
  Widget build(BuildContext context) => EstruturaFormulario(
    titulo: widget.empresa == null ? 'Nova empresa' : 'Editar empresa',
    subtitulo: widget.empresa == null
        ? 'Cadastre uma empresa cliente do escritório'
        : 'Atualize os dados cadastrais da empresa',
    retorno: (rotulo: 'Empresas', aoVoltar: () => context.go(RotasEmpresas.lista)),
    chave: chaveFormulario,
    salvando: salvando,
    aoSalvar: _salvar,
    secoes: [
      SecaoDoFormulario(
        titulo: 'Identificação',
        descricao: 'Dados que identificam a empresa perante a Receita Federal.',
        campos: [
          CampoDoFormulario(
            CampoDeTexto(
              rotulo: 'Razão social',
              obrigatorio: true,
              controlador: _razaoSocial,
              validador: validarCampo(
                'razaoSocial',
                Validacoes.obrigatorio('A razão social é obrigatória.', maximo: 150),
              ),
              aoAlterar: (_) => campoAlterado('razaoSocial'),
            ),
            larguraInteira: true,
          ),
          CampoDoFormulario(
            CampoDeTexto(
              rotulo: 'CNPJ',
              obrigatorio: true,
              controlador: _cnpj,
              dica: '00.000.000/0000-00',
              ajuda: 'Aceita o formato numérico e o alfanumérico.',
              formatadores: [MascaraCnpj()],
              capitalizacao: TextCapitalization.characters,
              validador: validarCampo('cnpj', Validacoes.cnpj),
              aoAlterar: (_) => campoAlterado('cnpj'),
            ),
          ),
          CampoDoFormulario(
            CampoDeTexto(
              rotulo: 'Nome fantasia',
              controlador: _nomeFantasia,
              validador: validarCampo('nomeFantasia', Validacoes.tamanhoMaximo(150)),
              aoAlterar: (_) => campoAlterado('nomeFantasia'),
            ),
          ),
        ],
      ),
      SecaoDoFormulario(
        titulo: 'Contato',
        descricao: 'Canais usados pelo escritório para falar com a empresa.',
        campos: [
          CampoDoFormulario(
            CampoDeTexto(
              rotulo: 'E-mail',
              controlador: _email,
              dica: 'Ex.: financeiro@empresa.com.br',
              teclado: TextInputType.emailAddress,
              validador: validarCampo('email', Validacoes.todas([Validacoes.tamanhoMaximo(150), Validacoes.email])),
              aoAlterar: (_) => campoAlterado('email'),
            ),
          ),
          CampoDoFormulario(
            CampoDeTexto(
              rotulo: 'Telefone',
              controlador: _telefone,
              dica: 'Ex.: (63) 3333-4444',
              teclado: TextInputType.phone,
              formatadores: [FilteringTextInputFormatter.allow(RegExp(r'[0-9()+\- ]'))],
              validador: validarCampo('telefone', Validacoes.tamanhoMaximo(20)),
              aoAlterar: (_) => campoAlterado('telefone'),
              acaoDoTeclado: TextInputAction.done,
              aoConfirmar: (_) => unawaited(_salvar()),
            ),
          ),
        ],
      ),
    ],
  );
}
