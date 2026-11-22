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
