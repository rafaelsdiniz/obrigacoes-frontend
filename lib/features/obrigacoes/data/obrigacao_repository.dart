import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatacao/datas.dart';
import '../../../core/http/cliente_api.dart';
import '../../../core/http/pagina.dart';
import '../../../core/http/parametros_de_listagem.dart';
import '../domain/filtro_obrigacoes.dart';
import '../domain/historico_de_status.dart';
import '../domain/obrigacao.dart';
import '../domain/resumo_obrigacoes.dart';
import '../domain/status_obrigacao.dart';

final obrigacaoRepositoryProvider = Provider((ref) => ObrigacaoRepository(ref.watch(clienteApiProvider)));

class ObrigacaoRepository {
  const ObrigacaoRepository(this._api);

  static const _recurso = 'obrigacoes';

  final ClienteApi _api;

  Future<Pagina<Obrigacao>> listar(FiltroObrigacoes filtro) async => Pagina.deJson(
    await _api.get(
      _recurso,
      parametros: {
        'busca': filtro.busca.trim(),
        'status': [for (final status in filtro.status) status.valorApi],
        'atrasada': filtro.somenteAtrasadas ? true : null,
        'page': filtro.pagina,
        'size': tamanhoDaPagina,
        'sort': 'dataVencimento',
      },
    ),
    Obrigacao.deJson,
  );

  Future<Pagina<Obrigacao>> proximosVencimentos({int quantidade = 6}) async => Pagina.deJson(
    await _api.get(
      _recurso,
      parametros: {
        'status': [StatusObrigacao.pendente.valorApi, StatusObrigacao.emAndamento.valorApi],
        'vencimentoDe': Datas.paraApi(Datas.hoje()),
        'size': quantidade,
        'sort': 'dataVencimento',
      },
    ),
    Obrigacao.deJson,
  );

  Future<ResumoObrigacoes> resumir() async => ResumoObrigacoes.deJson(await _api.get('$_recurso/resumo'));

  Future<Obrigacao> buscar(int id) async => Obrigacao.deJson(await _api.get('$_recurso/$id'));

  Future<List<TransicaoDeStatus>> historico(int id) async =>
      (await _api.getLista('$_recurso/$id/historico')).map(TransicaoDeStatus.deJson).toList();

  Future<Obrigacao> cadastrar(DadosObrigacao dados) async =>
      Obrigacao.deJson(await _api.post(_recurso, corpo: dados.paraJson()));

  Future<Obrigacao> atualizar(Obrigacao obrigacao, DadosObrigacao dados) async =>
      Obrigacao.deJson(await _api.put('$_recurso/${obrigacao.id}', dados.paraJson(versao: obrigacao.versao)));

  Future<Obrigacao> avancarStatus(Obrigacao obrigacao, StatusObrigacao novoStatus) async =>
      Obrigacao.deJson(await _api.patch('$_recurso/${obrigacao.id}/status', corpo: {'status': novoStatus.valorApi}));
}
