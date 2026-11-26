import 'package:flutter_test/flutter_test.dart';
import 'package:ligariaia/data/models.dart';
import 'package:ligariaia/features/escuela/importar_jugadores.dart';

final _hoy = DateTime(2026, 11, 26);

List<FilaImport> _leer(String t, {List<JugadorLite> existentes = const []}) =>
    leerJugadores(t, existentes: existentes, hoy: _hoy);

void main() {
  group('tablaDeTexto', () {
    test('celdas separadas por tabulador (pegado desde Excel)', () {
      expect(tablaDeTexto('Ana\tLópez\t05/03/2015\nLuis\tPérez\t01/02/2014'), [
        ['Ana', 'López', '05/03/2015'],
        ['Luis', 'Pérez', '01/02/2014'],
      ]);
    });

    test(
      'CSV con punto y coma (Excel en español) y saltos de línea Windows',
      () {
        expect(tablaDeTexto('a;b;c\r\n1;2;3\r\n'), [
          ['a', 'b', 'c'],
          ['1', '2', '3'],
        ]);
      },
    );

    test(
      'CSV con comas y comillas, con coma y comilla dentro de una celda',
      () {
        expect(tablaDeTexto('"López, Ana","dice ""hola""",x'), [
          ['López, Ana', 'dice "hola"', 'x'],
        ]);
      },
    );

    test('quita la marca BOM y salta las filas vacías', () {
      expect(tablaDeTexto('﻿a;b\n\n;;\nc;d'), [
        ['a', 'b'],
        ['c', 'd'],
      ]);
    });
  });

  group('fechaFlexible', () {
    test('acepta los formatos habituales', () {
      final esperada = DateTime(2015, 3, 5);
      expect(fechaFlexible('05/03/2015', hoy: _hoy), esperada);
      expect(fechaFlexible('5/3/2015', hoy: _hoy), esperada);
      expect(fechaFlexible('05-03-2015', hoy: _hoy), esperada);
      expect(fechaFlexible('05.03.2015', hoy: _hoy), esperada);
      expect(fechaFlexible('2015-03-05', hoy: _hoy), esperada);
    });

    test('número de serie de Excel', () {
      // 42068 = 05/03/2015 en Excel.
      expect(fechaFlexible('42068', hoy: _hoy), DateTime(2015, 3, 5));
    });

    test('rechaza lo imposible, lo futuro y lo absurdo', () {
      expect(fechaFlexible('31/02/2015', hoy: _hoy), isNull);
      expect(fechaFlexible('05/03/2030', hoy: _hoy), isNull);
      expect(fechaFlexible('05/03/1800', hoy: _hoy), isNull);
      expect(fechaFlexible('ayer', hoy: _hoy), isNull);
      expect(fechaFlexible('', hoy: _hoy), isNull);
    });
  });

  group('leerJugadores', () {
    test('con cabecera: reconoce columnas con acentos, otro orden y extras', () {
      final f = _leer(
        'Correo del tutor;Fecha de nacimiento;Apellidos;Nombre;Observaciones\n'
        'maria@x.es;05/03/2015;López Ruiz;Ana;nada',
      );
      expect(f, hasLength(1));
      expect(f.single.valida, isTrue);
      expect(f.single.nombre, 'Ana');
      expect(f.single.apellidos, 'López Ruiz');
      expect(f.single.fecha, DateTime(2015, 3, 5));
      expect(f.single.correo, 'maria@x.es');
      expect(f.single.linea, 2); // la fila 1 es la cabecera
    });

    test('sin cabecera: orden nombre, apellidos, fecha, tutor, correo', () {
      final f = _leer('Ana;López;05/03/2015;María Ruiz;Maria@X.es');
      expect(f.single.valida, isTrue);
      expect(f.single.tutor, 'María Ruiz');
      expect(f.single.correo, 'maria@x.es'); // en minúsculas
      expect(f.single.conTutor, isTrue);
      expect(f.single.linea, 1);
    });

    test('tutor y correo son opcionales', () {
      final f = _leer('Ana;López;05/03/2015');
      expect(f.single.valida, isTrue);
      expect(f.single.conTutor, isFalse);
    });

    test('parentesco reconocido y sin reconocer', () {
      final f = _leer(
        'nombre;fecha;correo;parentesco\n'
        'Ana;05/03/2015;a@x.es;mamá\n'
        'Bea;05/03/2015;b@x.es;Padre\n'
        'Cai;05/03/2015;c@x.es;Abuela',
      );
      expect(f.map((x) => x.parentesco), ['Madre', 'Padre', 'Abuela']);
    });

    test('marca cada error con su motivo', () {
      final f = _leer(
        'nombre;apellidos;fecha;tutor;correo\n'
        ';López;05/03/2015;;\n'
        'Ana;López;nunca;;\n'
        'Bea;Ruiz;05/03/2015;Mamá;no-es-correo\n',
      );
      expect(f.map((x) => x.motivo), [
        MotivoFila.sinNombre,
        MotivoFila.fechaInvalida,
        MotivoFila.correoInvalido,
      ]);
    });

    test('repetidas en la lista y ya existentes en la escuela', () {
      final f = _leer(
        'Ana;López;05/03/2015\n'
        'ana;LÓPEZ;05/03/2015\n'
        'Luis;Pérez;01/02/2014',
        existentes: [
          JugadorLite(
            id: 'j1',
            nombre: 'Luis',
            apellidos: 'Pérez',
            fechaNacimiento: DateTime(2014, 2, 1),
          ),
        ],
      );
      expect(f[0].valida, isTrue);
      expect(f[1].motivo, MotivoFila.repetida);
      expect(f[2].motivo, MotivoFila.existe);
    });

    test('dos hermanos con el mismo correo de tutor son válidos', () {
      final f = _leer(
        'Ana;López;05/03/2015;Mamá;m@x.es\nLuis;López;01/02/2017;Mamá;m@x.es',
      );
      expect(f.every((x) => x.valida), isTrue);
    });

    test('texto vacío no da filas', () {
      expect(_leer(''), isEmpty);
      expect(_leer('  \n ;; \n'), isEmpty);
    });
  });
}
