import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';

/// Un equipo que entreno, con las ligas en las que participa.
class EquipoEntrenado {
  const EquipoEntrenado({required this.equipoId, required this.equipo, required this.escuela, this.ligas = const []});
  final String equipoId, equipo, escuela;
  final List<({String id, String nombre})> ligas;
}

/// misEquipos() filtrado a rol «entrenador», agrupando las filas (una por liga) por equipo.
final equiposEntrenadorProvider = FutureProvider<List<EquipoEntrenado>>((ref) async {
  final filas = await ref.watch(ligaRepositoryProvider).misEquipos();
  final mapa = <String, EquipoEntrenado>{};
  for (final f in filas.where((f) => f.rol == 'entrenador')) {
    final previo = mapa[f.equipoId];
    final ligas = [...?previo?.ligas];
    if (f.ligaId != null && !ligas.any((l) => l.id == f.ligaId)) {
      ligas.add((id: f.ligaId!, nombre: f.liga ?? ''));
    }
    mapa[f.equipoId] = EquipoEntrenado(equipoId: f.equipoId, equipo: f.equipo, escuela: f.escuela, ligas: ligas);
  }
  return mapa.values.toList();
});

final jugadoresDeEquipoProvider = FutureProvider.family<List<Jugador>, String>(
    (ref, equipoId) => ref.watch(ligaRepositoryProvider).jugadores(equipoId));

/// Encuentros de mis equipos en todas sus ligas, por jornada.
final proximaJornadaProvider = FutureProvider<List<EncuentroVista>>((ref) async {
  final equipos = await ref.watch(equiposEntrenadorProvider.future);
  final repo = ref.watch(ligaRepositoryProvider);
  final mios = equipos.map((e) => e.equipoId).toSet();
  final ligaIds = {for (final e in equipos) for (final l in e.ligas) l.id};
  final lista = <EncuentroVista>[];
  for (final id in ligaIds) {
    lista.addAll((await repo.encuentros(id)).where((e) => mios.contains(e.localId) || mios.contains(e.visitanteId)));
  }
  lista.sort((a, b) => a.jornada != b.jornada ? a.jornada.compareTo(b.jornada) : a.local.compareTo(b.local));
  return lista;
});

/// Datos para el formulario: estructura de partidos (+ resultado previo) y plantillas legibles.
class DatosFormulario {
  const DatosFormulario({required this.detalle, required this.local, required this.visitante});
  final DetalleEncuentro detalle;
  final List<Jugador> local, visitante;
}

/// Clave: (encuentroId, localId, visitanteId).
final datosFormularioProvider =
    FutureProvider.autoDispose.family<DatosFormulario, (String, String, String)>((ref, k) async {
  final repo = ref.watch(ligaRepositoryProvider);
  Future<List<Jugador>> plantilla(String equipoId) async {
    try {
      return await repo.jugadores(equipoId); // el rival suele estar vacío por RLS
    } catch (_) {
      return const [];
    }
  }

  final detalle = await repo.detalleEncuentro(k.$1);
  return DatosFormulario(detalle: detalle, local: await plantilla(k.$2), visitante: await plantilla(k.$3));
});

/// Traduce errores del servidor a mensajes comprensibles (sin detalles técnicos).
String mensajeErrorEntrenador(Object e) {
  final t = e.toString().toLowerCase();
  if (t.contains('no pertenece al equipo')) return 'Algún jugador no pertenece a su equipo.';
  if (t.contains('ya está confirmado')) return 'El resultado ya está confirmado; pide una corrección a la organización.';
  if (t.contains('sin permiso')) return 'No tienes permiso para proponer este resultado.';
  if (t.contains('marcador de set')) return 'Hay un marcador de set no válido.';
  if (t.contains('demasiados jugadores')) return 'Hay demasiados jugadores en un partido.';
  return 'No se pudo enviar el resultado. Inténtalo de nuevo.';
}
