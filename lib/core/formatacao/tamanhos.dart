abstract final class Tamanhos {
  static const _kilobyte = 1024;
  static const _megabyte = _kilobyte * 1024;

  static int megabytes(int quantidade) => quantidade * _megabyte;

  static String formatar(int bytes) {
    if (bytes < _kilobyte) {
      return '$bytes B';
    }
    if (bytes < _megabyte) {
      return '${(bytes / _kilobyte).round()} KB';
    }
    final megabytes = bytes / _megabyte;
    final texto = megabytes == megabytes.roundToDouble() ? '${megabytes.round()}' : megabytes.toStringAsFixed(1);
    return '${texto.replaceAll('.', ',')} MB';
  }
}
