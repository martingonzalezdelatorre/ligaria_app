import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';

final orgLigasProvider = FutureProvider.autoDispose.family<List<Liga>, String>(
    (ref, escuelaId) => ref
        .watch(ligaRepositoryProvider)
        .ligasOrganizadas(escuelaId)
        .timeout(const Duration(seconds: 20)));

final orgDeportesProvider =
    FutureProvider.autoDispose<List<Deporte>>((ref) => ref.watch(ligaRepositoryProvider).deportes());

final orgEncuentrosProvider = FutureProvider.autoDispose.family<List<EncuentroVista>, String>(
    (ref, ligaId) => ref.watch(ligaRepositoryProvider).encuentros(ligaId));

final orgClasificacionProvider = FutureProvider.autoDispose.family<List<FilaClasificacion>, String>(
    (ref, ligaId) => ref.watch(ligaRepositoryProvider).clasificacion(ligaId));

final orgDetalleProvider = FutureProvider.autoDispose.family<DetalleEncuentro, String>(
    (ref, encuentroId) => ref.watch(ligaRepositoryProvider).detalleEncuentro(encuentroId));

/// Invalida todo lo que depende del resultado de un encuentro (listas, clasificación, detalle).
void refrescarResultado(WidgetRef ref, EncuentroVista e) {
  ref.invalidate(orgEncuentrosProvider(e.ligaId));
  ref.invalidate(orgClasificacionProvider(e.ligaId));
  ref.invalidate(orgDetalleProvider(e.id));
}

/// Traduce errores del servidor a mensajes en español, sin detalles internos.
String mensajeError(Object e, {String defecto = 'No se pudo completar la operación.'}) {
  final t = e.toString().toLowerCase();
  if (t.contains('escuela_existe') || t.contains('email_existe')) {
    return 'No se puede crear la cuenta, contacte con el departamento técnico en tecnico@ligaria.es';
  }
  if (t.contains('no se puede regenerar') || t.contains('resultados registrados')) {
    return 'Ya hay resultados registrados: no se puede regenerar el calendario.';
  }
  if (t.contains('al menos 2 equipos')) return 'Se necesitan al menos 2 equipos inscritos.';
  if (t.contains('no admite') || t.contains('ya no admite')) return 'La competición ya no admite cambios.';
  if (t.contains('sin permiso') || t.contains('row-level security') || t.contains('42501')) {
    return 'No tienes permiso para hacer esto.';
  }
  return defecto;
}
