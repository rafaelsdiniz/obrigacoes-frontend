abstract final class Datas {
  static DateTime daApi(String valor) {
    final partes = valor.split('-').map(int.parse).toList();
    return DateTime(partes[0], partes[1], partes[2]);
  }

  static String paraApi(DateTime data) => '${data.year}-${_doisDigitos(data.month)}-${_doisDigitos(data.day)}';

  static String formatar(DateTime data) => '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/${data.year}';

  static String formatarComHora(DateTime instante) {
    final local = instante.toLocal();
    return '${formatar(local)} às ${_doisDigitos(local.hour)}:${_doisDigitos(local.minute)}';
  }

  static DateTime hoje() {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  static int diasEntre(DateTime de, DateTime ate) =>
      DateTime.utc(ate.year, ate.month, ate.day).difference(DateTime.utc(de.year, de.month, de.day)).inDays;

  static String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');
}

class Competencia {
  const Competencia(this.ano, this.mes) : assert(mes >= 1 && mes <= 12);

  factory Competencia.daApi(String valor) {
    final partes = valor.split('-').map(int.parse).toList();
    return Competencia(partes[0], partes[1]);
  }

  static Competencia? deTexto(String texto) {
    final correspondencia = RegExp(r'^(\d{2})/(\d{4})$').firstMatch(texto.trim());
    if (correspondencia == null) {
      return null;
    }
    final mes = int.parse(correspondencia.group(1)!);
    final ano = int.parse(correspondencia.group(2)!);
    return mes >= 1 && mes <= 12 ? Competencia(ano, mes) : null;
  }

  final int ano;
  final int mes;

  String paraApi() => '$ano-${mes.toString().padLeft(2, '0')}';

  @override
  String toString() => '${mes.toString().padLeft(2, '0')}/$ano';

  @override
  bool operator ==(Object other) => other is Competencia && other.ano == ano && other.mes == mes;

  @override
  int get hashCode => Object.hash(ano, mes);
}
