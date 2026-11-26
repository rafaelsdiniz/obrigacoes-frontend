import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/formatacao/datas.dart';
import '../../../core/layout/medidas.dart';
import '../../../core/tema/tema.dart';
import '../../../core/widgets/cabecalho_de_colunas.dart';
import '../../../core/widgets/icone.dart';
import '../../../core/widgets/linha_de_cadastro.dart';
import '../domain/obrigacao.dart';
import '../domain/prazo.dart';
import 'indicador_de_status.dart';
import 'rotas_obrigacoes.dart';
import 'texto_do_prazo.dart';

class LinhaDeObrigacao extends StatelessWidget {
  const LinhaDeObrigacao(this.obrigacao, {super.key});

  final Obrigacao obrigacao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final prazo = Prazo.de(obrigacao, Datas.hoje());
    final vencimento = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Datas.formatar(obrigacao.dataVencimento), style: Tema.mono(context)),
        const SizedBox(height: 2),
        TextoDoPrazo(prazo),
      ],
    );
    return LayoutBuilder(
      builder: (context, restricoes) {
        final emColunas = restricoes.maxWidth >= Medidas.larguraParaColunas;
        final atrasada = prazo.urgencia == UrgenciaDoPrazo.atrasada;
        return Material(
          color: atrasada ? context.cores.tomDeAtraso : Colors.transparent,
          child: InkWell(
            onTap: () => context.go(RotasObrigacoes.detalhe(obrigacao.id)),
            hoverColor: atrasada ? context.cores.erroContainer.withValues(alpha: 0.5) : context.cores.realce,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(LinhaDeCadastro.margemHorizontal, 14, 8, 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(obrigacao.titulo, style: tema.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          emColunas
                              ? [obrigacao.tipo.rotulo, ?obrigacao.competencia].join('  ·  ')
                              : '${obrigacao.empresa.razaoSocial}  ·  ${obrigacao.responsavel.nome}',
                          style: tema.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!emColunas) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [IndicadorDeStatus(obrigacao.status), vencimento],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (emColunas) ...[
                    _Coluna(obrigacao.empresa.razaoSocial),
                    _Coluna(obrigacao.responsavel.nome),
                    Expanded(flex: 2, child: vencimento),
                    SizedBox(
                      width: LinhaDeCadastro.larguraDaSituacao,
                      child: Align(alignment: Alignment.centerLeft, child: IndicadorDeStatus(obrigacao.status)),
                    ),
                  ],
                  SizedBox(
                    width: LinhaDeCadastro.larguraDoMenu,
                    child: Icone(Icones.avancar, tamanho: TamanhosDeIcone.padrao, cor: context.cores.textoVariante),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CabecalhoDeObrigacoes extends StatelessWidget {
  const CabecalhoDeObrigacoes({super.key});

  @override
  Widget build(BuildContext context) => const CabecalhoDeColunas(
    titulo: 'Obrigação',
    detalhes: ['Empresa', 'Responsável', 'Vencimento'],
    situacao: 'Status',
  );
}

class _Coluna extends StatelessWidget {
  const _Coluna(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Expanded(
    flex: 2,
    child: Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Text(texto, style: Tema.textoSecundario(context), maxLines: 2, overflow: TextOverflow.ellipsis),
    ),
  );
}
