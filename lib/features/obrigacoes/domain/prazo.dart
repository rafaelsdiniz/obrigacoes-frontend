import '../../../core/formatacao/datas.dart';
import 'obrigacao.dart';

enum UrgenciaDoPrazo { concluida, atrasada, venceHoje, proxima, tranquila }

class Prazo {
  const Prazo._(this.urgencia, this.descricao);

  factory Prazo.de(Obrigacao obrigacao, DateTime hoje) {
    if (obrigacao.concluida) {
      return const Prazo._(UrgenciaDoPrazo.concluida, 'Entregue');
    }
    final dias = Datas.diasEntre(hoje, obrigacao.dataVencimento);
    if (obrigacao.atrasada) {
      return Prazo._(UrgenciaDoPrazo.atrasada, dias < 0 ? 'Venceu há ${_dias(-dias)}' : 'Vencida');
    }
    if (dias <= 0) {
      return const Prazo._(UrgenciaDoPrazo.venceHoje, 'Vence hoje');
    }
    if (dias <= diasDeAntecedencia) {
      return Prazo._(UrgenciaDoPrazo.proxima, 'Vence em ${_dias(dias)}');
    }
    return Prazo._(UrgenciaDoPrazo.tranquila, 'Vence em ${_dias(dias)}');
  }

  static const diasDeAntecedencia = 7;

  final UrgenciaDoPrazo urgencia;
  final String descricao;

  static String _dias(int quantidade) => quantidade == 1 ? '1 dia' : '$quantidade dias';
}
