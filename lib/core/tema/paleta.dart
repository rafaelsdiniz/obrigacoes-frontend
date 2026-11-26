import 'package:material_ui/material_ui.dart';

@immutable
class Paleta extends ThemeExtension<Paleta> {
  const Paleta({
    required this.primaria,
    required this.sobrePrimaria,
    required this.primariaContainer,
    required this.marca,
    required this.fundo,
    required this.superficieMaisBaixa,
    required this.superficieBaixa,
    required this.superficie,
    required this.superficieAlta,
    required this.texto,
    required this.textoVariante,
    required this.contorno,
    required this.contornoVariante,
    required this.secundarioContainer,
    required this.sobreSecundarioContainer,
    required this.erro,
    required this.erroContainer,
    required this.sobreErroContainer,
    required this.aviso,
    required this.info,
    required this.sucesso,
    required this.tomDeAtraso,
    required this.sobreForte,
    required this.sobrePrimariaContainer,
    required this.sobreMarca,
    required this.barraLateral,
    required this.sobreBarraLateral,
  });

  static const claro = Paleta(
    primaria: Color(0xFF0B1628),
    sobrePrimaria: Color(0xFFFFFFFF),
    primariaContainer: Color(0xFF1E293B),
    marca: Color(0xFFF59E0B),
    fundo: Color(0xFFF5F7FA),
    superficieMaisBaixa: Color(0xFFFFFFFF),
    superficieBaixa: Color(0xFFF1F4F8),
    superficie: Color(0xFFEBEFF4),
    superficieAlta: Color(0xFFE2E8F0),
    texto: Color(0xFF0F172A),
    textoVariante: Color(0xFF475569),
    contorno: Color(0xFF64748B),
    contornoVariante: Color(0xFFCBD5E1),
    secundarioContainer: Color(0xFFE2E8F0),
    sobreSecundarioContainer: Color(0xFF0F172A),
    erro: Color(0xFFC81E1E),
    erroContainer: Color(0xFFFEE2E2),
    sobreErroContainer: Color(0xFF991B1B),
    aviso: Color(0xFFB45309),
    info: Color(0xFF2563EB),
    sucesso: Color(0xFF047857),
    tomDeAtraso: Color(0xFFFEF2F2),
    sobreForte: Color(0xFFFFFFFF),
    sobrePrimariaContainer: Color(0xFFFFFFFF),
    sobreMarca: Color(0xFF0B1628),
    barraLateral: Color(0xFF0B1628),
    sobreBarraLateral: Color(0xFFFFFFFF),
  );

  static const escuro = Paleta(
    primaria: Color(0xFFF59E0B),
    sobrePrimaria: Color(0xFF0B1628),
    primariaContainer: Color(0xFF1E293B),
    marca: Color(0xFFF59E0B),
    fundo: Color(0xFF0B1120),
    superficieMaisBaixa: Color(0xFF0F172A),
    superficieBaixa: Color(0xFF131C2E),
    superficie: Color(0xFF1A2335),
    superficieAlta: Color(0xFF243047),
    texto: Color(0xFFE2E8F0),
    textoVariante: Color(0xFF94A3B8),
    contorno: Color(0xFF7C8BA1),
    contornoVariante: Color(0xFF334155),
    secundarioContainer: Color(0xFF1E293B),
    sobreSecundarioContainer: Color(0xFFE2E8F0),
    erro: Color(0xFFF87171),
    erroContainer: Color(0xFF7F1D1D),
    sobreErroContainer: Color(0xFFFEE2E2),
    aviso: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    sucesso: Color(0xFF34D399),
    tomDeAtraso: Color(0x2EDC2626),
    sobreForte: Color(0xFF0B1628),
    sobrePrimariaContainer: Color(0xFFFFFFFF),
    sobreMarca: Color(0xFF0B1628),
    barraLateral: Color(0xFF080D19),
    sobreBarraLateral: Color(0xFFFFFFFF),
  );

  final Color primaria;
  final Color sobrePrimaria;
  final Color primariaContainer;
  final Color marca;
  final Color fundo;
  final Color superficieMaisBaixa;
  final Color superficieBaixa;
  final Color superficie;
  final Color superficieAlta;
  final Color texto;
  final Color textoVariante;
  final Color contorno;
  final Color contornoVariante;
  final Color secundarioContainer;
  final Color sobreSecundarioContainer;
  final Color erro;
  final Color erroContainer;
  final Color sobreErroContainer;
  final Color aviso;
  final Color info;
  final Color sucesso;
  final Color tomDeAtraso;
  final Color sobreForte;
  final Color sobrePrimariaContainer;
  final Color sobreMarca;
  final Color barraLateral;
  final Color sobreBarraLateral;

  Color get borda => contornoVariante.withValues(alpha: 0.6);

  Color get bordaSuave => contornoVariante.withValues(alpha: 0.4);

  Color get bordaDoCampo => contornoVariante.withValues(alpha: 0.9);

  Color get realce => superficieBaixa.withValues(alpha: 0.6);

  @override
  Paleta copyWith() => this;

  @override
  Paleta lerp(Paleta? outra, double t) {
    if (outra == null) {
      return this;
    }
    return Paleta(
      primaria: Color.lerp(primaria, outra.primaria, t)!,
      sobrePrimaria: Color.lerp(sobrePrimaria, outra.sobrePrimaria, t)!,
      primariaContainer: Color.lerp(primariaContainer, outra.primariaContainer, t)!,
      marca: Color.lerp(marca, outra.marca, t)!,
      fundo: Color.lerp(fundo, outra.fundo, t)!,
      superficieMaisBaixa: Color.lerp(superficieMaisBaixa, outra.superficieMaisBaixa, t)!,
      superficieBaixa: Color.lerp(superficieBaixa, outra.superficieBaixa, t)!,
      superficie: Color.lerp(superficie, outra.superficie, t)!,
      superficieAlta: Color.lerp(superficieAlta, outra.superficieAlta, t)!,
      texto: Color.lerp(texto, outra.texto, t)!,
      textoVariante: Color.lerp(textoVariante, outra.textoVariante, t)!,
      contorno: Color.lerp(contorno, outra.contorno, t)!,
      contornoVariante: Color.lerp(contornoVariante, outra.contornoVariante, t)!,
      secundarioContainer: Color.lerp(secundarioContainer, outra.secundarioContainer, t)!,
      sobreSecundarioContainer: Color.lerp(sobreSecundarioContainer, outra.sobreSecundarioContainer, t)!,
      erro: Color.lerp(erro, outra.erro, t)!,
      erroContainer: Color.lerp(erroContainer, outra.erroContainer, t)!,
      sobreErroContainer: Color.lerp(sobreErroContainer, outra.sobreErroContainer, t)!,
      aviso: Color.lerp(aviso, outra.aviso, t)!,
      info: Color.lerp(info, outra.info, t)!,
      sucesso: Color.lerp(sucesso, outra.sucesso, t)!,
      tomDeAtraso: Color.lerp(tomDeAtraso, outra.tomDeAtraso, t)!,
      sobreForte: Color.lerp(sobreForte, outra.sobreForte, t)!,
      sobrePrimariaContainer: Color.lerp(sobrePrimariaContainer, outra.sobrePrimariaContainer, t)!,
      sobreMarca: Color.lerp(sobreMarca, outra.sobreMarca, t)!,
      barraLateral: Color.lerp(barraLateral, outra.barraLateral, t)!,
      sobreBarraLateral: Color.lerp(sobreBarraLateral, outra.sobreBarraLateral, t)!,
    );
  }
}

extension PaletaDoContexto on BuildContext {
  Paleta get cores => Theme.of(this).extension<Paleta>() ?? Paleta.claro;
}
