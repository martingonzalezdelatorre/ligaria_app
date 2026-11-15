/// Marcador de un partido de tenis o pádel, punto a punto. Inmutable: cada punto devuelve un estado nuevo.
class Tanteo {
  const Tanteo({
    required this.setsParaGanar,
    this.puntoDeOro = false,
    this.sets = const [],
    this.juegosL = 0,
    this.juegosV = 0,
    this.puntosL = 0,
    this.puntosV = 0,
  });

  final int setsParaGanar;

  /// Pádel: en el 40-40 el siguiente punto decide el juego.
  final bool puntoDeOro;

  /// Sets ya cerrados: [juegosLocal, juegosVisitante].
  final List<List<int>> sets;
  final int juegosL, juegosV, puntosL, puntosV;

  Map<String, dynamic> toJson() => {
    'setsParaGanar': setsParaGanar,
    'puntoDeOro': puntoDeOro,
    'sets': sets,
    'juegosL': juegosL,
    'juegosV': juegosV,
    'puntosL': puntosL,
    'puntosV': puntosV,
  };

  factory Tanteo.fromJson(Map<String, dynamic> j) => Tanteo(
    setsParaGanar: (j['setsParaGanar'] as num).toInt(),
    puntoDeOro: j['puntoDeOro'] as bool? ?? false,
    sets: [
      for (final s in (j['sets'] as List? ?? const []))
        [for (final x in (s as List)) (x as num).toInt()],
    ],
    juegosL: (j['juegosL'] as num? ?? 0).toInt(),
    juegosV: (j['juegosV'] as num? ?? 0).toInt(),
    puntosL: (j['puntosL'] as num? ?? 0).toInt(),
    puntosV: (j['puntosV'] as num? ?? 0).toInt(),
  );

  bool get desempate => juegosL == 6 && juegosV == 6;
  int get setsL => sets.where((s) => s[0] > s[1]).length;
  int get setsV => sets.where((s) => s[1] > s[0]).length;
  bool get terminado => setsL == setsParaGanar || setsV == setsParaGanar;
  bool get ganaLocal => setsL > setsV;

  Tanteo copiar({
    List<List<int>>? sets,
    int? juegosL,
    int? juegosV,
    int? puntosL,
    int? puntosV,
    bool? puntoDeOro,
  }) => Tanteo(
    setsParaGanar: setsParaGanar,
    puntoDeOro: puntoDeOro ?? this.puntoDeOro,
    sets: sets ?? this.sets,
    juegosL: juegosL ?? this.juegosL,
    juegosV: juegosV ?? this.juegosV,
    puntosL: puntosL ?? this.puntosL,
    puntosV: puntosV ?? this.puntosV,
  );

  /// Punto para el local (`true`) o el visitante (`false`).
  Tanteo punto(bool local) {
    if (terminado) return this;
    final pl = puntosL + (local ? 1 : 0);
    final pv = puntosV + (local ? 0 : 1);
    final bool juegoGanado;
    if (desempate) {
      juegoGanado = (pl >= 7 || pv >= 7) && (pl - pv).abs() >= 2;
    } else if (puntoDeOro) {
      juegoGanado = pl >= 4 || pv >= 4;
    } else {
      juegoGanado = (pl >= 4 || pv >= 4) && (pl - pv).abs() >= 2;
    }
    if (!juegoGanado) return copiar(puntosL: pl, puntosV: pv);

    final gl = juegosL + (local ? 1 : 0);
    final gv = juegosV + (local ? 0 : 1);
    final setGanado =
        (gl >= 6 || gv >= 6) && ((gl - gv).abs() >= 2 || gl == 7 || gv == 7);
    if (!setGanado) {
      return copiar(juegosL: gl, juegosV: gv, puntosL: 0, puntosV: 0);
    }
    return copiar(
      sets: [
        ...sets,
        [gl, gv],
      ],
      juegosL: 0,
      juegosV: 0,
      puntosL: 0,
      puntosV: 0,
    );
  }

  /// Texto del punto actual de cada lado: 0, 15, 30, 40, «Ad» (o el número en el desempate).
  (String, String) get textoPuntos {
    if (desempate) return ('$puntosL', '$puntosV');
    const t = ['0', '15', '30', '40'];
    if (puntosL >= 3 && puntosV >= 3 && !puntoDeOro) {
      if (puntosL == puntosV) return ('40', '40');
      return puntosL > puntosV ? ('Ad', '40') : ('40', 'Ad');
    }
    return (t[puntosL.clamp(0, 3)], t[puntosV.clamp(0, 3)]);
  }

  /// Resultado para guardar: los sets cerrados.
  List<List<int>> get resultado => [for (final s in sets) List<int>.of(s)];
}
