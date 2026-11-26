import 'package:material_ui/material_ui.dart';

import '../dominio/situacao.dart';

enum _AcaoDeCadastro { editar, alterarSituacao }

class MenuDeCadastro extends StatelessWidget {
  const MenuDeCadastro({
    required this.nome,
    required this.situacao,
    required this.aoEditar,
    required this.aoAlterarSituacao,
    super.key,
  });

  final String nome;
  final Situacao situacao;
  final VoidCallback aoEditar;
  final VoidCallback aoAlterarSituacao;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_AcaoDeCadastro>(
    tooltip: 'Ações de $nome',
    icon: const Icon(Icons.more_horiz_rounded),
    onSelected: (acao) => switch (acao) {
      _AcaoDeCadastro.editar => aoEditar(),
      _AcaoDeCadastro.alterarSituacao => aoAlterarSituacao(),
    },
    itemBuilder: (context) => [
      const PopupMenuItem(value: _AcaoDeCadastro.editar, child: Text('Editar')),
      PopupMenuItem(
        value: _AcaoDeCadastro.alterarSituacao,
        child: Text(situacao == Situacao.ativo ? 'Inativar' : 'Ativar'),
      ),
    ],
  );
}
