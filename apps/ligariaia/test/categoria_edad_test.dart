import 'package:flutter_test/flutter_test.dart';
import 'package:ligariaia/data/categoria_edad.dart';

void main() {
  final hoy = DateTime(2026, 11, 21);
  test('la categoría sale del año de nacimiento', () {
    expect(categoriaPorEdad(DateTime(2018, 3, 1), hoy), 'Prebenjamín'); // 8
    expect(categoriaPorEdad(DateTime(2016, 12, 31), hoy), 'Benjamín'); // 10
    expect(categoriaPorEdad(DateTime(2014, 1, 1), hoy), 'Alevín'); // 12
    expect(categoriaPorEdad(DateTime(2012, 5, 14), hoy), 'Infantil'); // 14
    expect(categoriaPorEdad(DateTime(2010, 6, 1), hoy), 'Cadete'); // 16
    expect(categoriaPorEdad(DateTime(2008, 6, 1), hoy), 'Júnior'); // 18
    expect(categoriaPorEdad(DateTime(2000, 6, 1), hoy), 'Absoluta');
  });
}
