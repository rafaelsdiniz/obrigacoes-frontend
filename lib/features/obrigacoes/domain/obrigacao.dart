import '../../../core/dominio/json.dart';
import '../../../core/dominio/situacao.dart';
import '../../../core/formatacao/datas.dart';
import 'status_obrigacao.dart';
import 'tipo_obrigacao.dart';

class Obrigacao {
  const Obrigacao({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.dataVencimento,
    required this.status,
    required this.atrasada,
    required this.empresa,
    required this.responsavel,
    required this.versao,
    this.descricao,
    this.competencia,
    this.proximoStatus,
  });

  factory Obrigacao.deJson(Json json) => Obrigacao(
    id: json['id'] as int,
    titulo: json['titulo'] as String,
    descricao: json['descricao'] as String?,
    tipo: TipoObrigacao.daApi(json['tipo']),
    competencia: switch (json['competencia']) {
      final String valor => Competencia.daApi(valor),
      _ => null,
    },
    dataVencimento: Datas.daApi(json['dataVencimento'] as String),
    status: StatusObrigacao.daApi(json['status']),
    proximoStatus: json['proximoStatus'] == null ? null : StatusObrigacao.daApi(json['proximoStatus']),
    atrasada: json['atrasada'] as bool,
    empresa: EmpresaDaObrigacao.deJson(json['empresa'] as Json),
    responsavel: ResponsavelDaObrigacao.deJson(json['responsavel'] as Json),
    versao: json['versao'] as int,
  );

  final int id;
  final String titulo;
  final String? descricao;
  final TipoObrigacao tipo;
  final Competencia? competencia;
  final DateTime dataVencimento;
  final StatusObrigacao status;
  final StatusObrigacao? proximoStatus;
  final bool atrasada;
  final EmpresaDaObrigacao empresa;
  final ResponsavelDaObrigacao responsavel;
  final int versao;

  bool get concluida => status == StatusObrigacao.concluida;
}

class EmpresaDaObrigacao {
  const EmpresaDaObrigacao({required this.id, required this.razaoSocial, required this.cnpj, required this.situacao});

  factory EmpresaDaObrigacao.deJson(Json json) => EmpresaDaObrigacao(
    id: json['id'] as int,
    razaoSocial: json['razaoSocial'] as String,
    cnpj: json['cnpj'] as String,
    situacao: Situacao.daApi(json['situacao']),
  );

  final int id;
  final String razaoSocial;
  final String cnpj;
  final Situacao situacao;
}

class ResponsavelDaObrigacao {
  const ResponsavelDaObrigacao({required this.id, required this.nome, required this.email, required this.situacao});

  factory ResponsavelDaObrigacao.deJson(Json json) => ResponsavelDaObrigacao(
    id: json['id'] as int,
    nome: json['nome'] as String,
    email: json['email'] as String,
    situacao: Situacao.daApi(json['situacao']),
  );

  final int id;
  final String nome;
  final String email;
  final Situacao situacao;
}

class DadosObrigacao {
  const DadosObrigacao({
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.competencia,
    required this.dataVencimento,
    required this.empresaId,
    required this.responsavelId,
  });

  final String titulo;
  final String descricao;
  final TipoObrigacao tipo;
  final Competencia? competencia;
  final DateTime dataVencimento;
  final int empresaId;
  final int responsavelId;

  Json paraJson({int? versao}) => {
    'titulo': titulo,
    'descricao': descricao,
    'tipo': tipo.valorApi,
    'competencia': competencia?.paraApi(),
    'dataVencimento': Datas.paraApi(dataVencimento),
    'empresaId': empresaId,
    'responsavelId': responsavelId,
    'versao': ?versao,
  };
}
