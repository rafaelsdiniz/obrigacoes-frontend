import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/dominio/filtro_cadastro.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/core/estado/filtro_cadastro_notifier.dart';

final _filtro = NotifierProvider<FiltroCadastroNotifier, FiltroCadastro>(FiltroCadastroNotifier.new);

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer.test());

  FiltroCadastroNotifier notifier() => container.read(_filtro.notifier);

  test('volta à primeira página quando a busca ou a situação mudam', () {
    notifier().irParaPagina(3);
    notifier().buscar('alfa');
    expect(container.read(_filtro), const FiltroCadastro(busca: 'alfa'));

    notifier().irParaPagina(2);
    notifier().filtrarPorSituacao(Situacao.ativo);
    expect(container.read(_filtro), const FiltroCadastro(busca: 'alfa', situacao: Situacao.ativo));
  });

  test('ignora busca e situação iguais às atuais, mantendo a página', () {
    notifier().buscar('alfa');
    notifier().irParaPagina(2);

    notifier().buscar(' alfa ');
    notifier().filtrarPorSituacao(null);

    expect(container.read(_filtro).pagina, 2);
  });
}
