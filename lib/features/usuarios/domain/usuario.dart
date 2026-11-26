import '../../../core/dominio/json.dart';
import '../../../core/dominio/situacao.dart';

class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.situacao,
    required this.versao,
    this.cargo,
  });

  factory Usuario.deJson(Json json) => Usuario(
    id: json['id'] as int,
    nome: json['nome'] as String,
    email: json['email'] as String,
    cargo: json['cargo'] as String?,
    situacao: Situacao.daApi(json['situacao']),
    versao: json['versao'] as int,
  );

  final int id;
  final String nome;
  final String email;
  final String? cargo;
  final Situacao situacao;
  final int versao;
}

class DadosUsuario {
  const DadosUsuario({required this.nome, required this.email, required this.cargo});

  final String nome;
  final String email;
  final String cargo;

  Json paraJson({int? versao}) => {'nome': nome, 'email': email, 'cargo': cargo, 'versao': ?versao};
}
