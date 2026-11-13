// Modo demo: arranca la app con datos de ejemplo, sin Supabase.
//   flutter run -d chrome -t lib/main_demo.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/auth.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'data/liga_repository.dart';
import 'data/models.dart';

void main() {
  runApp(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(_AuthDemo()),
      ligaRepositoryProvider.overrideWithValue(_LigaDemo()),
    ],
    child: const _DemoApp(),
  ));
}

class _DemoApp extends ConsumerWidget {
  const _DemoApp();
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Ligaria (demo)',
        debugShowCheckedModeBanner: false,
        theme: temaClaro(),
        darkTheme: temaOscuro(),
        themeMode: ref.watch(themeModeProvider),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: ref.watch(routerProvider),
      );
}

class _AuthDemo implements AuthRepository {
  @override
  String? get userId => 'demo';
  @override
  String? get email => 'demo@ligaria.app';
  @override
  Stream<String?> get cambios => const Stream.empty();
  @override
  Stream<void> get recuperacion => const Stream.empty();
  @override
  Future<void> iniciarSesion(String email, String password) async {}
  @override
  Future<void> enviarRecuperacion(String email) async {}
  @override
  Future<void> cerrarSesion() async {}
  @override
  Future<void> cambiarPassword(String nueva) async {}
  @override
  Future<List<Pertenencia>> misPertenencias() async => const [
        Pertenencia(escuelaId: 'e1', escuela: 'Club Tenis Norte', rol: Rol.alumno),
        Pertenencia(escuelaId: 'e1', escuela: 'Club Tenis Norte', rol: Rol.entrenador),
        Pertenencia(escuelaId: 'e1', escuela: 'Club Tenis Norte', rol: Rol.organizadorLiga),
      ];
}

const _ligaId = 'l1';
const _mio = 'q1';
const _equipos = <(String, String, String)>[
  ('q1', 'Norte Sub-14', 'Club Tenis Norte'),
  ('q2', 'Valle Raquetas', 'Escuela del Valle'),
  ('q3', 'Real Pádel Sur', 'Real Club Sur'),
  ('q4', 'Aces Mar', 'Academia Mar'),
  ('q5', 'Smash Centro', 'Club Centro'),
  ('q6', 'Pinos Tenis', 'Escuela Los Pinos'),
];

class _LigaDemo implements LigaRepository {
  @override
  Future<List<Liga>> misLigas() async => const [
        Liga(id: _ligaId, nombre: 'Liga Escolar Primavera', estado: 'en_curso', deporte: 'Tenis'),
        Liga(id: 'l2', nombre: 'Copa Pádel Juvenil', estado: 'publicada', deporte: 'Pádel'),
      ];

  @override
  Future<List<MiEquipo>> misEquipos() async => const [
        MiEquipo(equipoId: _mio, equipo: 'Norte Sub-14', escuelaId: 'e1', escuela: 'Club Tenis Norte', rol: 'alumno', ligaId: _ligaId, liga: 'Liga Escolar Primavera'),
      ];

  @override
  Future<List<EncuentroVista>> encuentros(String ligaId) async {
    final base = DateTime.now();
    EncuentroVista e(int i, int j, int a, int b, {int? pl, int? pv, String estado = 'finalizado'}) => EncuentroVista(
          id: 'm$i',
          ligaId: ligaId,
          jornada: j,
          estado: estado,
          localId: _equipos[a].$1,
          local: _equipos[a].$2,
          visitanteId: _equipos[b].$1,
          visitante: _equipos[b].$2,
          fecha: base.add(Duration(days: (j - 3) * 7)),
          partidosLocal: pl,
          partidosVisitante: pv,
        );
    return [
      e(1, 1, 0, 1, pl: 3, pv: 1),
      e(2, 1, 2, 3, pl: 2, pv: 2),
      e(3, 2, 4, 0, pl: 1, pv: 3),
      e(4, 2, 1, 2, pl: 0, pv: 4),
      e(5, 3, 0, 2, estado: 'programado'),
      e(6, 3, 3, 4, estado: 'programado'),
      e(7, 4, 5, 0, estado: 'programado'),
    ];
  }

  @override
  Future<List<Descanso>> descansos(String ligaId) async => const [Descanso(jornada: 3, equipoId: 'q6', equipo: 'Pinos Tenis')];

  @override
  Future<List<FilaClasificacion>> clasificacion(String ligaId) async {
    final datos = [
      (0, 2, 2, 0, 0, 6), (2, 2, 1, 1, 0, 4), (1, 2, 1, 0, 1, 3),
      (3, 2, 0, 1, 1, 1), (4, 2, 0, 0, 2, 0), (5, 0, 0, 0, 0, 0),
    ];
    return [
      for (var i = 0; i < datos.length; i++)
        FilaClasificacion(
          posicion: i + 1,
          equipoId: _equipos[datos[i].$1].$1,
          equipo: _equipos[datos[i].$1].$2,
          escuela: _equipos[datos[i].$1].$3,
          pj: datos[i].$2, pg: datos[i].$3, pe: datos[i].$4, pp: datos[i].$5, puntos: datos[i].$6,
          partidosF: 0, partidosC: 0, setsF: 0, setsC: 0, juegosF: 0, juegosC: 0,
        ),
    ];
  }

  @override
  Future<List<Ficha>> misFichas() async => [
        Ficha(
          jugadorId: 'p1', escuelaId: 'e1', escuela: 'Club Tenis Norte', nombre: 'Lucía', apellidos: 'Martín Gil',
          fechaNacimiento: DateTime(2012, 5, 14), nivel: 'Iniciación', manoDominante: 'DIESTRO', relacion: 'tutor',
        ),
      ];

  @override
  Future<List<Jugador>> jugadores(String equipoId) async => const [
        Jugador(jugadorId: 'j1', nombre: 'Lucía', apellidos: 'Martín'),
        Jugador(jugadorId: 'j2', nombre: 'Pablo', apellidos: 'Ruiz'),
        Jugador(jugadorId: 'j3', nombre: 'Marta', apellidos: 'Soler'),
        Jugador(jugadorId: 'j4', nombre: 'Diego', apellidos: 'Vera'),
      ];

  @override
  Future<List<Liga>> ligasOrganizadas(String escuelaId) => misLigas();

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value(const []);
}
