import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/formatacao/datas.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/prazo.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/status_obrigacao.dart';

import '../../apoio.dart';

void main() {
  final hoje = Datas.hoje();

  Prazo prazo(int dias, {StatusObrigacao status = StatusObrigacao.pendente}) =>
      Prazo.de(obrigacaoDeExemplo(diasParaVencer: dias, status: status), hoje);

  test('classifica o prazo pela distância até o vencimento', () {
    expect((prazo(-3).urgencia, prazo(-3).descricao), (UrgenciaDoPrazo.atrasada, 'Venceu há 3 dias'));
    expect((prazo(-1).urgencia, prazo(-1).descricao), (UrgenciaDoPrazo.atrasada, 'Venceu há 1 dia'));
    expect((prazo(0).urgencia, prazo(0).descricao), (UrgenciaDoPrazo.venceHoje, 'Vence hoje'));
    expect((prazo(7).urgencia, prazo(7).descricao), (UrgenciaDoPrazo.proxima, 'Vence em 7 dias'));
    expect((prazo(8).urgencia, prazo(8).descricao), (UrgenciaDoPrazo.tranquila, 'Vence em 8 dias'));
  });

  test('o atraso informado pela API prevalece sobre a data do aparelho', () {
    final vencidaNoEscritorio = Prazo.de(obrigacaoDeExemplo(diasParaVencer: 0, atrasadaNaApi: true), hoje);
    final aindaNoPrazo = Prazo.de(obrigacaoDeExemplo(diasParaVencer: -1, atrasadaNaApi: false), hoje);

    expect((vencidaNoEscritorio.urgencia, vencidaNoEscritorio.descricao), (UrgenciaDoPrazo.atrasada, 'Vencida'));
    expect(aindaNoPrazo.urgencia, UrgenciaDoPrazo.venceHoje);
  });

  test('obrigação concluída nunca aparece como atrasada', () {
    expect(prazo(-10, status: StatusObrigacao.concluida).urgencia, UrgenciaDoPrazo.concluida);
  });
}
