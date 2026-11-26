import '../../../core/formatacao/datas.dart';
import 'obrigacao.dart';

enum UrgenciaDoPrazo { concluida, atrasada, venceHoje, proxima, tranquila }

class Prazo {
  const Prazo._(this.urgencia, this.descricao, this.diasAteOVencimento);

  factory Prazo.de(Obrigacao obrigacao, DateTime hoje) {
    final dias = Datas.diasEntre(hoje, obrigacao.dataVencimento);
    if (obrigacao.concluida) {
      return Prazo._(UrgenciaDoPrazo.concluida, 'Entregue', dias);
    }
    if (obrigacao.atrasada) {
      return Prazo._(UrgenciaDoPrazo.atrasada, dias < 0 ? 'Venceu há ${emDias(-dias)}' : 'Vencida', dias);
    }
    if (dias <= 0) {
      return Prazo._(UrgenciaDoPrazo.venceHoje, 'Vence hoje', dias);
    }
    if (dias <= diasDeAntecedencia) {
      return Prazo._(UrgenciaDoPrazo.proxima, 'Vence em ${emDias(dias)}', dias);
    }
    return Prazo._(UrgenciaDoPrazo.tranquila, 'Vence em ${emDias(dias)}', dias);
  }

  static const diasDeAntecedencia = 7;

  final UrgenciaDoPrazo urgencia;
  final String descricao;
  final int diasAteOVencimento;

  static String emDias(int quantidade) => quantidade == 1 ? '1 dia' : '$quantidade dias';
}
