import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_friends/features/jugador/ligas/tanteo.dart';

Tanteo _juegos(Tanteo t, int local, int visit) {
  for (var i = 0; i < local; i++) {
    for (var p = 0; p < 4; p++) {
      t = t.punto(true);
    }
  }
  for (var i = 0; i < visit; i++) {
    for (var p = 0; p < 4; p++) {
      t = t.punto(false);
    }
  }
  return t;
}

void main() {
  test('textos de puntos y ventaja', () {
    var t = const Tanteo(setsParaGanar: 2);
    t = t.punto(true).punto(true);
    expect(t.textoPuntos, ('30', '0'));
    t = t.punto(false).punto(false).punto(false); // 30-40
    t = t.punto(true); // 40-40
    expect(t.textoPuntos, ('40', '40'));
    expect(t.punto(true).textoPuntos, ('Ad', '40'));
    expect(t.punto(true).punto(false).textoPuntos, ('40', '40'));
  });

  test('punto de oro decide el juego en el 40-40', () {
    var t = const Tanteo(setsParaGanar: 2, puntoDeOro: true);
    for (var i = 0; i < 3; i++) {
      t = t.punto(true).punto(false);
    }
    t = t.punto(false);
    expect(t.juegosV, 1);
    expect(t.textoPuntos, ('0', '0'));
  });

  test('set 6-4 y partido a 2 sets', () {
    var t = const Tanteo(setsParaGanar: 2);
    for (var i = 0; i < 4; i++) {
      t = _juegos(t, 1, 0);
      t = _juegos(t, 0, 1);
    }
    t = _juegos(t, 2, 0);
    expect(t.sets, [
      [6, 4],
    ]);
    t = _juegos(t, 6, 0);
    expect(t.terminado, isTrue);
    expect(t.ganaLocal, isTrue);
    expect(t.resultado, [
      [6, 4],
      [6, 0],
    ]);
  });

  test('desempate a 7 cierra el set 7-6', () {
    var t = const Tanteo(setsParaGanar: 1);
    for (var i = 0; i < 5; i++) {
      t = _juegos(t, 1, 0);
      t = _juegos(t, 0, 1);
    }
    t = _juegos(t, 1, 0);
    t = _juegos(t, 0, 1); // 6-6
    expect(t.desempate, isTrue);
    for (var i = 0; i < 7; i++) {
      t = t.punto(true);
    }
    expect(t.resultado, [
      [7, 6],
    ]);
    expect(t.terminado, isTrue);
  });
}
