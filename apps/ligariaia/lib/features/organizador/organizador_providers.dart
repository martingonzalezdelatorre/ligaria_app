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

final orgInscripcionesProvider = FutureProvider.autoDispose.family<List<InscripcionVista>, String>(
    (ref, ligaId) => ref.watch(ligaRepositoryProvider).inscripciones(ligaId));

final orgEquipoProvider = FutureProvider.autoDispose.family<List<UsuarioEscuela>, String>(
    (ref, orgId) => ref.watch(ligaRepositoryProvider).organizadoresOrg(orgId));

final orgByesProvider = FutureProvider.autoDispose.family<List<Descanso>, String>(
    (ref, ligaId) => ref.watch(ligaRepositoryProvider).pasanDirecto(ligaId));

final orgCategoriasProvider = FutureProvider.autoDispose.family<List<CategoriaLiga>, String>(
    (ref, ligaId) => ref.watch(ligaRepositoryProvider).categorias(ligaId));

final orgOrganizadoresProvider = FutureProvider.autoDispose.family<List<OrganizadorLiga>, String>(
    (ref, ligaId) => ref.watch(ligaRepositoryProvider).organizadores(ligaId));

final orgInvitacionesProvider = FutureProvider.autoDispose.family<List<InvitacionLiga>, String>(
    (ref, ligaId) => ref.watch(ligaRepositoryProvider).invitacionesLiga(ligaId));

final orgEscuelasInvitablesProvider = FutureProvider.autoDispose<List<EscuelaInvitable>>(
    (ref) => ref.watch(ligaRepositoryProvider).escuelasInvitables());

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
  if ((t.contains('no se puede regenerar') || t.contains('resultados registrados')) && !t.contains('playoff')) {
    return 'Ya hay resultados registrados: no se puede regenerar el calendario.';
  }
  if (t.contains('no puede haber empate')) return 'En una eliminatoria no puede haber empate: debe haber un ganador.';
  if (t.contains('siguiente ronda ya está generada')) {
    return 'La siguiente ronda ya está generada: no se puede cambiar el ganador.';
  }
  if (t.contains('pase directo')) return 'Ese encuentro es un pase directo del cuadro: no tiene resultado.';
  if (t.contains('fase de grupos no ha terminado')) return 'La fase de grupos aún no ha terminado.';
  if (t.contains('primero hay que generar el calendario')) return 'Primero genera el calendario de la fase de grupos.';
  if (t.contains('playoff ya tiene resultados')) return 'El playoff ya tiene resultados: no se puede regenerar.';
  if (t.contains('genera el cuadro')) return 'Esta liga es de eliminatoria: genera el cuadro.';
  if (t.contains('no es de eliminatoria') || t.contains('no tiene fase de grupos')) {
    return 'Esa acción no corresponde al formato de la liga.';
  }
  if (t.contains('entre 2 y 8')) return 'El número de grupos debe estar entre 2 y 8.';
  if (t.contains('no hay equipos suficientes')) return 'No hay equipos suficientes para el playoff.';
  if (t.contains('usuario no encontrado'))return 'No hay ninguna cuenta con ese correo. La persona debe registrarse primero.';
  if (t.contains('correo no válido')) return 'Introduce un correo válido.';
  if (t.contains('ya está invitado como organizador')) return 'Esa persona ya está invitada a esta liga.';
  if (t.contains('invitación no encontrada')) return 'No se encontró la invitación: puede que ya se haya activado.';
  if (t.contains('ya organiza las ligas')) return 'Esa persona ya organiza las ligas de la organización.';
  if (t.contains('ya es organizador')) return 'Esa persona ya organiza esta liga.';
  if (t.contains('tiene equipos inscritos') && t.contains('categor')) {
    return 'La categoría tiene equipos inscritos: no se puede eliminar.';
  }
  if (t.contains('al menos una categoría')) return 'La liga necesita al menos una categoría.';
  if (t.contains('elige una categoría')) return 'Elige una categoría.';
  if (t.contains('competicion_puntuacion_valida')) {
    return 'La puntuación no es válida: victoria ≥ empate ≥ derrota ≥ 0.';
  }
  if (t.contains('duplicate key')) return 'Ya existe una categoría con ese nombre.';
  if (t.contains('solo se puede invitar a escuelas'))return 'Solo se puede invitar a escuelas activas.';
  if (t.contains('no admite escuelas de fuera')) return 'Esta liga no admite escuelas de fuera.';
  if (t.contains('ya participa') || t.contains('está invitada')) {
    return 'Esa escuela ya participa, está invitada o tiene una solicitud.';
  }
  if (t.contains('ya tiene equipos inscritos')) return 'La escuela ya tiene equipos inscritos: no se puede retirar la invitación.';
  if (t.contains('ya no admite invitaciones')) return 'La liga ya no admite invitaciones.';
  if (t.contains('ya está resuelta')) return 'Esta solicitud ya estaba resuelta.';
  if (t.contains('calendario ya está generado')) return 'La liga ya tiene calendario; no admite más equipos.';
  if (t.contains('al menos 2 equipos')) return 'Se necesitan al menos 2 equipos inscritos.';
  if (t.contains('no admite') || t.contains('ya no admite')) return 'La competición ya no admite cambios.';
  if (t.contains('sin permiso') || t.contains('row-level security') || t.contains('42501')) {
    return 'No tienes permiso para hacer esto.';
  }
  return defecto;
}
