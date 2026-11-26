import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ArmazenamentoDoTema {
  Future<ThemeMode> ler();

  Future<void> salvar(ThemeMode modo);
}

class ArmazenamentoDoTemaLocal implements ArmazenamentoDoTema {
  static const _chave = 'tema';

  @override
  Future<ThemeMode> ler() async {
    try {
      final salvo = await SharedPreferencesAsync().getString(_chave);
      return ThemeMode.values.firstWhere((modo) => modo.name == salvo, orElse: () => ThemeMode.system);
    } on Exception {
      return ThemeMode.system;
    }
  }

  @override
  Future<void> salvar(ThemeMode modo) async {
    try {
      await SharedPreferencesAsync().setString(_chave, modo.name);
    } on Exception {
      return;
    }
  }
}

final armazenamentoDoTemaProvider = Provider<ArmazenamentoDoTema>((ref) => ArmazenamentoDoTemaLocal());

final temaInicialProvider = Provider<ThemeMode>((ref) => ThemeMode.system);

final temaProvider = NotifierProvider<ControleDoTema, ThemeMode>(ControleDoTema.new);

class ControleDoTema extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(temaInicialProvider);

  Future<void> alternar(Brightness atual) async {
    state = atual == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    await ref.read(armazenamentoDoTemaProvider).salvar(state);
  }
}
