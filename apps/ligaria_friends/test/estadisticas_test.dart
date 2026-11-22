import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_friends/features/jugador/estadisticas/estadisticas_repositorio.dart';
import 'package:ligaria_friends/features/jugador/ligas/ligas_repositorio.dart';
import 'package:ligaria_friends/features/jugador/ligas/tanteador_page.dart';
import 'package:ligaria_friends/features/jugador/ligas/tanteo.dart';
import 'package:ligaria_friends/l10n/app_localizations.dart';

void main() {
  group('EstadisticasJugador', () {
    test('porcentajes y partidos perdidos', () {
      const e = EstadisticasJugador(
        usuarioId: 'u',
        nombre: 'A',
        partidos: 10,
        ganados: 4,
        partidosConPuntos: 2,
        puntosGanados: 30,
        puntosPerdidos: 70,
      );
      expect(e.perdidos, 6);
      expect(e.pctVictorias, closeTo(.4, 1e-9));
      expect(e.pctPuntos, closeTo(.3, 1e-9));
      expect(e.tienePuntos, isTrue);
    });

    test('sin partidos ni puntos no divide por cero', () {
      const e = EstadisticasJugador(usuarioId: 'u', nombre: 'A');
      expect(e.pctVictorias, 0);
      expect(e.pctPuntos, 0);
      expect(e.tienePuntos, isFalse);
    });

    test('desdeFila lee las columnas de la RPC', () {
      final e = EstadisticasJugador.desdeFila({
        'usuario_id': 'u1',
        'nombre': 'Ana',
        'partidos': 3,
        'ganados': 2,
        'sets_ganados': 5,
        'sets_perdidos': 3,
        'juegos_ganados': 41,
        'juegos_perdidos': 33,
        'partidos_con_puntos': 1,
        'puntos_ganados': 60,
        'puntos_perdidos': 50,
      });
      expect(e.nombre, 'Ana');
      expect(e.setsGanados, 5);
      expect(e.puntosPerdidos, 50);
    });

    test('el grupo se ordena por victorias, % y partidos', () {
      final l = ordenarEstadisticas([
        const EstadisticasJugador(
          usuarioId: 'a',
          nombre: 'A',
          partidos: 4,
          ganados: 2,
        ),
        const EstadisticasJugador(
          usuarioId: 'b',
          nombre: 'B',
          partidos: 2,
          ganados: 2,
        ),
        const EstadisticasJugador(
          usuarioId: 'c',
          nombre: 'C',
          partidos: 3,
          ganados: 2,
        ),
      ]);
      expect([for (final e in l) e.usuarioId], ['b', 'c', 'a']);
    });
  });

  group('el tanteador devuelve los puntos', () {
    Future<ResultadoTanteador?> jugar(
      WidgetTester tester,
      Future<void> Function() pulsar,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      ResultadoTanteador? res;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppL10n.supportedLocales,
          locale: const Locale('es'),
          home: Builder(
            builder: (c) => TextButton(
              onPressed: () async =>
                  res = await Navigator.of(c).push<ResultadoTanteador>(
                    MaterialPageRoute(
                      builder: (_) => const TanteadorPage(
                        local: 'Ana',
                        visitante: 'Luis',
                        deporte: Deporte.tenis,
                        setsParaGanar: 1,
                      ),
                    ),
                  ),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await pulsar();
      await tester.tap(find.text('Guardar resultado'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      return res;
    }

    testWidgets('secuencia L/V en orden y sets cerrados', (tester) async {
      final res = await jugar(tester, () async {
        // Un set a 1 juego decidido: 6 juegos de 4 puntos para el local.
        for (var i = 0; i < 24; i++) {
          await tester.tap(find.text('Punto para Ana'));
          await tester.pump();
        }
      });
      expect(res, isNotNull);
      expect(res!.puntos, 'L' * 24);
      expect(res.sets, [
        [6, 0],
      ]);
    });

    testWidgets('deshacer quita el último punto de la secuencia', (
      tester,
    ) async {
      final res = await jugar(tester, () async {
        await tester.tap(find.text('Punto para Luis'));
        await tester.pump();
        await tester.tap(find.text('Punto para Luis'));
        await tester.pump();
        await tester.tap(find.byTooltip('Deshacer último punto'));
        await tester.pump();
        for (var i = 0; i < 24; i++) {
          await tester.tap(find.text('Punto para Ana'));
          await tester.pump();
        }
      });
      expect(res!.puntos, 'V${'L' * 24}');
      expect(res.sets, [
        [6, 0],
      ]);
    });
  });
}
