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

  test('los equipos filtran por año de nacimiento según su categoría', () {
    final y = DateTime(2026, 11, 21);
    DateTime n(int anio) => DateTime(anio, 6, 1);
    expect(CategoriaEquipo.benjamin.admite(n(2016), y), isTrue);
    expect(CategoriaEquipo.benjamin.admite(n(2019), y), isTrue);
    expect(CategoriaEquipo.benjamin.admite(n(2015), y), isFalse);
    expect(CategoriaEquipo.alevin.admite(n(2014), y), isTrue);
    expect(CategoriaEquipo.alevin.admite(n(2015), y), isTrue);
    expect(CategoriaEquipo.alevin.admite(n(2016), y), isFalse);
    expect(CategoriaEquipo.alevin.admite(n(2013), y), isFalse);
    expect(CategoriaEquipo.infantil.admite(n(2012), y), isTrue);
    expect(CategoriaEquipo.cadete.admite(n(2011), y), isTrue);
    expect(CategoriaEquipo.junior.admite(n(2008), y), isTrue);
    expect(CategoriaEquipo.junior.admite(n(2007), y), isFalse);
    expect(CategoriaEquipo.absoluto.admite(n(1970), y), isTrue);
    expect(CategoriaEquipo.absoluto.admite(null, y), isTrue);
    expect(CategoriaEquipo.alevin.admite(null, y), isFalse);
    expect(CategoriaEquipo.veteranos.admite(n(1991), y), isTrue);
    expect(CategoriaEquipo.veteranos.admite(n(1992), y), isFalse);
    expect(CategoriaEquipo.alevin.aniosNacimiento(y), (2014, 2015));
    expect(CategoriaEquipo.benjamin.aniosNacimiento(y), (2016, null));
    // Al cambiar de año la categoría avanza sola.
    expect(CategoriaEquipo.alevin.aniosNacimiento(DateTime(2027)), (2015, 2016));
  });
}
