import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/arquivos/arquivos_do_dispositivo.dart';
import '../../../core/formatacao/tamanhos.dart';
import '../../../core/http/erro_api.dart';
import '../data/anexo_repository.dart';
import '../domain/anexo.dart';
import '../domain/tipo_de_anexo.dart';

final anexosDaObrigacaoProvider = FutureProvider.autoDispose.family<List<Anexo>, int>(
  (ref, obrigacaoId) => ref.watch(anexoRepositoryProvider).listar(obrigacaoId),
);

final gestaoDeAnexosProvider = Provider(GestaoDeAnexos.new);

class GestaoDeAnexos {
  const GestaoDeAnexos(this._ref);

  final Ref _ref;

  AnexoRepository get _repositorio => _ref.read(anexoRepositoryProvider);

  Future<void> enviar(int obrigacaoId, ArquivoEscolhido arquivo) async {
    _garantirTipoPermitido(arquivo.nome);
    _garantirTamanhoPermitido(arquivo.tamanho);
    final bytes = await arquivo.ler();
    _garantirTamanhoPermitido(bytes.length);
    try {
      await _repositorio.enviar(obrigacaoId, nome: arquivo.nome, bytes: bytes);
    } finally {
      _ref.invalidate(anexosDaObrigacaoProvider(obrigacaoId));
    }
  }

  Future<void> excluir(int obrigacaoId, Anexo anexo) async {
    try {
      await _repositorio.excluir(obrigacaoId, anexo.id);
    } finally {
      _ref.invalidate(anexosDaObrigacaoProvider(obrigacaoId));
    }
  }

  Future<void> baixar(int obrigacaoId, Anexo anexo) async {
    final iniciado = await _ref
        .read(arquivosDoDispositivoProvider)
        .baixar(_repositorio.enderecoDoArquivo(obrigacaoId, anexo.id));
    if (!iniciado) {
      throw const ErroApi(codigo: CodigoErro.desconhecido, mensagem: 'Não foi possível baixar o arquivo.');
    }
  }

  static void _garantirTipoPermitido(String nome) {
    final ponto = nome.lastIndexOf('.');
    final extensao = ponto < 0 ? '' : nome.substring(ponto + 1).toLowerCase();
    if (!TipoDeAnexo.extensoesPermitidas.contains(extensao)) {
      throw ErroApi(
        codigo: CodigoErro.arquivoInvalido,
        mensagem: '"$nome" não é aceito. Envie ${TipoDeAnexo.descricaoDosAceitos}.',
      );
    }
  }

  static void _garantirTamanhoPermitido(int? tamanho) {
    if (tamanho != null && tamanho > Anexo.tamanhoMaximo) {
      throw ErroApi(
        codigo: CodigoErro.arquivoInvalido,
        mensagem: 'O arquivo deve ter no máximo ${Tamanhos.formatar(Anexo.tamanhoMaximo)}.',
      );
    }
  }
}
