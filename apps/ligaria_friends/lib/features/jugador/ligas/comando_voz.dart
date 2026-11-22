/// Qué se ha dicho al tanteador: punto para un lado o deshacer el último.
sealed class ComandoVoz {
  const ComandoVoz();
}

class PuntoVoz extends ComandoVoz {
  const PuntoVoz(this.local);
  final bool local;
  @override
  String toString() => 'PuntoVoz(${local ? 'local' : 'visitante'})';
}

class DeshacerVoz extends ComandoVoz {
  const DeshacerVoz();
  @override
  String toString() => 'DeshacerVoz()';
}

/// Convierte lo que oye el reconocedor de voz en comandos del tanteador.
///
/// Vocabulario fijo, no frases libres: «punto para Martín», «Ana», «local», «visitante»,
/// «deshacer». Un lado se identifica por el nombre de sus jugadores (el de pareja es «A / B»).
/// Si un nombre aparece en los dos lados es ambiguo y no se reconoce: mejor ignorarlo que
/// puntuar al rival por error.
class InterpreteVoz {
  InterpreteVoz({required String local, required String visitante})
    : _local = _palabrasDe(local),
      _visitante = _palabrasDe(visitante) {
    final comunes = _local.intersection(_visitante);
    _local.removeAll(comunes);
    _visitante.removeAll(comunes);
  }

  final Set<String> _local, _visitante;

  static const _deshacer = {
    'deshacer',
    'deshaz',
    'corrige',
    'corregir',
    'atras',
    'undo',
    'anular',
    'anula',
  };
  static const _sueltas = {'local', 'locales'};
  static const _sueltasVisit = {'visitante', 'visitantes', 'rival', 'rivales'};
  static const _relleno = {
    'punto',
    'puntos',
    'para',
    'de',
    'del',
    'a',
    'el',
    'la',
    'los',
    'las',
    'y',
    'e',
  };

  /// Minúsculas, sin tildes ni signos.
  static String normalizar(String s) {
    const de = 'áàäâéèëêíìïîóòöôúùüûñç';
    const a = 'aaaaeeeeiiiioooouuuunc';
    final b = StringBuffer();
    for (final r in s.toLowerCase().runes) {
      final c = String.fromCharCode(r);
      final i = de.indexOf(c);
      b.write(i >= 0 ? a[i] : c);
    }
    return b.toString().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  }

  static Set<String> _palabrasDe(String nombre) => {
    for (final p in normalizar(nombre).split(RegExp(r'\s+')))
      if (p.length >= 3 && !_relleno.contains(p)) p,
  };

  /// Comandos dichos en [texto], en orden. Repetir el nombre de un lado sin decir «punto»
  /// entre medias («Martín López») cuenta una sola vez.
  List<ComandoVoz> interpretar(String texto) {
    final out = <ComandoVoz>[];
    bool?
    ultimoLado; // lado del último punto, hasta que se diga «punto» otra vez
    for (final p in normalizar(texto).split(RegExp(r'\s+'))) {
      if (p.isEmpty) continue;
      if (_deshacer.contains(p)) {
        out.add(const DeshacerVoz());
        ultimoLado = null;
        continue;
      }
      if (p == 'punto' || p == 'puntos') {
        ultimoLado = null;
        continue;
      }
      final bool? lado = _local.contains(p) || _sueltas.contains(p)
          ? true
          : _visitante.contains(p) || _sueltasVisit.contains(p)
          ? false
          : null;
      if (lado == null || lado == ultimoLado) continue;
      out.add(PuntoVoz(lado));
      ultimoLado = lado;
    }
    return out;
  }
}
