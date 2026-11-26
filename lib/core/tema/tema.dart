import 'package:material_ui/material_ui.dart';

import '../layout/medidas.dart';
import 'paleta.dart';

export 'paleta.dart';

abstract final class Raios {
  static const controle = BorderRadius.all(Radius.circular(8));
  static const cartao = BorderRadius.all(Radius.circular(12));
  static const pilula = BorderRadius.all(Radius.circular(999));
}

abstract final class Fontes {
  static const titulos = 'InterDisplay';
  static const texto = 'Inter';
  static const mono = 'SplineSansMono';
}

abstract final class Movimento {
  static const mudancaDeEstado = Duration(milliseconds: 120);
  static const curvaDeEntrada = Cubic(0.2, 0, 0, 1);

  static Duration duracao(BuildContext context, Duration padrao) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : padrao;
}

abstract final class Tema {
  static TextStyle? textoSecundario(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.cores.textoVariante);

  static TextStyle mono(BuildContext context, {Color? cor, double tamanho = 12, FontWeight peso = FontWeight.w500}) =>
      TextStyle(
        fontFamily: Fontes.mono,
        fontSize: tamanho,
        height: 16 / 12,
        fontWeight: peso,
        color: cor ?? context.cores.texto,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static ThemeData claro() => _construir(Paleta.claro, Brightness.light);

  static ThemeData escuro() => _construir(Paleta.escuro, Brightness.dark);

  static ThemeData _construir(Paleta cores, Brightness brilho) {
    final esquema = ColorScheme(
      brightness: brilho,
      primary: cores.primaria,
      onPrimary: cores.sobrePrimaria,
      primaryContainer: cores.primariaContainer,
      onPrimaryContainer: cores.sobrePrimariaContainer,
      secondary: cores.marca,
      onSecondary: cores.sobreMarca,
      secondaryContainer: cores.secundarioContainer,
      onSecondaryContainer: cores.sobreSecundarioContainer,
      tertiary: cores.marca,
      onTertiary: cores.sobreMarca,
      error: cores.erro,
      onError: cores.sobreForte,
      errorContainer: cores.erroContainer,
      onErrorContainer: cores.sobreErroContainer,
      surface: cores.superficieMaisBaixa,
      onSurface: cores.texto,
      onSurfaceVariant: cores.textoVariante,
      surfaceContainerLowest: cores.superficieMaisBaixa,
      surfaceContainerLow: cores.superficieBaixa,
      surfaceContainer: cores.superficie,
      surfaceContainerHigh: cores.superficieAlta,
      surfaceContainerHighest: cores.superficieAlta,
      outline: cores.contorno,
      outlineVariant: cores.contornoVariante,
    );
    final texto = _textos(cores);
    final bordaDoCampo = OutlineInputBorder(
      borderRadius: Raios.controle,
      borderSide: BorderSide(color: cores.bordaDoCampo),
    );
    return ThemeData(
      visualDensity: VisualDensity.standard,
      brightness: brilho,
      colorScheme: esquema,
      extensions: [cores],
      fontFamily: Fontes.texto,
      textTheme: texto,
      scaffoldBackgroundColor: cores.fundo,
      canvasColor: cores.fundo,
      dividerTheme: DividerThemeData(color: cores.bordaSuave, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cores.primaria,
          foregroundColor: cores.sobrePrimaria,
          minimumSize: const Size.square(Medidas.alturaDoControle),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: const RoundedRectangleBorder(borderRadius: Raios.controle),
          textStyle: texto.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cores.texto,
          backgroundColor: cores.superficieMaisBaixa,
          minimumSize: const Size.square(Medidas.alturaDoControle),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: BorderSide(color: cores.bordaDoCampo),
          shape: const RoundedRectangleBorder(borderRadius: Raios.controle),
          textStyle: texto.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cores.texto,
          minimumSize: const Size.square(Medidas.alturaDoControle),
          shape: const RoundedRectangleBorder(borderRadius: Raios.controle),
          textStyle: texto.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: cores.textoVariante,
          shape: const RoundedRectangleBorder(borderRadius: Raios.controle),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cores.superficieMaisBaixa,
        constraints: const BoxConstraints(minHeight: Medidas.alturaDoControle),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: bordaDoCampo,
        enabledBorder: bordaDoCampo,
        focusedBorder: OutlineInputBorder(
          borderRadius: Raios.controle,
          borderSide: BorderSide(color: cores.primaria, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Raios.controle,
          borderSide: BorderSide(color: cores.erro, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: Raios.controle,
          borderSide: BorderSide(color: cores.erro, width: 2),
        ),
        labelStyle: texto.bodyMedium?.copyWith(color: cores.textoVariante),
        hintStyle: texto.bodyMedium?.copyWith(color: cores.contorno),
        floatingLabelStyle: texto.bodyMedium?.copyWith(color: cores.primaria, fontWeight: FontWeight.w600),
        errorStyle: texto.bodySmall?.copyWith(color: cores.erro, fontWeight: FontWeight.w500),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cores.primaria,
        selectionColor: cores.marca.withValues(alpha: 0.3),
        selectionHandleColor: cores.marca,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: cores.primaria),
      popupMenuTheme: PopupMenuThemeData(
        color: cores.superficieMaisBaixa,
        elevation: 8,
        shadowColor: Colors.black38,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Raios.cartao,
          side: BorderSide(color: cores.borda),
        ),
        textStyle: texto.bodyMedium,
        labelTextStyle: WidgetStatePropertyAll(texto.bodyMedium),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(cores.superficieMaisBaixa),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: Raios.cartao,
              side: BorderSide(color: cores.borda),
            ),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cores.superficieMaisBaixa,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: Raios.cartao),
        titleTextStyle: texto.titleLarge,
        contentTextStyle: texto.bodyMedium?.copyWith(color: cores.textoVariante),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cores.primariaContainer,
        contentTextStyle: texto.bodyMedium?.copyWith(color: cores.sobrePrimariaContainer),
        actionTextColor: cores.marca,
        shape: const RoundedRectangleBorder(borderRadius: Raios.controle),
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cores.superficieMaisBaixa,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cores.secundarioContainer,
        elevation: 0,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            color: estados.contains(WidgetState.selected) ? cores.sobreSecundarioContainer : cores.textoVariante,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => texto.labelSmall?.copyWith(
            color: estados.contains(WidgetState.selected) ? cores.texto : cores.textoVariante,
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: cores.primariaContainer, borderRadius: Raios.controle),
        textStyle: texto.bodySmall?.copyWith(color: cores.sobrePrimariaContainer),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: cores.superficieMaisBaixa,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: Raios.cartao),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cores.superficieMaisBaixa,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _textos(Paleta cores) => TextTheme(
    displaySmall: TextStyle(
      fontFamily: Fontes.titulos,
      fontSize: 36,
      height: 42 / 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.75,
      color: cores.texto,
    ),
    headlineMedium: TextStyle(
      fontFamily: Fontes.titulos,
      fontSize: 28,
      height: 34 / 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: cores.texto,
    ),
    headlineSmall: TextStyle(
      fontFamily: Fontes.titulos,
      fontSize: 22,
      height: 28 / 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      color: cores.texto,
    ),
    titleLarge: TextStyle(
      fontFamily: Fontes.texto,
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: cores.texto,
    ),
    titleMedium: TextStyle(
      fontFamily: Fontes.texto,
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w600,
      color: cores.texto,
    ),
    titleSmall: TextStyle(
      fontFamily: Fontes.texto,
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w600,
      color: cores.texto,
    ),
    bodyLarge: TextStyle(fontFamily: Fontes.texto, fontSize: 15, height: 22 / 15, color: cores.texto),
    bodyMedium: TextStyle(fontFamily: Fontes.texto, fontSize: 14, height: 20 / 14, color: cores.texto),
    bodySmall: TextStyle(fontFamily: Fontes.texto, fontSize: 13, height: 18 / 13, color: cores.textoVariante),
    labelLarge: const TextStyle(fontFamily: Fontes.texto, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(
      fontFamily: Fontes.texto,
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: cores.textoVariante,
    ),
    labelSmall: TextStyle(
      fontFamily: Fontes.texto,
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: cores.textoVariante,
    ),
  );
}
