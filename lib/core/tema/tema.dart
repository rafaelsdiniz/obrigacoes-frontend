import 'package:material_ui/material_ui.dart';

abstract final class Cores {
  static const fundo = Color(0xFFF5F5F7);
  static const superficie = Color(0xFFFFFFFF);
  static const preenchimento = Color(0xFFEDEDF0);
  static const separador = Color(0xFFE4E4E9);
  static const texto = Color(0xFF1D1D1F);
  static const textoSecundario = Color(0xFF636368);
  static const grafite = Color(0xFF1F2A37);
  static const dourado = Color(0xFFF8A800);
  static const laranja = Color(0xFFF07800);
  static const douradoSuave = Color(0xFFFFF3D6);
  static const douradoTexto = Color(0xFF9A5B00);
  static const sucesso = Color(0xFF17703A);
  static const atencao = Color(0xFF8A5300);
  static const informacao = Color(0xFF2453C2);
  static const erro = Color(0xFFB42318);
  static const bordaDoCampo = Color(0xFF8A8A92);
  static const sobreposicao = Color(0x0A1D1D1F);
}

abstract final class Raios {
  static const pequeno = BorderRadius.all(Radius.circular(10));
  static const medio = BorderRadius.all(Radius.circular(14));
  static const grande = BorderRadius.all(Radius.circular(20));
}

abstract final class Tema {
  static const _fonte = 'Inter';
  static const _fonteDeTitulos = 'InterDisplay';

  static TextStyle? textoSecundario(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(color: Cores.textoSecundario);

  static ThemeData claro() {
    final cores = ColorScheme.fromSeed(seedColor: Cores.grafite).copyWith(
      primary: Cores.grafite,
      onPrimary: Colors.white,
      secondary: Cores.dourado,
      onSecondary: Cores.texto,
      tertiary: Cores.dourado,
      onTertiary: Cores.texto,
      surface: Cores.superficie,
      onSurface: Cores.texto,
      onSurfaceVariant: Cores.textoSecundario,
      surfaceContainerHighest: Cores.preenchimento,
      outline: Cores.textoSecundario,
      outlineVariant: Cores.separador,
      error: Cores.erro,
    );
    final texto = _textos();
    return ThemeData(
      colorScheme: cores,
      fontFamily: _fonte,
      textTheme: texto,
      scaffoldBackgroundColor: Cores.fundo,
      dividerTheme: const DividerThemeData(color: Cores.separador, thickness: 0.8, space: 0.8),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Cores.grafite,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: const StadiumBorder(),
          textStyle: texto.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Cores.grafite,
          minimumSize: const Size(48, 48),
          shape: const StadiumBorder(),
          textStyle: texto.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: Cores.textoSecundario)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Cores.fundo,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: const OutlineInputBorder(
          borderRadius: Raios.pequeno,
          borderSide: BorderSide(color: Cores.bordaDoCampo),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: Raios.pequeno,
          borderSide: BorderSide(color: Cores.bordaDoCampo),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: Raios.pequeno,
          borderSide: BorderSide(color: Cores.douradoTexto, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: Raios.pequeno,
          borderSide: BorderSide(color: Cores.erro, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: Raios.pequeno,
          borderSide: BorderSide(color: Cores.erro, width: 2),
        ),
        labelStyle: texto.bodyLarge?.copyWith(color: Cores.textoSecundario),
        hintStyle: texto.bodyLarge?.copyWith(color: Cores.textoSecundario),
        floatingLabelStyle: texto.bodyMedium?.copyWith(color: Cores.douradoTexto, fontWeight: FontWeight.w600),
        errorStyle: texto.bodySmall?.copyWith(color: Cores.erro),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Cores.laranja,
        selectionColor: Cores.douradoSuave,
        selectionHandleColor: Cores.dourado,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: Cores.dourado),
      popupMenuTheme: PopupMenuThemeData(
        color: Cores.superficie,
        elevation: 8,
        shadowColor: Colors.black26,
        shape: const RoundedRectangleBorder(borderRadius: Raios.medio),
        textStyle: texto.bodyMedium,
        labelTextStyle: WidgetStatePropertyAll(texto.bodyMedium),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Cores.superficie,
        shape: const RoundedRectangleBorder(borderRadius: Raios.grande),
        titleTextStyle: texto.titleLarge,
        contentTextStyle: texto.bodyMedium?.copyWith(color: Cores.textoSecundario),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Cores.texto,
        contentTextStyle: texto.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: Cores.dourado,
        shape: const RoundedRectangleBorder(borderRadius: Raios.medio),
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Cores.superficie,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Cores.grafite,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => texto.labelSmall?.copyWith(
            color: estados.contains(WidgetState.selected) ? Cores.texto : Cores.textoSecundario,
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(color: Cores.texto, borderRadius: Raios.pequeno),
        textStyle: texto.bodySmall?.copyWith(color: Colors.white),
      ),
    );
  }

  static TextTheme _textos() => const TextTheme(
    displaySmall: TextStyle(
      fontFamily: _fonteDeTitulos,
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      height: 1.1,
      color: Cores.texto,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fonteDeTitulos,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.15,
      color: Cores.texto,
    ),
    titleLarge: TextStyle(
      fontFamily: _fonte,
      fontSize: 19,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: Cores.texto,
    ),
    titleMedium: TextStyle(
      fontFamily: _fonte,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: Cores.texto,
    ),
    titleSmall: TextStyle(fontFamily: _fonte, fontSize: 14.5, fontWeight: FontWeight.w600, color: Cores.texto),
    bodyLarge: TextStyle(fontFamily: _fonte, fontSize: 16, color: Cores.texto, height: 1.4),
    bodyMedium: TextStyle(fontFamily: _fonte, fontSize: 14, color: Cores.texto, height: 1.4),
    bodySmall: TextStyle(fontFamily: _fonte, fontSize: 12.5, color: Cores.textoSecundario, height: 1.35),
    labelLarge: TextStyle(fontFamily: _fonte, fontSize: 14.5, fontWeight: FontWeight.w600, letterSpacing: -0.1),
    labelMedium: TextStyle(
      fontFamily: _fonte,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: Cores.textoSecundario,
    ),
    labelSmall: TextStyle(fontFamily: _fonte, fontSize: 12, fontWeight: FontWeight.w600, color: Cores.textoSecundario),
  );
}
