import '../../core/idioma.dart';

/// Plantilla para crear una liga en un clic: rellena nombre, formato y fechas; el resto del
/// formulario (deporte, tipo, puntuación…) sigue siendo editable.
class PlantillaLiga {
  const PlantillaLiga({
    required this.id,
    required this.formato,
    required this.nombre,
    required this.descripcion,
    required this.fechas,
  });

  final String id;

  /// LIGA | ELIMINATORIA | MIXTO
  final String formato;
  final String Function(AppL10n l, int anio) nombre;
  final String Function(AppL10n l) descripcion;

  /// Inicio y fin propuestos a partir de [hoy]: la próxima vez que toca esa temporada.
  final (DateTime, DateTime) Function(DateTime hoy) fechas;
}

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Temporada que va de (mesIni/diaIni) a (mesFin/diaFin) del mismo año. Si hoy cae dentro, empieza hoy;
/// si ya terminó este año, se propone la del año siguiente.
(DateTime, DateTime) temporada(DateTime hoy, (int, int) ini, (int, int) fin) {
  final h = _dia(hoy);
  var anio = h.year;
  var fFin = DateTime(anio, fin.$1, fin.$2);
  if (fFin.isBefore(h)) {
    anio++;
    fFin = DateTime(anio, fin.$1, fin.$2);
  }
  final fIni = DateTime(anio, ini.$1, ini.$2);
  return (fIni.isBefore(h) ? h : fIni, fFin);
}

/// Próximo sábado (nunca hoy) y el domingo siguiente.
(DateTime, DateTime) proximoFinDeSemana(DateTime hoy) {
  final h = _dia(hoy);
  var dias = (DateTime.saturday - h.weekday) % 7;
  if (dias == 0) dias = 7;
  final sab = h.add(Duration(days: dias));
  return (sab, sab.add(const Duration(days: 1)));
}

final plantillasLiga = <PlantillaLiga>[
  PlantillaLiga(
    id: 'otono',
    formato: 'LIGA',
    nombre: (l, a) => l.plantillaNombreOtono(a),
    descripcion: (l) => l.plantillaDescOtono,
    fechas: (hoy) => temporada(hoy, (9, 15), (12, 15)),
  ),
  PlantillaLiga(
    id: 'primavera',
    formato: 'LIGA',
    nombre: (l, a) => l.plantillaNombrePrimavera(a),
    descripcion: (l) => l.plantillaDescPrimavera,
    fechas: (hoy) => temporada(hoy, (3, 1), (6, 15)),
  ),
  PlantillaLiga(
    id: 'torneo',
    formato: 'ELIMINATORIA',
    nombre: (l, a) => l.plantillaNombreTorneo(a),
    descripcion: (l) => l.plantillaDescTorneo,
    fechas: proximoFinDeSemana,
  ),
  PlantillaLiga(
    id: 'grupos',
    formato: 'MIXTO',
    nombre: (l, a) => l.plantillaNombreGrupos(a),
    descripcion: (l) => l.plantillaDescGrupos,
    fechas: (hoy) => temporada(hoy, (4, 1), (6, 30)),
  ),
];
