import '../../../core/dominio/json.dart';
import '../../../core/dominio/situacao.dart';
import '../../../core/dominio/termos_do_cadastro.dart';

const termosDaEmpresa = TermosDoCadastro(substantivo: 'Empresa', genero: Genero.feminino);

class Empresa {
  const Empresa({
    required this.id,
    required this.razaoSocial,
    required this.cnpj,
    required this.situacao,
    required this.versao,
    this.nomeFantasia,
    this.email,
    this.telefone,
  });

  factory Empresa.deJson(Json json) => Empresa(
    id: json['id'] as int,
    razaoSocial: json['razaoSocial'] as String,
    nomeFantasia: json['nomeFantasia'] as String?,
    cnpj: json['cnpj'] as String,
    email: json['email'] as String?,
    telefone: json['telefone'] as String?,
    situacao: Situacao.daApi(json['situacao']),
    versao: json['versao'] as int,
  );

  final int id;
  final String razaoSocial;
  final String? nomeFantasia;
  final String cnpj;
  final String? email;
  final String? telefone;
  final Situacao situacao;
  final int versao;
}

class DadosEmpresa {
  const DadosEmpresa({
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.cnpj,
    required this.email,
    required this.telefone,
  });

  final String razaoSocial;
  final String nomeFantasia;
  final String cnpj;
  final String email;
  final String telefone;

  Json paraJson({int? versao}) => {
    'razaoSocial': razaoSocial,
    'nomeFantasia': nomeFantasia,
    'cnpj': cnpj,
    'email': email,
    'telefone': telefone,
    'versao': ?versao,
  };
}
