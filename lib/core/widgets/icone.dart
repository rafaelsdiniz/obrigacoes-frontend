import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

enum Icones {
  painel('painel'),
  obrigacoes('obrigacoes'),
  empresas('empresas'),
  usuarios('usuarios'),
  adicionar('adicionar'),
  editar('editar'),
  mais('mais'),
  buscar('buscar'),
  limpar('limpar'),
  voltar('voltar'),
  avancar('avancar'),
  salvar('salvar'),
  anexar('anexar'),
  baixar('baixar'),
  excluir('excluir'),
  recarregar('recarregar'),
  calendario('calendario'),
  filtrar('filtrar'),
  situacaoAtiva('situacao-ativa'),
  situacaoInativa('situacao-inativa'),
  statusPendente('status-pendente'),
  statusEmAndamento('status-em-andamento'),
  statusConcluida('status-concluida'),
  statusAtrasada('status-atrasada'),
  arquivo('arquivo'),
  arquivoPdf('arquivo-pdf'),
  arquivoImagem('arquivo-imagem'),
  arquivoPlanilha('arquivo-planilha'),
  arquivoXml('arquivo-xml'),
  arquivoTexto('arquivo-texto'),
  vazio('vazio'),
  semConexao('sem-conexao'),
  naoEncontrado('nao-encontrado'),
  historico('historico');

  const Icones(this._arquivo);

  final String _arquivo;

  String get caminho => 'assets/icones/$_arquivo.svg';
}

class Icone extends StatelessWidget {
  const Icone(this.icone, {this.tamanho = 20, this.cor, this.rotulo, super.key});

  final Icones icone;
  final double tamanho;
  final Color? cor;
  final String? rotulo;

  @override
  Widget build(BuildContext context) {
    final corFinal = cor ?? IconTheme.of(context).color ?? DefaultTextStyle.of(context).style.color!;
    final imagem = SvgPicture.asset(
      icone.caminho,
      width: tamanho,
      height: tamanho,
      colorFilter: ColorFilter.mode(corFinal, BlendMode.srcIn),
      semanticsLabel: rotulo,
      excludeFromSemantics: rotulo == null,
    );
    return SizedBox.square(dimension: tamanho, child: imagem);
  }
}
