import '../core/idioma.dart';

/// Categorías deportivas por edad (tenis / pádel base). La edad es la "deportiva": año actual menos año de
/// nacimiento (la que cumple el jugador el 31 de diciembre), como es habitual en las competiciones de base.
/// Para cambiar los tramos basta con editar esta lista.
const tramosCategoria = <(int, String)>[
  (8, 'Prebenjamín'),
  (10, 'Benjamín'),
  (12, 'Alevín'),
  (14, 'Infantil'),
  (16, 'Cadete'),
  (18, 'Júnior'),
];

int edadDeportiva(DateTime nacimiento, [DateTime? hoy]) =>
    (hoy ?? DateTime.now()).year - nacimiento.year;

/// Categoría que le corresponde por su fecha de nacimiento («Absoluta» a partir de los 19).
String _traducida(String es) => switch (es) {
  'Prebenjamín' => l10nActual.catPrebenjamin,
  'Benjamín' => l10nActual.catBenjamin,
  'Alevín' => l10nActual.catAlevin,
  'Infantil' => l10nActual.catInfantil,
  'Cadete' => l10nActual.catCadete,
  'Júnior' => l10nActual.catJunior,
  _ => es,
};

String categoriaPorEdad(DateTime nacimiento, [DateTime? hoy]) {
  final e = edadDeportiva(nacimiento, hoy);
  for (final (maxEdad, nombre) in tramosCategoria) {
    if (e <= maxEdad) return _traducida(nombre);
  }
  return l10nActual.catAbsoluta;
}

/// Categoría de edad de un equipo. Los tramos van por edad deportiva (año actual − año de nacimiento):
/// en 2026, Benjamín = nacidos en 2016 y después, Alevín = 2014–2015, Infantil = 2012–2013,
/// Cadete = 2010–2011, Júnior = 2008–2009, Absoluto = todas las edades, Veteranos = 35 años o más.
enum CategoriaEquipo {
  benjamin('BENJAMIN', null, 10),
  alevin('ALEVIN', 11, 12),
  infantil('INFANTIL', 13, 14),
  cadete('CADETE', 15, 16),
  junior('JUNIOR', 17, 18),
  absoluto('ABSOLUTO', null, null),
  veteranos('VETERANOS', 35, null);

  const CategoriaEquipo(this.codigo, this.edadMin, this.edadMax);

  /// Valor guardado en la BD (equipo.categoria).
  final String codigo;

  /// Edad deportiva mínima y máxima (null = sin límite).
  final int? edadMin, edadMax;

  static CategoriaEquipo? deCodigo(String? codigo) {
    for (final c in values) {
      if (c.codigo == codigo) return c;
    }
    return null;
  }

  String get nombre => switch (this) {
    benjamin => l10nActual.catBenjamin,
    alevin => l10nActual.catAlevin,
    infantil => l10nActual.catInfantil,
    cadete => l10nActual.catCadete,
    junior => l10nActual.catJunior,
    absoluto => l10nActual.catAbsoluta,
    veteranos => l10nActual.catVeteranos,
  };

  /// Primer y último año de nacimiento admitidos en la temporada de [hoy] (null = sin límite).
  (int?, int?) aniosNacimiento([DateTime? hoy]) {
    final y = (hoy ?? DateTime.now()).year;
    return (
      edadMax == null ? null : y - edadMax!,
      edadMin == null ? null : y - edadMin!,
    );
  }

  /// Texto con los años de nacimiento de la categoría, p. ej. «Nacidos en 2014–2015».
  String rotuloAnios([DateTime? hoy]) {
    final (desde, hasta) = aniosNacimiento(hoy);
    if (desde == null && hasta == null) return l10nActual.todasLasEdades;
    if (desde == null) return l10nActual.nacidosHasta(hasta!);
    if (hasta == null) return l10nActual.nacidosDesde(desde);
    return l10nActual.nacidosEntre(desde, hasta);
  }

  /// Si un jugador nacido en [nacimiento] puede jugar en esta categoría. Sin fecha de nacimiento solo
  /// cabe en Absoluto.
  bool admite(DateTime? nacimiento, [DateTime? hoy]) {
    if (edadMin == null && edadMax == null) return true;
    if (nacimiento == null) return false;
    final e = edadDeportiva(nacimiento, hoy);
    return (edadMin == null || e >= edadMin!) &&
        (edadMax == null || e <= edadMax!);
  }
}
