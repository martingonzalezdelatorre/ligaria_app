import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_friends/features/jugador/ligas/comando_voz.dart';

String _s(List<ComandoVoz> c) => c.join(',');

void main() {
  final i = InterpreteVoz(local: 'Martín / Ana', visitante: 'Luis García');

  test('punto para un jugador por su nombre, con o sin tildes', () {
    expect(_s(i.interpretar('punto para Martín')), 'PuntoVoz(local)');
    expect(_s(i.interpretar('Punto para martin')), 'PuntoVoz(local)');
    expect(_s(i.interpretar('ana')), 'PuntoVoz(local)');
    expect(_s(i.interpretar('punto de Luis')), 'PuntoVoz(visitante)');
  });

  test('local, visitante y deshacer', () {
    expect(_s(i.interpretar('punto local')), 'PuntoVoz(local)');
    expect(_s(i.interpretar('punto visitante')), 'PuntoVoz(visitante)');
    expect(_s(i.interpretar('deshacer')), 'DeshacerVoz()');
  });

  test('varios comandos en una frase, en orden', () {
    expect(
      _s(i.interpretar('punto Martín punto Luis deshacer')),
      'PuntoVoz(local),PuntoVoz(visitante),DeshacerVoz()',
    );
  });

  test('nombre y apellido del mismo lado cuentan un solo punto', () {
    expect(_s(i.interpretar('punto para Luis García')), 'PuntoVoz(visitante)');
    expect(
      _s(i.interpretar('punto Luis García punto Luis')),
      'PuntoVoz(visitante),PuntoVoz(visitante)',
    );
  });

  test('lo que no se entiende se ignora', () {
    expect(i.interpretar('quince cero buena jugada'), isEmpty);
    expect(i.interpretar(''), isEmpty);
  });

  test('un nombre repetido en los dos lados es ambiguo y no puntúa', () {
    final a = InterpreteVoz(local: 'Ana López', visitante: 'Ana Ruiz');
    expect(a.interpretar('punto para Ana'), isEmpty);
    expect(_s(a.interpretar('punto para López')), 'PuntoVoz(local)');
  });
}
