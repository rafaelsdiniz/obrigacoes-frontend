import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/formatacao/validacoes.dart';
import '../../../core/widgets/avisos.dart';
import '../../../core/widgets/campo_de_texto.dart';
import '../../../core/widgets/campo_do_formulario.dart';
import '../../../core/widgets/envio_de_formulario.dart';
import '../../../core/widgets/estrutura_formulario.dart';
import '../../../core/widgets/registro_com_carregamento.dart';
import '../../../core/widgets/secao_do_formulario.dart';
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
    return RegistroComCarregamento<Usuario>(
      titulo: 'Editar usuário',
      registro: ref.watch(usuarioProvider(id)),
      aoTentarNovamente: () => ref.invalidate(usuarioProvider(id)),
      retorno: (rotulo: 'Usuários', aoVoltar: () => context.go(RotasUsuarios.lista)),
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
    retorno: (rotulo: 'Usuários', aoVoltar: () => context.go(RotasUsuarios.lista)),
    chave: chaveFormulario,
    salvando: salvando,
    aoSalvar: _salvar,
    secoes: [
      SecaoDoFormulario(
        titulo: 'Dados pessoais',
        descricao: 'Identificam o colaborador nas obrigações sob sua responsabilidade.',
        campos: [
          CampoDoFormulario(
            CampoDeTexto(
              rotulo: 'Nome',
              obrigatorio: true,
              controlador: _nome,
              capitalizacao: TextCapitalization.words,
              validador: validarCampo('nome', Validacoes.obrigatorio('O nome é obrigatório.', maximo: 120)),
              aoAlterar: (_) => campoAlterado('nome'),
            ),
            larguraInteira: true,
          ),
          CampoDoFormulario(
            CampoDeTexto(
              rotulo: 'E-mail',
              obrigatorio: true,
              controlador: _email,
              dica: 'Ex.: nome@escritorio.com.br',
              teclado: TextInputType.emailAddress,
              validador: validarCampo(
                'email',
                Validacoes.todas([Validacoes.obrigatorio('O e-mail é obrigatório.', maximo: 150), Validacoes.email]),
              ),
              aoAlterar: (_) => campoAlterado('email'),
            ),
          ),
        ],
      ),
      SecaoDoFormulario(
        titulo: 'Atuação',
        descricao: 'Função do colaborador no escritório.',
        campos: [
          CampoDoFormulario(
            CampoDeTexto(
              rotulo: 'Cargo',
              controlador: _cargo,
              dica: 'Ex.: Analista fiscal',
              validador: validarCampo('cargo', Validacoes.tamanhoMaximo(80)),
              aoAlterar: (_) => campoAlterado('cargo'),
              acaoDoTeclado: TextInputAction.done,
              aoConfirmar: (_) => unawaited(_salvar()),
            ),
          ),
        ],
      ),
    ],
  );
}
