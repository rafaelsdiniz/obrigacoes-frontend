import 'package:material_ui/material_ui.dart';

abstract final class Tema {
  static const _grafite = Color(0xFF1F2A37);
  static const _dourado = Color(0xFFF8A800);

  static ThemeData claro() {
    final cores = ColorScheme.fromSeed(seedColor: _grafite, tertiary: _dourado);
    return ThemeData(
      colorScheme: cores,
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: cores.outlineVariant),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}
