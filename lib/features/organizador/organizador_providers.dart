import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';

final orgLigasProvider = FutureProvider.autoDispose.family<List<Liga>, String>(
    (ref, escuelaId) => ref.watch(ligaRepositoryProvider).ligasOrganizadas(escuelaId));

final orgTemporadasProvider =
    FutureProvider.autoDispose<List<Temporada>>((ref) => ref.watch(ligaRepositoryProvider).temporadas());

final orgDeportesProvider =
    FutureProvider.autoDispose<List<Deporte>>((ref) => ref.watch(ligaRepositoryProvider).deportes());

final orgPendientesProvider = FutureProvider.autoDispose.family<List<EncuentroVista>, String>(
    (ref, escuelaId) => ref.watch(ligaRepositoryProvider).pendientes(escuelaId));

final orgEncuentrosProvider = FutureProvider.autoDispose.family<List<EncuentroVista>, String>(
    (ref, ligaId) => ref.watch(ligaRepositoryProvider).encuentros(ligaId));

final orgClasificacionProvider = FutureProvider.autoDispose.family<List<FilaClasificacion>, String>(
    (ref, ligaId) => ref.watch(ligaRepositoryProvider).clasificacion(ligaId));

final orgDetalleProvider = FutureProvider.autoDispose.family<DetalleEncuentro, String>(
    (ref, encuentroId) => ref.watch(ligaRepositoryProvider).detalleEncuentro(encuentroId));

final orgCorreccionesProvider = FutureProvider.autoDispose.family<List<Correccion>, String>(
    (ref, encuentroId) => ref.watch(ligaRepositoryProvider).correcciones(encuentroId));

/// Invalida todo lo que depende del resultado de un encuentro (listas, clasificación, detalle, historial).
void refrescarResultado(WidgetRef ref, String escuelaId, EncuentroVista e) {
  ref.invalidate(orgPendientesProvider(escuelaId));
  ref.invalidate(orgEncuentrosProvider(e.ligaId));
  ref.invalidate(orgClasificacionProvider(e.ligaId));
  ref.invalidate(orgDetalleProvider(e.id));
  ref.invalidate(orgCorreccionesProvider(e.id));
}

/// Traduce errores del servidor a mensajes en español, sin detalles internos.
String mensajeError(Object e, {String defecto = 'No se pudo completar la operación.'}) {
  final t = e.toString().toLowerCase();
  if (t.contains('no se puede regenerar') || t.contains('resultados')) {
    return 'Ya hay resultados propuestos o confirmados: no se puede regenerar el calendario.';
  }
  if (t.contains('al menos 2 equipos')) return 'Se necesitan al menos 2 equipos inscritos.';
  if (t.contains('sin permiso') || t.contains('solo la organización')) return 'No tienes permiso para hacer esto.';
  if (t.contains('módulo') || t.contains('row-level security') || t.contains('42501')) {
    return 'No tienes permiso o el módulo de competiciones no está activo en tu escuela.';
  }
  if (t.contains('motivo')) return 'Indica el motivo.';
  return defecto;
}
