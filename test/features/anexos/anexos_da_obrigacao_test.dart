import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:obrigacoes_app/app/roteador.dart';
import 'package:obrigacoes_app/core/arquivos/arquivos_do_dispositivo.dart';
import 'package:obrigacoes_app/core/http/erro_api.dart';
import 'package:obrigacoes_app/core/widgets/icone.dart';
import 'package:obrigacoes_app/features/anexos/domain/tipo_de_anexo.dart';

import '../../apoio.dart';

void main() {
  setUpAll(() {
    registrarValoresPadrao();
    registerFallbackValue(Uri());
    registerFallbackValue(Uint8List(0));
  });

  Future<RepositoriosFalsos> abrirDetalhe(WidgetTester tester, {int id = 10, RepositoriosFalsos? repositorios}) async {
    final falsos = repositorios ?? repositoriosComDados();
    final container = await abrirApp(tester, tamanho: const Size(1280, 1100), repositorios: falsos);
    container.read(roteadorProvider).go('/obrigacoes/$id');
    await tester.pumpAndSettle();
    return falsos;
  }

  void escolherArquivo(RepositoriosFalsos falsos, {String nome = 'guia.pdf', int tamanho = 3}) =>
      when(() => falsos.arquivos.escolher(extensoes: any(named: 'extensoes')))
          .thenAnswer((_) async => (nome: nome, tamanho: tamanho, ler: () async => Uint8List.fromList([1, 2, 3])));

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  testWidgets('lista os anexos com tipo, tamanho e data de envio', (tester) async {
    await abrirDetalhe(tester);

    expect(find.text('recibo-dctfweb.pdf'), findsOneWidget);
    expect(find.textContaining('PDF  ·  180 KB  ·  20/11/2026'), findsOneWidget);
  });

  testWidgets('envia o arquivo escolhido somente com as extensões aceitas pela API', (tester) async {
    final falsos = repositoriosComDados();
    escolherArquivo(falsos);
    when(
      () => falsos.anexos.enviar(
        any(),
        nome: any(named: 'nome'),
        bytes: any(named: 'bytes'),
      ),
    ).thenAnswer((_) async => anexoDeExemplo(id: 2, nome: 'guia.pdf'));
    await abrirDetalhe(tester, repositorios: falsos);

    when(() => falsos.anexos.listar(10))
        .thenAnswer((_) async => [anexoDeExemplo(id: 2, nome: 'guia.pdf'), anexoDeExemplo()]);
    await tocar(tester, find.text('Anexar arquivo'));

    final extensoes = verify(() => falsos.arquivos.escolher(extensoes: captureAny(named: 'extensoes'))).captured.single;
    expect(extensoes, TipoDeAnexo.extensoesPermitidas);
    verify(() => falsos.anexos.enviar(10, nome: 'guia.pdf', bytes: Uint8List.fromList([1, 2, 3]))).called(1);
    expect(find.text('Arquivo anexado.'), findsOneWidget);
    expect(find.text('guia.pdf'), findsOneWidget);
  });

  testWidgets('não envia arquivo acima do tamanho máximo', (tester) async {
    final falsos = repositoriosComDados();
    escolherArquivo(falsos, tamanho: 11 * 1024 * 1024);
    await abrirDetalhe(tester, repositorios: falsos);

    await tocar(tester, find.text('Anexar arquivo'));

    expect(find.text('O arquivo deve ter no máximo 10 MB.'), findsOneWidget);
    verifyNever(
      () => falsos.anexos.enviar(
        any(),
        nome: any(named: 'nome'),
        bytes: any(named: 'bytes'),
      ),
    );
  });

  testWidgets('mostra o motivo quando a API recusa o arquivo', (tester) async {
    final falsos = repositoriosComDados();
    escolherArquivo(falsos, nome: 'falso.pdf');
    when(
      () => falsos.anexos.enviar(
        any(),
        nome: any(named: 'nome'),
        bytes: any(named: 'bytes'),
      ),
    ).thenThrow(
      const ErroApi(codigo: CodigoErro.arquivoInvalido, mensagem: 'O conteúdo do arquivo não corresponde a um PDF.'),
    );
    await abrirDetalhe(tester, repositorios: falsos);

    await tocar(tester, find.text('Anexar arquivo'));

    expect(find.text('O conteúdo do arquivo não corresponde a um PDF.'), findsOneWidget);
    expect(find.text('Anexar arquivo'), findsOneWidget);
  });

  testWidgets('não faz nada quando a escolha do arquivo é cancelada', (tester) async {
    final falsos = repositoriosComDados();
    when(() => falsos.arquivos.escolher(extensoes: any(named: 'extensoes'))).thenAnswer((_) async => null);
    await abrirDetalhe(tester, repositorios: falsos);

    await tocar(tester, find.text('Anexar arquivo'));

    verifyNever(
      () => falsos.anexos.enviar(
        any(),
        nome: any(named: 'nome'),
        bytes: any(named: 'bytes'),
      ),
    );
  });

  testWidgets('baixa o arquivo pelo endereço do anexo', (tester) async {
    final falsos = repositoriosComDados();
    when(() => falsos.arquivos.baixar(any())).thenAnswer((_) async => true);
    await abrirDetalhe(tester, repositorios: falsos);

    await tocar(tester, find.byTooltip('Baixar recibo-dctfweb.pdf'));

    verify(() => falsos.arquivos.baixar(Uri.parse('http://localhost:8080/api/v1/obrigacoes/10/anexos/1'))).called(1);
  });

  testWidgets('avisa quando o download não pode ser iniciado', (tester) async {
    final falsos = repositoriosComDados();
    when(() => falsos.arquivos.baixar(any())).thenAnswer((_) async => false);
    await abrirDetalhe(tester, repositorios: falsos);

    await tocar(tester, find.byTooltip('Baixar recibo-dctfweb.pdf'));

    expect(find.text('Não foi possível baixar o arquivo.'), findsOneWidget);
  });

  testWidgets('exclui o anexo depois da confirmação', (tester) async {
    final falsos = repositoriosComDados();
    when(() => falsos.anexos.excluir(any(), any())).thenAnswer((_) async {});
    await abrirDetalhe(tester, repositorios: falsos);

    await tocar(tester, find.byTooltip('Excluir recibo-dctfweb.pdf'));
    expect(find.text('"recibo-dctfweb.pdf" será removido desta obrigação.'), findsOneWidget);
    when(() => falsos.anexos.listar(10)).thenAnswer((_) async => []);
    await tocar(tester, find.widgetWithText(FilledButton, 'Excluir'));

    verify(() => falsos.anexos.excluir(10, 1)).called(1);
    expect(find.text('Anexo excluído.'), findsOneWidget);
    expect(find.text('Nenhum arquivo anexado.'), findsOneWidget);
  });

  testWidgets('obrigação concluída permite anexar e baixar, mas não excluir', (tester) async {
    await abrirDetalhe(tester, id: 12);

    expect(find.text('Anexar arquivo'), findsOneWidget);
    expect(find.byTooltip('Baixar recibo-dctfweb.pdf'), findsOneWidget);
    expect(find.byTooltip('Excluir recibo-dctfweb.pdf'), findsNothing);
  });

  testWidgets('permite tentar de novo quando a lista de anexos não carrega', (tester) async {
    final falsos = repositoriosComDados();
    when(() => falsos.anexos.listar(any()))
        .thenThrow(const ErroApi(codigo: CodigoErro.semConexao, mensagem: 'Sem conexão com o servidor.'));
    await abrirDetalhe(tester, repositorios: falsos);

    when(() => falsos.anexos.listar(any())).thenAnswer((_) async => [anexoDeExemplo()]);
    await tocar(tester, find.text('Tentar novamente'));

    expect(find.text('recibo-dctfweb.pdf'), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is Icone && widget.icone == Icones.arquivoPdf), findsOneWidget);
  });

  testWidgets('não abre um segundo seletor enquanto o primeiro está aberto', (tester) async {
    final falsos = repositoriosComDados();
    final escolha = Completer<ArquivoEscolhido?>();
    when(() => falsos.arquivos.escolher(extensoes: any(named: 'extensoes'))).thenAnswer((_) => escolha.future);
    await abrirDetalhe(tester, repositorios: falsos);

    await tocar(tester, find.text('Anexar arquivo'));
    await tester.tap(find.text('Anexar arquivo'));
    await tester.pump();
    escolha.complete(null);
    await tester.pumpAndSettle();

    verify(() => falsos.arquivos.escolher(extensoes: any(named: 'extensoes'))).called(1);
  });

  testWidgets('confere o tamanho lido quando o dispositivo não informa o tamanho do arquivo', (tester) async {
    final falsos = repositoriosComDados();
    when(() => falsos.arquivos.escolher(extensoes: any(named: 'extensoes')))
        .thenAnswer((_) async => (nome: 'grande.pdf', tamanho: null, ler: () async => Uint8List(11 * 1024 * 1024)));
    await abrirDetalhe(tester, repositorios: falsos);

    await tocar(tester, find.text('Anexar arquivo'));

    expect(find.text('O arquivo deve ter no máximo 10 MB.'), findsOneWidget);
    verifyNever(
      () => falsos.anexos.enviar(
        any(),
        nome: any(named: 'nome'),
        bytes: any(named: 'bytes'),
      ),
    );
  });

  testWidgets('recarrega a lista quando o anexo já tinha sido excluído por outra pessoa', (tester) async {
    final falsos = repositoriosComDados();
    when(() => falsos.anexos.excluir(any(), any()))
        .thenThrow(const ErroApi(codigo: CodigoErro.recursoNaoEncontrado, mensagem: 'Não existe anexo com o id 1.'));
    await abrirDetalhe(tester, repositorios: falsos);

    await tocar(tester, find.byTooltip('Excluir recibo-dctfweb.pdf'));
    when(() => falsos.anexos.listar(10)).thenAnswer((_) async => []);
    await tocar(tester, find.widgetWithText(FilledButton, 'Excluir'));

    expect(find.text('Não existe anexo com o id 1.'), findsOneWidget);
    expect(find.text('Nenhum arquivo anexado.'), findsOneWidget);
  });
}
