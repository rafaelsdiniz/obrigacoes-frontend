import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/formatacao/cnpj.dart';
import '../../../core/formatacao/validacoes.dart';
import '../../../core/widgets/avisos.dart';
import '../../../core/widgets/envio_de_formulario.dart';
import '../../../core/widgets/estrutura_formulario.dart';
import '../../../core/widgets/formulario_com_carregamento.dart';
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
    return FormularioComCarregamento<Empresa>(
      titulo: 'Editar empresa',
      registro: ref.watch(empresaProvider(id)),
      aoTentarNovamente: () => ref.invalidate(empresaProvider(id)),
      aoVoltar: () => context.go(RotasEmpresas.lista),
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
    aoVoltar: () => context.go(RotasEmpresas.lista),
    chave: chaveFormulario,
    salvando: salvando,
    aoSalvar: _salvar,
    campos: [
      CampoDoFormulario(
        TextFormField(
          controller: _razaoSocial,
          decoration: const InputDecoration(labelText: 'Razão social *'),
          validator: validarCampo('razaoSocial', Validacoes.obrigatorio('A razão social é obrigatória.', maximo: 150)),
          onChanged: (_) => campoAlterado('razaoSocial'),
          textInputAction: TextInputAction.next,
        ),
        larguraInteira: true,
      ),
      CampoDoFormulario(
        TextFormField(
          controller: _nomeFantasia,
          decoration: const InputDecoration(labelText: 'Nome fantasia'),
          validator: validarCampo('nomeFantasia', Validacoes.tamanhoMaximo(150)),
          onChanged: (_) => campoAlterado('nomeFantasia'),
          textInputAction: TextInputAction.next,
        ),
      ),
      CampoDoFormulario(
        TextFormField(
          controller: _cnpj,
          decoration: const InputDecoration(labelText: 'CNPJ *', hintText: 'Numérico ou alfanumérico'),
          inputFormatters: [MascaraCnpj()],
          textCapitalization: TextCapitalization.characters,
          validator: validarCampo('cnpj', Validacoes.cnpj),
          onChanged: (_) => campoAlterado('cnpj'),
          textInputAction: TextInputAction.next,
        ),
      ),
      CampoDoFormulario(
        TextFormField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'E-mail'),
          keyboardType: TextInputType.emailAddress,
          validator: validarCampo('email', Validacoes.todas([Validacoes.tamanhoMaximo(150), Validacoes.email])),
          onChanged: (_) => campoAlterado('email'),
          textInputAction: TextInputAction.next,
        ),
      ),
      CampoDoFormulario(
        TextFormField(
          controller: _telefone,
          decoration: const InputDecoration(labelText: 'Telefone'),
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9()+\- ]'))],
          validator: validarCampo('telefone', Validacoes.tamanhoMaximo(20)),
          onChanged: (_) => campoAlterado('telefone'),
          onFieldSubmitted: (_) => unawaited(_salvar()),
        ),
      ),
    ],
  );
}
