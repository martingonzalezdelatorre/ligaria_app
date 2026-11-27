import 'package:flutter/material.dart';

const acentoNaranja = Color(0xFFFF8A3D); // naranja

/// Anchos de referencia para el diseño adaptable.
class Pantalla {
  static const double compacta = 600;
  static const double media = 900;
  static const double contenidoMax = 1100;
  static bool esAncha(BuildContext c) => MediaQuery.sizeOf(c).width >= media;
}

/// Paleta "punch" (compartida con Socio+).
const tinta = Color(0xFF06110E);
const lima = Color(0xFFC6FF3D);
const menta = Color(0xFF14C79A);
const verdeMarca = Color(0xFF0E7C66);
const cristal = Color(0x0FFFFFFF); // blanco 6 %
const bordeCristal = Color(0x1FFFFFFF); // blanco 12 %
const superficieOscura = Color(0xFF101D19);

/// Tema único, oscuro, con lima eléctrico como color principal.
ThemeData _construir(Brightness _, Color acento) {
  final cs = ColorScheme.fromSeed(seedColor: lima, brightness: Brightness.dark)
      .copyWith(
        primary: lima,
        onPrimary: tinta,
        primaryContainer: const Color(0xFF2B3F10),
        onPrimaryContainer: lima,
        secondary: menta,
        onSecondary: tinta,
        tertiary: acento,
        onTertiary: tinta,
        surface: tinta,
        onSurface: Colors.white,
        onSurfaceVariant: const Color(0xFFD3E0DA),
        outline: const Color(0xFF3F524A),
        outlineVariant: const Color(0xFF26372F),
        surfaceContainerLowest: tinta,
        surfaceContainerLow: const Color(0xFF0C1814),
        surfaceContainer: superficieOscura,
        surfaceContainerHigh: const Color(0xFF16261F),
        surfaceContainerHighest: const Color(0xFF1C2F27),
      );

  final base = ThemeData(useMaterial3: true, colorScheme: cs);
  final t = base.textTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );
  final tt = t.copyWith(
    displaySmall: t.displaySmall?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -1.5,
    ),
    headlineMedium: t.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
    ),
    headlineSmall: t.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -.8,
    ),
    titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w700),
  );
  const borde = bordeCristal;
  RoundedRectangleBorder redondo(double r) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
  OutlineInputBorder campo(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c, width: w),
  );

  return base.copyWith(
    scaffoldBackgroundColor: tinta,
    textTheme: tt,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: tt.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -.5,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: cristal,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borde),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: lima,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: lima.withValues(alpha: .35), blurRadius: 12),
        ],
      ),
      labelColor: tinta,
      unselectedLabelColor: Colors.white70,
      labelStyle: tt.labelLarge,
      splashBorderRadius: BorderRadius.circular(999),
      labelPadding: const EdgeInsets.symmetric(horizontal: 18),
      overlayColor: WidgetStatePropertyAll(lima.withValues(alpha: .08)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cristal,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: campo(borde),
      enabledBorder: campo(borde),
      focusedBorder: campo(lima, 1.5),
      errorBorder: campo(cs.error),
      focusedErrorBorder: campo(cs.error, 2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: lima,
        foregroundColor: tinta,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: redondo(16),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lima,
        foregroundColor: tinta,
        minimumSize: const Size(64, 48),
        shape: redondo(16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lima,
        side: BorderSide(color: lima.withValues(alpha: .6)),
        minimumSize: const Size(64, 48),
        shape: redondo(16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: lima, shape: redondo(12)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lima,
      foregroundColor: tinta,
      shape: redondo(16),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: const StadiumBorder(),
      side: BorderSide(color: lima.withValues(alpha: .4)),
      backgroundColor: lima.withValues(alpha: .12),
      labelStyle: const TextStyle(
        color: lima,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
    listTileTheme: ListTileThemeData(shape: redondo(16), iconColor: lima),
    dialogTheme: DialogThemeData(
      backgroundColor: superficieOscura,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: borde),
      ),
      constraints: const BoxConstraints(minWidth: 400, maxWidth: 560),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: superficieOscura,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: lima,
      contentTextStyle: const TextStyle(
        color: tinta,
        fontWeight: FontWeight.w700,
      ),
      shape: redondo(16),
      insetPadding: const EdgeInsets.all(12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tinta.withValues(alpha: .85),
      surfaceTintColor: Colors.transparent,
      indicatorColor: lima,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? tinta : Colors.white70,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: s.contains(WidgetState.selected) ? lima : Colors.white70,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: tinta.withValues(alpha: .6),
      indicatorColor: lima,
      selectedIconTheme: const IconThemeData(color: tinta),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      selectedLabelTextStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        color: lima,
      ),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: superficieOscura,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: lima),
    dividerTheme: const DividerThemeData(color: borde, space: 1, thickness: 1),
    extensions: [Marca(acento: acento, borde: borde, superficie: cristal)],
  );
}

/// Colores de marca adicionales: `Theme.of(context).extension<Marca>()!`.
class Marca extends ThemeExtension<Marca> {
  const Marca({
    required this.acento,
    required this.borde,
    required this.superficie,
  });
  final Color acento, borde, superficie;
  static Marca de(BuildContext c) =>
      Theme.of(c).extension<Marca>() ??
      const Marca(
        acento: acentoNaranja,
        borde: bordeCristal,
        superficie: cristal,
      );
  @override
  Marca copyWith({Color? acento, Color? borde, Color? superficie}) => Marca(
    acento: acento ?? this.acento,
    borde: borde ?? this.borde,
    superficie: superficie ?? this.superficie,
  );
  @override
  Marca lerp(Marca? other, double t) => other == null
      ? this
      : Marca(
          acento: Color.lerp(acento, other.acento, t)!,
          borde: Color.lerp(borde, other.borde, t)!,
          superficie: Color.lerp(superficie, other.superficie, t)!,
        );
}

/// Paleta clara "Salvia": pensada para cansar poco la vista. Fondo gris-verdoso muy suave
/// (no blanco puro), texto gris pizarra (no negro) y un verde salvia poco saturado como principal.
/// La salvia clara es el acento (logo, tarjeta destacada, degradados) y la arena da el toque cálido.
/// En oscuro el acento sigue siendo la lima de siempre.
const acentoClaro = Color(0xFF86CFA6); // salvia clara
const acentoClaroSuave = Color(0xFFD5F0E0); // salvia muy pálida
const arenaClaro = Color(0xFFE9D3A8); // arena: toque cálido
const arenaClaroSuave = Color(0xFFF3E3C8);

/// Acento destacado según el modo: lima en oscuro, salvia clara en claro.
Color acentoDe(BuildContext c) =>
    Theme.of(c).brightness == Brightness.light ? acentoClaro : lima;

/// Segundo tono del degradado de acento: menta en oscuro, salvia muy pálida en claro.
Color acentoSuaveDe(BuildContext c) =>
    Theme.of(c).brightness == Brightness.light ? acentoClaroSuave : menta;

const primarioClaro = Color(0xFF2E7A5C); // verde salvia: botones, pestañas, iconos activos
const fondoClaro = Color(0xFFF4F6F2);
const superficieClara = Color(0xFFFFFFFF);
const tintaClara = Color(0xFF2B3532); // texto principal: gris pizarra, no negro
const textoSecundarioClaro = Color(0xFF66716D);
const bordeClaro = Color(0xFFE1E6E1);

ThemeData _construirClaro(Color acento) {
  final cs =
      ColorScheme.fromSeed(
        seedColor: primarioClaro,
        brightness: Brightness.light,
      ).copyWith(
        primary: primarioClaro,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFD2EEDD),
        onPrimaryContainer: const Color(0xFF14412F),
        secondary: const Color(0xFF8A6D3B),
        onSecondary: Colors.white,
        secondaryContainer: arenaClaroSuave,
        onSecondaryContainer: const Color(0xFF5C4317),
        tertiary: acento,
        onTertiary: tintaClara,
        surface: fondoClaro,
        onSurface: tintaClara,
        onSurfaceVariant: textoSecundarioClaro,
        outline: const Color(0xFFC5CEC8),
        outlineVariant: bordeClaro,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFFAFBF9),
        surfaceContainer: Colors.white,
        surfaceContainerHigh: const Color(0xFFEDF1EC),
        surfaceContainerHighest: const Color(0xFFE5EBE6),
      );

  final base = ThemeData(useMaterial3: true, colorScheme: cs);
  final t = base.textTheme.apply(bodyColor: tintaClara, displayColor: tintaClara);
  final tt = t.copyWith(
    displaySmall: t.displaySmall?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -1.5,
    ),
    headlineMedium: t.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
    ),
    headlineSmall: t.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -.8,
    ),
    titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w700),
  );
  const borde = bordeClaro;
  RoundedRectangleBorder redondo(double r) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
  OutlineInputBorder campo(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c, width: w),
  );

  return base.copyWith(
    scaffoldBackgroundColor: fondoClaro,
    textTheme: tt,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: tintaClara,
      iconTheme: const IconThemeData(color: tintaClara),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: tt.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -.5,
        color: tintaClara,
      ),
    ),
    cardTheme: CardThemeData(
      color: superficieClara,
      surfaceTintColor: Colors.transparent,
      shadowColor: tintaClara.withValues(alpha: .06),
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borde),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    iconTheme: const IconThemeData(color: tintaClara),
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: primarioClaro,
        borderRadius: BorderRadius.circular(999),
      ),
      labelColor: Colors.white,
      unselectedLabelColor: cs.onSurfaceVariant,
      labelStyle: tt.labelLarge,
      splashBorderRadius: BorderRadius.circular(999),
      labelPadding: const EdgeInsets.symmetric(horizontal: 18),
      overlayColor: WidgetStatePropertyAll(
        primarioClaro.withValues(alpha: .08),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: campo(borde),
      enabledBorder: campo(borde),
      focusedBorder: campo(primarioClaro, 1.5),
      errorBorder: campo(cs.error),
      focusedErrorBorder: campo(cs.error, 2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primarioClaro,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: redondo(16),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primarioClaro,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        shape: redondo(16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primarioClaro,
        side: BorderSide(color: primarioClaro.withValues(alpha: .5)),
        minimumSize: const Size(64, 48),
        shape: redondo(16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primarioClaro,
        shape: redondo(12),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primarioClaro,
      foregroundColor: Colors.white,
      shape: redondo(16),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: const StadiumBorder(),
      side: BorderSide(color: primarioClaro.withValues(alpha: .25)),
      backgroundColor: primarioClaro.withValues(alpha: .08),
      labelStyle: const TextStyle(
        color: primarioClaro,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: redondo(16),
      iconColor: primarioClaro,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: borde),
      ),
      constraints: const BoxConstraints(minWidth: 400, maxWidth: 560),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: tintaClara,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: tintaClara,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      actionTextColor: acentoClaro,
      shape: redondo(16),
      insetPadding: const EdgeInsets.all(12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withValues(alpha: .92),
      surfaceTintColor: Colors.transparent,
      indicatorColor: cs.primaryContainer,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? primarioClaro
              : cs.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: s.contains(WidgetState.selected)
              ? primarioClaro
              : cs.onSurfaceVariant,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.white.withValues(alpha: .7),
      indicatorColor: cs.primaryContainer,
      selectedIconTheme: const IconThemeData(color: primarioClaro),
      unselectedIconTheme: IconThemeData(color: cs.onSurfaceVariant),
      selectedLabelTextStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        color: primarioClaro,
      ),
      unselectedLabelTextStyle: TextStyle(color: cs.onSurfaceVariant),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primarioClaro,
    ),
    dividerTheme: const DividerThemeData(color: borde, space: 1, thickness: 1),
    extensions: [
      Marca(acento: acento, borde: borde, superficie: superficieClara),
    ],
  );
}

/// [acento] diferencia cada app (ligariaia: naranja, friends: otro) sin cambiar la base.
///
/// `temaOscuro` es la estética original "punch" (tinta + lima); `temaClaro` la variante clara.
/// Para volver atrás basta con usar `ThemeMode.dark` (o la etiqueta git `tema-oscuro-lima-v1`).
ThemeData temaClaro({Color acento = acentoNaranja}) => _construirClaro(acento);
ThemeData temaOscuro({Color acento = acentoNaranja}) =>
    _construir(Brightness.dark, acento);
