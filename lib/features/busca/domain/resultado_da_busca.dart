import '../../empresas/domain/empresa.dart';
import '../../obrigacoes/domain/obrigacao.dart';
import '../../usuarios/domain/usuario.dart';

sealed class ItemDaBusca {
  const ItemDaBusca();
}

class ObrigacaoEncontrada extends ItemDaBusca {
  const ObrigacaoEncontrada(this.obrigacao);

  final Obrigacao obrigacao;
}

class EmpresaEncontrada extends ItemDaBusca {
  const EmpresaEncontrada(this.empresa);

  final Empresa empresa;
}

class UsuarioEncontrado extends ItemDaBusca {
  const UsuarioEncontrado(this.usuario);

  final Usuario usuario;
}

class ResultadoDaBusca {
  const ResultadoDaBusca({required this.obrigacoes, required this.empresas, required this.usuarios});

  static const limitePorGrupo = 5;

  final List<Obrigacao> obrigacoes;
  final List<Empresa> empresas;
  final List<Usuario> usuarios;

  List<ItemDaBusca> get itens => [
    ...obrigacoes.map(ObrigacaoEncontrada.new),
    ...empresas.map(EmpresaEncontrada.new),
    ...usuarios.map(UsuarioEncontrado.new),
  ];

  int get total => obrigacoes.length + empresas.length + usuarios.length;
}
