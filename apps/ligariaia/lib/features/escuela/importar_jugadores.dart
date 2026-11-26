import '../../data/models.dart';

/// Por qué una fila de la lista importada no se puede dar de alta.
enum MotivoFila { sinNombre, fechaInvalida, correoInvalido, repetida, existe }

/// Una fila de la lista de jugadores pegada o cargada desde Excel/CSV.
class FilaImport {
  const FilaImport({
    required this.linea,
    required this.nombre,
    required this.apellidos,
    required this.fecha,
    this.tutor = '',
    this.correo = '',
    this.parentesco = '',
    this.telefono = '',
    this.motivo,
  });

  /// Número de fila en la lista original (la primera fila de datos es la 1; con cabecera, la 2).
  final int linea;
  final String nombre, apellidos, tutor, correo, parentesco, telefono;
  final DateTime? fecha;
  final MotivoFila? motivo;

  bool get valida => motivo == null;

  /// Solo se asocia un tutor si se dio su correo (es lo que identifica la invitación).
  bool get conTutor => correo.isNotEmpty;

  String get nombreCompleto => '$nombre $apellidos'.trim();
}

/// Primera fila de ejemplo para que la escuela la copie y la rellene en Excel.
const modeloImportacion =
    'Nombre;Apellidos;Fecha de nacimiento;Tutor;Correo del tutor\n'
    'Ana;López Ruiz;05/03/2015;María Ruiz;maria@ejemplo.com';

String _norm(String s) {
  const de = 'áàäâéèëêíìïîóòöôúùüûñÁÀÄÂÉÈËÊÍÌÏÎÓÒÖÔÚÙÜÛÑ';
  const a = 'aaaaeeeeiiiioooouuuunAAAAEEEEIIIIOOOOUUUUN';
  final b = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    final c = String.fromCharCode(r);
    final i = de.indexOf(c);
    b.write(i >= 0 ? a[i].toLowerCase() : c);
  }
  return b.toString().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

enum _Col { nombre, apellidos, fecha, tutor, correo, parentesco, telefono }

const _sinonimos = <String, _Col>{
  'nombre': _Col.nombre,
  'name': _Col.nombre,
  'nombrejugador': _Col.nombre,
  'jugador': _Col.nombre,
  'alumno': _Col.nombre,
  'apellidos': _Col.apellidos,
  'apellido': _Col.apellidos,
  'surname': _Col.apellidos,
  'lastname': _Col.apellidos,
  'fechadenacimiento': _Col.fecha,
  'fechanacimiento': _Col.fecha,
  'nacimiento': _Col.fecha,
  'fnacimiento': _Col.fecha,
  'fecha': _Col.fecha,
  'birthdate': _Col.fecha,
  'tutor': _Col.tutor,
  'nombretutor': _Col.tutor,
  'nombredeltutor': _Col.tutor,
  'padremadre': _Col.tutor,
  'padreomadre': _Col.tutor,
  'responsable': _Col.tutor,
  'familiar': _Col.tutor,
  'correo': _Col.correo,
  'correotutor': _Col.correo,
  'correodeltutor': _Col.correo,
  'correoelectronico': _Col.correo,
  'email': _Col.correo,
  'emailtutor': _Col.correo,
  'emaildeltutor': _Col.correo,
  'mail': _Col.correo,
  'parentesco': _Col.parentesco,
  'telefono': _Col.telefono,
  'telefonotutor': _Col.telefono,
  'tel': _Col.telefono,
  'movil': _Col.telefono,
};

const _orden = [
  _Col.nombre,
  _Col.apellidos,
  _Col.fecha,
  _Col.tutor,
  _Col.correo,
  _Col.parentesco,
  _Col.telefono,
];

/// Convierte texto de Excel (celdas separadas por tabulador) o de un CSV (`;` o `,`) en filas de celdas.
/// Respeta las comillas dobles (con `""` como comilla literal) y los saltos de línea dentro de ellas.
List<List<String>> tablaDeTexto(String texto) {
  var t = texto.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  if (t.startsWith('﻿')) t = t.substring(1);
  final primera = t
      .split('\n')
      .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
  final tabs = '\t'.allMatches(primera).length;
  final puntoComa = ';'.allMatches(primera).length;
  final comas = ','.allMatches(primera).length;
  final sep = tabs > 0
      ? '\t'
      : (puntoComa >= comas && puntoComa > 0 ? ';' : ',');

  final filas = <List<String>>[];
  var fila = <String>[];
  final celda = StringBuffer();
  var comillas = false;
  void cerrarCelda() {
    fila.add(celda.toString().trim());
    celda.clear();
  }

  void cerrarFila() {
    cerrarCelda();
    if (fila.any((c) => c.isNotEmpty)) filas.add(fila);
    fila = <String>[];
  }

  for (var i = 0; i < t.length; i++) {
    final c = t[i];
    if (comillas) {
      if (c == '"') {
        if (i + 1 < t.length && t[i + 1] == '"') {
          celda.write('"');
          i++;
        } else {
          comillas = false;
        }
      } else {
        celda.write(c);
      }
    } else if (c == '"' && celda.isEmpty) {
      comillas = true;
    } else if (c == sep) {
      cerrarCelda();
    } else if (c == '\n') {
      cerrarFila();
    } else {
      celda.write(c);
    }
  }
  if (celda.isNotEmpty || fila.isNotEmpty) cerrarFila();
  return filas;
}

/// Fecha en `dd/mm/aaaa`, `dd-mm-aaaa`, `dd.mm.aaaa`, `aaaa-mm-dd` o número de serie de Excel.
DateTime? fechaFlexible(String texto, {DateTime? hoy}) {
  final t = texto.trim();
  if (t.isEmpty) return null;
  DateTime? f;
  var m = RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})$').firstMatch(t);
  if (m != null) {
    f = _fechaValida(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!));
  } else {
    m = RegExp(r'^(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})$').firstMatch(t);
    if (m != null) {
      f = _fechaValida(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    } else if (RegExp(r'^\d{5}$').hasMatch(t)) {
      // Fecha pegada como número desde Excel: días desde el 30/12/1899.
      final n = int.parse(t);
      if (n >= 10000 && n <= 80000) {
        final d = DateTime.utc(1899, 12, 30).add(Duration(days: n));
        f = DateTime(d.year, d.month, d.day);
      }
    }
  }
  if (f == null) return null;
  final ahora = hoy ?? DateTime.now();
  final limite = DateTime(ahora.year, ahora.month, ahora.day);
  if (f.isAfter(limite) || f.year < 1920) return null;
  return f;
}

DateTime? _fechaValida(int a, int m, int d) {
  final f = DateTime(a, m, d);
  return (f.year == a && f.month == m && f.day == d) ? f : null;
}

final _reCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Madre / Padre / Tutor legal / Otro familiar si se reconoce; si no, el texto tal cual.
String parentescoCanonico(String t) {
  final n = _norm(t);
  if (n.isEmpty) return '';
  if (n.startsWith('madre') || n == 'mama') return 'Madre';
  if (n.startsWith('padre') || n == 'papa') return 'Padre';
  if (n.startsWith('tutor')) return 'Tutor legal';
  if (n.startsWith('otro')) return 'Otro familiar';
  return t.trim();
}

String _clave(String nombre, String apellidos, DateTime? f) =>
    '${_norm(nombre)}|${_norm(apellidos)}|${f == null ? '' : '${f.year}-${f.month}-${f.day}'}';

/// Lee la lista y valida cada fila. [existentes] son los jugadores que la escuela ya tiene: se marcan
/// como `existe` para no duplicarlos si se vuelve a importar el mismo archivo.
List<FilaImport> leerJugadores(
  String texto, {
  Iterable<JugadorLite> existentes = const [],
  DateTime? hoy,
}) {
  final filas = tablaDeTexto(texto);
  if (filas.isEmpty) return const [];

  // ¿La primera fila es una cabecera? Debe reconocerse «nombre» y al menos otra columna.
  final cab = [for (final c in filas.first) _sinonimos[_norm(c)]];
  final hayCabecera =
      cab.contains(_Col.nombre) && cab.whereType<_Col>().length >= 2;
  final columnas = hayCabecera ? cab : _orden;
  final datos = hayCabecera ? filas.skip(1) : filas;
  final offset = hayCabecera ? 2 : 1;

  final vistos = <String>{
    for (final e in existentes)
      _clave(e.nombre, e.apellidos, e.fechaNacimiento),
  };
  final salida = <FilaImport>[];
  var n = 0;
  for (final f in datos) {
    String v(_Col c) {
      final i = columnas.indexOf(c);
      return (i >= 0 && i < f.length) ? f[i].trim() : '';
    }

    final nombre = v(_Col.nombre);
    final apellidos = v(_Col.apellidos);
    final fecha = fechaFlexible(v(_Col.fecha), hoy: hoy);
    final correo = v(_Col.correo).toLowerCase();
    MotivoFila? motivo;
    if (nombre.isEmpty) {
      motivo = MotivoFila.sinNombre;
    } else if (fecha == null) {
      motivo = MotivoFila.fechaInvalida;
    } else if (correo.isNotEmpty && !_reCorreo.hasMatch(correo)) {
      motivo = MotivoFila.correoInvalido;
    } else {
      final k = _clave(nombre, apellidos, fecha);
      if (!vistos.add(k)) {
        motivo =
            salida.any(
              (x) => x.valida && _clave(x.nombre, x.apellidos, x.fecha) == k,
            )
            ? MotivoFila.repetida
            : MotivoFila.existe;
      }
    }
    salida.add(
      FilaImport(
        linea: offset + n++,
        nombre: nombre,
        apellidos: apellidos,
        fecha: fecha,
        tutor: v(_Col.tutor),
        correo: correo,
        parentesco: parentescoCanonico(v(_Col.parentesco)),
        telefono: v(_Col.telefono),
        motivo: motivo,
      ),
    );
  }
  return salida;
}
