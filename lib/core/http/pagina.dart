import '../dominio/json.dart';

class Pagina<T> {
  const Pagina({required this.itens, required this.numero, required this.totalItens, required this.totalPaginas});

  factory Pagina.deJson(Json json, T Function(Json) converter) => Pagina(
    itens: (json['conteudo'] as List<dynamic>).cast<Json>().map(converter).toList(),
    numero: json['pagina'] as int,
    totalItens: json['totalElementos'] as int,
    totalPaginas: json['totalPaginas'] as int,
  );

  final List<T> itens;
  final int numero;
  final int totalItens;
  final int totalPaginas;

  bool get vazia => itens.isEmpty;
  bool get temAnterior => numero > 0;
  bool get temProxima => numero + 1 < totalPaginas;
}
