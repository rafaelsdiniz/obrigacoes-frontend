import '../dominio/filtro_cadastro.dart';

const tamanhoDaPagina = 20;
const tamanhoMaximoDaPagina = 100;

Map<String, Object?> parametrosDeListagem(FiltroCadastro filtro, {required String ordenacao}) => {
  'busca': filtro.busca.trim(),
  'situacao': filtro.situacao?.valorApi,
  'page': filtro.pagina,
  'size': tamanhoDaPagina,
  'sort': ordenacao,
};
