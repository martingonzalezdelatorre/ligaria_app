import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _semilla = Color(0xFF1B8A4B); // verde pista
const _acento = Color(0xFFF2B705); // amarillo pelota

/// Anchos de referencia para el diseño adaptable.
class Pantalla {
  static const double compacta = 600;
  static const double media = 900;
  static const double contenidoMax = 1100;
  static bool esAncha(BuildContext c) => MediaQuery.sizeOf(c).width >= media;
}

ThemeData _construir(Brightness brillo) {
  final oscuro = brillo == Brightness.dark;
  final cs = ColorScheme.fromSeed(seedColor: _semilla, brightness: brillo).copyWith(
      primary: oscuro ? null : const Color(0xFF1B9A55), onPrimary: oscuro ? null : Colors.white);
  final fondo = oscuro ? const Color(0xFF0F1512) : const Color(0xFFF5FBF7);
  final superficie = oscuro ? const Color(0xFF18201C) : Colors.white;
  final borde = oscuro ? const Color(0xFF2A3630) : const Color(0xFFE2E8E4);

  final base = Typography.material2021(platform: TargetPlatform.android);
  final texto = (oscuro ? base.white : base.black).apply(bodyColor: cs.onSurface, displayColor: cs.onSurface);
  final tt = texto.copyWith(
    headlineMedium: texto.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.5),
    titleLarge: texto.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -.2),
    titleMedium: texto.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    labelLarge: texto.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );

  OutlineInputBorder campo(Color c, [double w = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: w));
  RoundedRectangleBorder redondo(double r) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: fondo,
    textTheme: tt,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: fondo,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: tt.titleLarge?.copyWith(color: cs.onSurface),
    ),
    cardTheme: CardThemeData(
      color: superficie,
      surfaceTintColor: Colors.transparent,
      elevation: oscuro ? 0 : 2,
      shadowColor: const Color(0xFF0B3D22).withValues(alpha: .12),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), side: BorderSide(color: borde.withValues(alpha: oscuro ? 1 : .6))),
      clipBehavior: Clip.antiAlias,
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primary, oscuro ? cs.primary : const Color(0xFF2DB36B)]),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: .35), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      labelColor: cs.onPrimary,
      unselectedLabelColor: cs.onSurfaceVariant,
      labelStyle: tt.labelLarge,
      splashBorderRadius: BorderRadius.circular(999),
      labelPadding: const EdgeInsets.symmetric(horizontal: 18),
      overlayColor: WidgetStatePropertyAll(cs.primary.withValues(alpha: .08)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: superficie,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: campo(borde),
      enabledBorder: campo(borde),
      focusedBorder: campo(cs.primary, 2),
      errorBorder: campo(cs.error),
      focusedErrorBorder: campo(cs.error, 2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: redondo(14),
        textStyle: tt.labelLarge,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(minimumSize: const Size(64, 50), shape: redondo(14)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(64, 50), side: BorderSide(color: borde), shape: redondo(14)),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: redondo(12))),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      shape: redondo(18),
    ),
    chipTheme: ChipThemeData(side: BorderSide(color: borde), shape: redondo(999), backgroundColor: superficie),
    listTileTheme: ListTileThemeData(shape: redondo(12)),
    dialogTheme: DialogThemeData(backgroundColor: superficie, surfaceTintColor: Colors.transparent, shape: redondo(24)),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: superficie,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: redondo(14), insetPadding: const EdgeInsets.all(12)),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: superficie,
      indicatorColor: cs.primaryContainer,
      indicatorShape: redondo(14),
      selectedLabelTextStyle: tt.labelMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: superficie,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(24))),
    ),
    dividerTheme: DividerThemeData(color: borde, space: 1, thickness: 1),
    extensions: [Marca(acento: _acento, borde: borde, superficie: superficie)],
  );
}

/// Colores de marca adicionales: `Theme.of(context).extension<Marca>()!`.
class Marca extends ThemeExtension<Marca> {
  const Marca({required this.acento, required this.borde, required this.superficie});
  final Color acento, borde, superficie;
  static Marca de(BuildContext c) =>
      Theme.of(c).extension<Marca>() ?? const Marca(acento: _acento, borde: Color(0xFFE2E8E4), superficie: Colors.white);
  @override
  Marca copyWith({Color? acento, Color? borde, Color? superficie}) =>
      Marca(acento: acento ?? this.acento, borde: borde ?? this.borde, superficie: superficie ?? this.superficie);
  @override
  Marca lerp(Marca? other, double t) => other == null
      ? this
      : Marca(
          acento: Color.lerp(acento, other.acento, t)!,
          borde: Color.lerp(borde, other.borde, t)!,
          superficie: Color.lerp(superficie, other.superficie, t)!);
}

ThemeData temaClaro() => _construir(Brightness.light);
ThemeData temaOscuro() => _construir(Brightness.dark);

/// Modo de tema (sistema / claro / oscuro), persistido localmente.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _clave = 'theme_mode';

  @override
  ThemeMode build() {
    _cargar();
    return ThemeMode.light;
  }

  Future<void> _cargar() async {
    try {
      final v = (await SharedPreferences.getInstance()).getString(_clave);
      final m = ThemeMode.values.where((e) => e.name == v);
      if (m.isNotEmpty) state = m.first;
    } catch (_) {}
  }

  Future<void> set(ThemeMode modo) async {
    state = modo;
    try {
      await (await SharedPreferences.getInstance()).setString(_clave, modo.name);
    } catch (_) {}
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
