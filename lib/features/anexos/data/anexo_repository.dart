import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/cliente_api.dart';
import '../domain/anexo.dart';

final anexoRepositoryProvider = Provider((ref) => AnexoRepository(ref.watch(clienteApiProvider)));

class AnexoRepository {
  const AnexoRepository(this._api);

  final ClienteApi _api;

  static String _recurso(int obrigacaoId) => 'obrigacoes/$obrigacaoId/anexos';

  Future<List<Anexo>> listar(int obrigacaoId) async =>
      (await _api.getLista(_recurso(obrigacaoId))).map(Anexo.deJson).toList();

  Future<Anexo> enviar(int obrigacaoId, {required String nome, required Uint8List bytes}) async =>
      Anexo.deJson(await _api.enviarArquivo(_recurso(obrigacaoId), campo: 'arquivo', nome: nome, bytes: bytes));

  Future<void> excluir(int obrigacaoId, int anexoId) => _api.delete('${_recurso(obrigacaoId)}/$anexoId');

  Uri enderecoDoArquivo(int obrigacaoId, int anexoId) => _api.endereco('${_recurso(obrigacaoId)}/$anexoId');
}
