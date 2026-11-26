import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/filtro_obrigacoes.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/tipo_obrigacao.dart';

void main() {
  group('período de vencimento', () {
    final hoje = DateTime(2026, 1, 30);

    test('próximos 7 dias atravessa a virada do mês', () {
      expect(PeriodoDeVencimento.proximos7Dias.intervalo(hoje), (de: hoje, ate: DateTime(2026, 2, 6)));
    });

    test('este mês vai do primeiro ao último dia do mês atual', () {
      expect(PeriodoDeVencimento.esteMes.intervalo(hoje), (de: DateTime(2026), ate: DateTime(2026, 1, 31)));
    });

    test('mês passado volta para dezembro do ano anterior', () {
      expect(PeriodoDeVencimento.mesPassado.intervalo(hoje), (de: DateTime(2025, 12), ate: DateTime(2025, 12, 31)));
    });
  });

  test('limpar filtros adicionais mantém busca, status e ordenação', () {
    const filtro = FiltroObrigacoes(
      busca: 'dctf',
      tipo: TipoObrigacao.fiscal,
      empresaId: 1,
      periodo: PeriodoDeVencimento.esteMes,
      ordem: OrdemDasObrigacoes.titulo,
    );

    final limpo = filtro.semFiltrosAdicionais();

    expect(limpo.temFiltrosAdicionais, isFalse);
    expect(limpo.busca, 'dctf');
    expect(limpo.ordem, OrdemDasObrigacoes.titulo);
  });

  test('alterar permite remover um filtro opcional e volta para a primeira página', () {
    const filtro = FiltroObrigacoes(empresaId: 4, pagina: 3);

    final alterado = filtro.alterar(empresaId: () => null);

    expect(alterado.empresaId, isNull);
    expect(alterado.pagina, 0);
  });
}
