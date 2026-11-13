import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modo de tema (sistema / claro / oscuro), persistido localmente.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _clave = 'theme_mode';

  @override
  ThemeMode build() {
    _cargar();
    return ThemeMode.dark;
  }

  Future<void> _cargar() async {}

  Future<void> set(ThemeMode modo) async {
    state = modo;
    try {
      await (await SharedPreferences.getInstance()).setString(_clave, modo.name);
    } catch (_) {}
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
