import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/dominio/situacao.dart';
import '../../../core/formatacao/datas.dart';
import '../../../core/formatacao/validacoes.dart';
import '../../../core/http/pagina.dart';
import '../../../core/widgets/aviso_de_estado.dart';
import '../../../core/widgets/avisos.dart';
import '../../../core/widgets/campo_de_data.dart';
import '../../../core/widgets/campo_de_selecao.dart';
import '../../../core/widgets/campo_de_texto.dart';
import '../../../core/widgets/campo_do_formulario.dart';
import '../../../core/widgets/envio_de_formulario.dart';
import '../../../core/widgets/estrutura_formulario.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/registro_com_carregamento.dart';
import '../../../core/widgets/secao_do_formulario.dart';
import '../domain/obrigacao.dart';
import '../domain/tipo_obrigacao.dart';
import 'obrigacoes_providers.dart';
import 'rotas_obrigacoes.dart';

class FormularioObrigacaoPage extends ConsumerWidget {
  const FormularioObrigacaoPage({this.id, super.key});

  final int? id;

  String get _titulo => id == null ? 'Nova obrigação' : 'Editar obrigação';

  void _recarregar(WidgetRef ref) {
    ref
      ..invalidate(empresasAtivasProvider)
      ..invalidate(usuariosAtivosProvider);
    if (id case final id?) {
      ref.invalidate(obrigacaoProvider(id));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void voltar() => context.go(id == null ? RotasObrigacoes.lista : RotasObrigacoes.detalhe(id!));
    return RegistroComCarregamento<DadosDoFormularioDeObrigacao>(
      titulo: _titulo,
      registro: ref.watch(formularioDeObrigacaoProvider(id)),
      aoTentarNovamente: () => _recarregar(ref),
      aoVoltar: voltar,
      builder: (dados) => dados.obrigacao?.concluida ?? false
          ? MolduraDoRegistro(
              titulo: _titulo,
              aoVoltar: voltar,
              child: AvisoDeEstado(
                icone: Icones.statusConcluida,
                titulo: 'Obrigação concluída',
                mensagem: 'Uma obrigação concluída não pode mais ser editada.',
                acao: FilledButton(onPressed: voltar, child: const Text('Ver obrigação')),
              ),
            )
          : _FormularioObrigacao(key: ValueKey(dados.obrigacao?.versao), dados: dados),
    );
  }
}

class _FormularioObrigacao extends ConsumerStatefulWidget {
  const _FormularioObrigacao({required this.dados, super.key});

  final DadosDoFormularioDeObrigacao dados;

  @override
  ConsumerState<_FormularioObrigacao> createState() => _FormularioObrigacaoState();
}

class _FormularioObrigacaoState extends ConsumerState<_FormularioObrigacao> with EnvioDeFormulario {
  static const _anoMinimo = 2000;
  static const _anoMaximo = 2100;

  Obrigacao? get _obrigacao => widget.dados.obrigacao;

  late final _titulo = TextEditingController(text: _obrigacao?.titulo);
  late final _descricao = TextEditingController(text: _obrigacao?.descricao);
  late final _competencia = TextEditingController(text: _obrigacao?.competencia?.toString());
  late TipoObrigacao? _tipo = _obrigacao?.tipo;
  late DateTime? _vencimento = _obrigacao?.dataVencimento;
  late int? _empresaId = _obrigacao?.empresa.id;
  late int? _responsavelId = _obrigacao?.responsavel.id;

  @override
  void dispose() {
    for (final controlador in [_titulo, _descricao, _competencia]) {
      controlador.dispose();
    }
    super.dispose();
  }

  static String? _avisoDeLimite(Pagina<Object> pagina, String cadastros) => pagina.temProxima
      ? 'Mostrando ${pagina.itens.length} de ${pagina.totalItens} $cadastros, em ordem alfabética.'
      : null;

  List<OpcaoDeSelecao<int>> get _empresas {
    final atual = _obrigacao?.empresa;
    final ativas = widget.dados.empresas.itens;
    return [
      for (final empresa in ativas) (valor: empresa.id, rotulo: empresa.razaoSocial),
      if (atual != null && !ativas.any((empresa) => empresa.id == atual.id))
        (valor: atual.id, rotulo: '${atual.razaoSocial} (${atual.situacao == Situacao.inativo ? 'inativa' : 'atual'})'),
    ];
  }

  List<OpcaoDeSelecao<int>> get _responsaveis {
    final atual = _obrigacao?.responsavel;
    final ativos = widget.dados.usuarios.itens;
    return [
      for (final usuario in ativos) (valor: usuario.id, rotulo: usuario.nome),
      if (atual != null && !ativos.any((usuario) => usuario.id == atual.id))
        (valor: atual.id, rotulo: '${atual.nome} (${atual.situacao == Situacao.inativo ? 'inativo' : 'atual'})'),
    ];
  }

  String? _validarCompetencia(String? texto) {
    final valor = texto?.trim() ?? '';
    if (valor.isEmpty) {
      return null;
    }
    final competencia = Competencia.deTexto(valor);
    if (competencia == null) {
      return 'Informe a competência no formato MM/AAAA.';
    }
    return competencia.ano < _anoMinimo || competencia.ano > _anoMaximo
        ? 'A competência deve estar entre $_anoMinimo e $_anoMaximo.'
        : null;
  }

  String? Function(T?) _obrigatorioDoServidor<T>(String campo, String mensagem) =>
      (valor) => erroDoServidor(campo) ?? (valor == null ? mensagem : null);

  Future<void> _salvar() {
    final obrigacao = _obrigacao;
    final cadastro = ref.read(cadastroDeObrigacoesProvider);
    Obrigacao? salva;
    return enviar(
      () async {
        final dados = DadosObrigacao(
          titulo: _titulo.text.trim(),
          descricao: _descricao.text.trim(),
          tipo: _tipo!,
          competencia: Competencia.deTexto(_competencia.text),
          dataVencimento: _vencimento!,
          empresaId: _empresaId!,
          responsavelId: _responsavelId!,
        );
        salva = obrigacao == null ? await cadastro.cadastrar(dados) : await cadastro.atualizar(obrigacao, dados);
      },
      aoConcluir: () {
        avisarSucesso(context, obrigacao == null ? 'Obrigação cadastrada.' : 'Obrigação atualizada.');
        context.go(RotasObrigacoes.detalhe(salva!.id));
      },
      aoConflitoDeVersao: obrigacao == null ? null : () => ref.invalidate(obrigacaoProvider(obrigacao.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final obrigacao = _obrigacao;
    return EstruturaFormulario(
      titulo: obrigacao == null ? 'Nova obrigação' : 'Editar obrigação',
      subtitulo: obrigacao == null ? 'Registre um prazo de uma empresa cliente' : obrigacao.titulo,
      aoVoltar: () => context.go(obrigacao == null ? RotasObrigacoes.lista : RotasObrigacoes.detalhe(obrigacao.id)),
      chave: chaveFormulario,
      salvando: salvando,
      aoSalvar: _salvar,
      secoes: [
        SecaoDoFormulario(
          titulo: 'Obrigação',
          descricao: 'O que precisa ser entregue e até quando.',
          campos: [
            CampoDoFormulario(
              CampoDeTexto(
                rotulo: 'Título',
                obrigatorio: true,
                controlador: _titulo,
                dica: 'Ex.: Entrega da DCTFWeb',
                validador: validarCampo('titulo', Validacoes.obrigatorio('O título é obrigatório.', maximo: 150)),
                aoAlterar: (_) => campoAlterado('titulo'),
              ),
              larguraInteira: true,
            ),
            CampoDoFormulario(
              CampoDeSelecao<TipoObrigacao>(
                rotulo: 'Tipo',
                obrigatorio: true,
                dica: 'Selecione o tipo',
                valor: _tipo,
                opcoes: [for (final tipo in TipoObrigacao.values) (valor: tipo, rotulo: tipo.rotulo)],
                validador: _obrigatorioDoServidor('tipo', 'O tipo é obrigatório.'),
                aoSelecionar: (tipo) {
                  campoAlterado('tipo');
                  setState(() => _tipo = tipo);
                },
              ),
            ),
            CampoDoFormulario(
              CampoDeTexto(
                rotulo: 'Competência',
                controlador: _competencia,
                dica: 'MM/AAAA',
                ajuda: 'Mês de referência, quando houver.',
                teclado: TextInputType.number,
                formatadores: [MascaraCompetencia()],
                validador: validarCampo('competencia', _validarCompetencia),
                aoAlterar: (_) => campoAlterado('competencia'),
              ),
            ),
            CampoDoFormulario(
              CampoDeData(
                rotulo: 'Vencimento',
                obrigatorio: true,
                valor: _vencimento,
                primeiraData: DateTime(_anoMinimo),
                ultimaData: DateTime(_anoMaximo, 12, 31),
                validador: _obrigatorioDoServidor('dataVencimento', 'A data de vencimento é obrigatória.'),
                aoSelecionar: (data) {
                  campoAlterado('dataVencimento');
                  setState(() => _vencimento = data);
                },
              ),
            ),
          ],
        ),
        SecaoDoFormulario(
          titulo: 'Responsabilidade',
          descricao:
              'Empresa atendida e colaborador que cuida da entrega. Somente cadastros ativos podem ser escolhidos.',
          campos: [
            CampoDoFormulario(
              CampoDeSelecao<int>(
                rotulo: 'Empresa',
                obrigatorio: true,
                dica: 'Selecione a empresa',
                valor: _empresaId,
                opcoes: _empresas,
                ajuda: _avisoDeLimite(widget.dados.empresas, 'empresas ativas'),
                validador: _obrigatorioDoServidor('empresaId', 'A empresa é obrigatória.'),
                aoSelecionar: (id) {
                  campoAlterado('empresaId');
                  setState(() => _empresaId = id);
                },
              ),
            ),
            CampoDoFormulario(
              CampoDeSelecao<int>(
                rotulo: 'Responsável',
                obrigatorio: true,
                dica: 'Selecione o responsável',
                valor: _responsavelId,
                opcoes: _responsaveis,
                ajuda: _avisoDeLimite(widget.dados.usuarios, 'usuários ativos'),
                validador: _obrigatorioDoServidor('responsavelId', 'O responsável é obrigatório.'),
                aoSelecionar: (id) {
                  campoAlterado('responsavelId');
                  setState(() => _responsavelId = id);
                },
              ),
            ),
          ],
        ),
        SecaoDoFormulario(
          titulo: 'Detalhes',
          descricao: 'Informações que ajudam quem vai executar a obrigação.',
          campos: [
            CampoDoFormulario(
              CampoDeTexto(
                rotulo: 'Descrição',
                controlador: _descricao,
                linhas: 4,
                validador: validarCampo('descricao', Validacoes.tamanhoMaximo(2000)),
                aoAlterar: (_) => campoAlterado('descricao'),
              ),
              larguraInteira: true,
            ),
          ],
        ),
      ],
    );
  }
}
