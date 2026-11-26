import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/formatacao/validacoes.dart';
import '../../../core/widgets/avisos.dart';
import '../../../core/widgets/envio_de_formulario.dart';
import '../../../core/widgets/estrutura_formulario.dart';
import '../../../core/widgets/formulario_com_carregamento.dart';
import '../domain/usuario.dart';
import 'rotas_usuarios.dart';
import 'usuarios_providers.dart';

class FormularioUsuarioPage extends ConsumerWidget {
  const FormularioUsuarioPage({this.id, super.key});

  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = this.id;
    if (id == null) {
      return const _FormularioUsuario();
    }
    return FormularioComCarregamento<Usuario>(
      titulo: 'Editar usuário',
      registro: ref.watch(usuarioProvider(id)),
      aoTentarNovamente: () => ref.invalidate(usuarioProvider(id)),
      aoVoltar: () => context.go(RotasUsuarios.lista),
      builder: (usuario) => _FormularioUsuario(key: ValueKey(usuario.versao), usuario: usuario),
    );
  }
}

class _FormularioUsuario extends ConsumerStatefulWidget {
  const _FormularioUsuario({this.usuario, super.key});

  final Usuario? usuario;

  @override
  ConsumerState<_FormularioUsuario> createState() => _FormularioUsuarioState();
}

class _FormularioUsuarioState extends ConsumerState<_FormularioUsuario> with EnvioDeFormulario {
  late final _nome = TextEditingController(text: widget.usuario?.nome);
  late final _email = TextEditingController(text: widget.usuario?.email);
  late final _cargo = TextEditingController(text: widget.usuario?.cargo);

  @override
  void dispose() {
    for (final controlador in [_nome, _email, _cargo]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() {
    final usuario = widget.usuario;
    final cadastro = ref.read(cadastroDeUsuariosProvider);
    final dados = DadosUsuario(nome: _nome.text.trim(), email: _email.text.trim(), cargo: _cargo.text.trim());
    return enviar(
      () => usuario == null ? cadastro.cadastrar(dados) : cadastro.atualizar(usuario, dados),
      aoConcluir: () {
        avisarSucesso(context, usuario == null ? 'Usuário cadastrado.' : 'Usuário atualizado.');
        context.go(RotasUsuarios.lista);
      },
      aoConflitoDeVersao: usuario == null ? null : () => ref.invalidate(usuarioProvider(usuario.id)),
    );
  }

  @override
  Widget build(BuildContext context) => EstruturaFormulario(
    titulo: widget.usuario == null ? 'Novo usuário' : 'Editar usuário',
    subtitulo: widget.usuario == null ? 'Cadastre um colaborador do escritório' : 'Atualize os dados do colaborador',
    aoVoltar: () => context.go(RotasUsuarios.lista),
    chave: chaveFormulario,
    salvando: salvando,
    aoSalvar: _salvar,
    campos: [
      CampoDoFormulario(
        TextFormField(
          controller: _nome,
          decoration: const InputDecoration(labelText: 'Nome *'),
          validator: validarCampo('nome', Validacoes.obrigatorio('O nome é obrigatório.', maximo: 120)),
          onChanged: (_) => campoAlterado('nome'),
          textInputAction: TextInputAction.next,
        ),
        larguraInteira: true,
      ),
      CampoDoFormulario(
        TextFormField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'E-mail *'),
          keyboardType: TextInputType.emailAddress,
          validator: validarCampo(
            'email',
            Validacoes.todas([Validacoes.obrigatorio('O e-mail é obrigatório.', maximo: 150), Validacoes.email]),
          ),
          onChanged: (_) => campoAlterado('email'),
          textInputAction: TextInputAction.next,
        ),
      ),
      CampoDoFormulario(
        TextFormField(
          controller: _cargo,
          decoration: const InputDecoration(labelText: 'Cargo'),
          validator: validarCampo('cargo', Validacoes.tamanhoMaximo(80)),
          onChanged: (_) => campoAlterado('cargo'),
          onFieldSubmitted: (_) => unawaited(_salvar()),
        ),
      ),
    ],
  );
}
