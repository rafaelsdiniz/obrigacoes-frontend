import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obrigacoes_app/core/dominio/situacao.dart';
import 'package:obrigacoes_app/core/formatacao/datas.dart';
import 'package:obrigacoes_app/core/http/cliente_api.dart';
import 'package:obrigacoes_app/features/empresas/data/empresa_repository.dart';
import 'package:obrigacoes_app/features/empresas/domain/empresa.dart';
import 'package:obrigacoes_app/features/obrigacoes/data/obrigacao_repository.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/obrigacao.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/status_obrigacao.dart';
import 'package:obrigacoes_app/features/obrigacoes/domain/tipo_obrigacao.dart';
import 'package:obrigacoes_app/features/usuarios/data/usuario_repository.dart';
import 'package:obrigacoes_app/features/usuarios/domain/usuario.dart';

import '../servidor_de_contrato.dart';

const _empresaDaApi = {
  'id': 1,
  'razaoSocial': 'Padaria Pão Dourado LTDA',
  'nomeFantasia': 'Pão Dourado',
  'cnpj': '11222333000181',
  'email': 'financeiro@paodourado.com.br',
  'telefone': '(63) 3214-0000',
  'situacao': 'ATIVO',
  'criadoEm': '2026-11-26T11:41:53.310971Z',
  'atualizadoEm': '2026-11-26T11:41:53.310971Z',
  'versao': 3,
};

const _usuarioDaApi = {
  'id': 1,
  'nome': 'Ana Souza',
  'email': 'ana.souza@escritorio.com.br',
  'cargo': 'Analista Fiscal',
  'situacao': 'INATIVO',
  'criadoEm': '2026-11-26T11:41:53.400146Z',
  'atualizadoEm': '2026-11-26T11:41:53.400146Z',
  'versao': 5,
};

const _obrigacaoDaApi = {
  'id': 1,
  'titulo': 'DCTFWeb',
  'descricao': 'DCTFWeb referente à competência 2026-10.',
  'tipo': 'PREVIDENCIARIA',
  'competencia': '2026-10',
  'dataVencimento': '2026-11-20',
  'status': 'EM_ANDAMENTO',
  'proximoStatus': 'CONCLUIDA',
  'atrasada': true,
  'empresa': {'id': 1, 'razaoSocial': 'Padaria Pão Dourado LTDA', 'cnpj': '11222333000181', 'situacao': 'ATIVO'},
  'responsavel': {'id': 1, 'nome': 'Ana Souza', 'email': 'ana.souza@escritorio.com.br', 'situacao': 'ATIVO'},
  'criadoEm': '2026-11-26T11:41:53.461226Z',
  'atualizadoEm': '2026-11-26T11:41:53.508610Z',
  'versao': 7,
};

ClienteApi _clienteCom(ServidorDeContrato servidor) =>
    ClienteApi(Dio(BaseOptions(baseUrl: 'http://api.teste/api/v1/'))..httpClientAdapter = servidor);

void main() {
  group('empresas', () {
    test('lê a resposta da API e envia a versão lida ao atualizar', () async {
      final servidor = ServidorDeContrato(_empresaDaApi);
      final repositorio = EmpresaRepository(_clienteCom(servidor));

      final empresa = await repositorio.buscar(1);
      expect(empresa.razaoSocial, 'Padaria Pão Dourado LTDA');
      expect(empresa.situacao, Situacao.ativo);
      expect(empresa.versao, 3);

      await repositorio.atualizar(
        empresa,
        const DadosEmpresa(
          razaoSocial: 'Padaria Pão Dourado S.A.',
          nomeFantasia: 'Pão Dourado',
          cnpj: '11222333000181',
          email: 'financeiro@paodourado.com.br',
          telefone: '',
        ),
      );

      expect(servidor.requisicao.method, 'PUT');
      expect(servidor.requisicao.path, endsWith('empresas/1'));
      expect(servidor.corpoRecebido, containsPair('versao', 3));
      expect(servidor.corpoRecebido, containsPair('razaoSocial', 'Padaria Pão Dourado S.A.'));
    });

    test('não envia versão ao cadastrar', () async {
      final servidor = ServidorDeContrato(_empresaDaApi);

      await EmpresaRepository(_clienteCom(servidor)).cadastrar(
        const DadosEmpresa(razaoSocial: 'Nova', nomeFantasia: '', cnpj: '11222333000181', email: '', telefone: ''),
      );

      expect(servidor.requisicao.method, 'POST');
      expect(servidor.corpoRecebido, isNot(contains('versao')));
    });
  });

  group('usuários', () {
    test('lê a resposta da API e envia a versão lida ao atualizar', () async {
      final servidor = ServidorDeContrato(_usuarioDaApi);
      final repositorio = UsuarioRepository(_clienteCom(servidor));

      final usuario = await repositorio.buscar(1);
      expect(usuario.nome, 'Ana Souza');
      expect(usuario.situacao, Situacao.inativo);

      await repositorio.atualizar(
        usuario,
        const DadosUsuario(nome: 'Ana Souza Lima', email: 'ana.souza@escritorio.com.br', cargo: 'Analista Fiscal'),
      );

      expect(servidor.requisicao.method, 'PUT');
      expect(servidor.corpoRecebido, containsPair('versao', 5));
      expect(servidor.corpoRecebido, containsPair('nome', 'Ana Souza Lima'));
    });
  });

  group('obrigações', () {
    test('lê todos os campos da resposta da API', () async {
      final obrigacao = await ObrigacaoRepository(_clienteCom(ServidorDeContrato(_obrigacaoDaApi))).buscar(1);

      expect(obrigacao.tipo, TipoObrigacao.previdenciaria);
      expect(obrigacao.competencia?.ano, 2026);
      expect(obrigacao.competencia?.mes, 10);
      expect(obrigacao.dataVencimento, DateTime(2026, 11, 20));
      expect(obrigacao.status, StatusObrigacao.emAndamento);
      expect(obrigacao.proximoStatus, StatusObrigacao.concluida);
      expect(obrigacao.atrasada, isTrue);
      expect(obrigacao.empresa.razaoSocial, 'Padaria Pão Dourado LTDA');
      expect(obrigacao.responsavel.nome, 'Ana Souza');
      expect(obrigacao.versao, 7);
    });

    test('envia os campos esperados pela API e a versão lida ao atualizar', () async {
      final servidor = ServidorDeContrato(_obrigacaoDaApi);
      final repositorio = ObrigacaoRepository(_clienteCom(servidor));
      final obrigacao = await repositorio.buscar(1);

      await repositorio.atualizar(
        obrigacao,
        DadosObrigacao(
          titulo: 'DCTFWeb retificadora',
          descricao: '',
          tipo: TipoObrigacao.fiscal,
          competencia: const Competencia(2026, 10),
          dataVencimento: DateTime(2026, 11, 25),
          empresaId: 1,
          responsavelId: 2,
        ),
      );

      expect(servidor.requisicao.method, 'PUT');
      expect(servidor.corpoRecebido, {
        'titulo': 'DCTFWeb retificadora',
        'descricao': '',
        'tipo': 'FISCAL',
        'competencia': '2026-10',
        'dataVencimento': '2026-11-25',
        'empresaId': 1,
        'responsavelId': 2,
        'versao': 7,
      });
    });

    test('avança o status enviando apenas o novo status', () async {
      final servidor = ServidorDeContrato(_obrigacaoDaApi);
      final repositorio = ObrigacaoRepository(_clienteCom(servidor));
      final obrigacao = await repositorio.buscar(1);

      await repositorio.avancarStatus(obrigacao, StatusObrigacao.concluida);

      expect(servidor.requisicao.method, 'PATCH');
      expect(servidor.requisicao.path, endsWith('obrigacoes/1/status'));
      expect(servidor.corpoRecebido, {'status': 'CONCLUIDA'});
    });
  });
}
