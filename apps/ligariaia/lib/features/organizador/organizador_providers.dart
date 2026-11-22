import '../../core/idioma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';

final orgLigasProvider = FutureProvider.autoDispose.family<List<Liga>, String>(
  (ref, escuelaId) => ref
      .watch(ligaRepositoryProvider)
      .ligasOrganizadas(escuelaId)
      .timeout(const Duration(seconds: 20)),
);

final orgDeportesProvider = FutureProvider.autoDispose<List<Deporte>>(
  (ref) => ref.watch(ligaRepositoryProvider).deportes(),
);

final orgEncuentrosProvider = FutureProvider.autoDispose
    .family<List<EncuentroVista>, String>(
      (ref, ligaId) => ref.watch(ligaRepositoryProvider).encuentros(ligaId),
    );

final orgClasificacionProvider = FutureProvider.autoDispose
    .family<List<FilaClasificacion>, String>(
      (ref, ligaId) => ref.watch(ligaRepositoryProvider).clasificacion(ligaId),
    );

final orgInscripcionesProvider = FutureProvider.autoDispose
    .family<List<InscripcionVista>, String>(
      (ref, ligaId) => ref.watch(ligaRepositoryProvider).inscripciones(ligaId),
    );

final orgEquipoProvider = FutureProvider.autoDispose
    .family<List<UsuarioEscuela>, String>(
      (ref, orgId) => ref.watch(ligaRepositoryProvider).organizadoresOrg(orgId),
    );

final orgByesProvider = FutureProvider.autoDispose
    .family<List<Descanso>, String>(
      (ref, ligaId) => ref.watch(ligaRepositoryProvider).pasanDirecto(ligaId),
    );

final orgCategoriasProvider = FutureProvider.autoDispose
    .family<List<CategoriaLiga>, String>(
      (ref, ligaId) => ref.watch(ligaRepositoryProvider).categorias(ligaId),
    );

final orgOrganizadoresProvider = FutureProvider.autoDispose
    .family<List<OrganizadorLiga>, String>(
      (ref, ligaId) => ref.watch(ligaRepositoryProvider).organizadores(ligaId),
    );

final orgInvitacionesProvider = FutureProvider.autoDispose
    .family<List<InvitacionLiga>, String>(
      (ref, ligaId) =>
          ref.watch(ligaRepositoryProvider).invitacionesLiga(ligaId),
    );

final orgEscuelasInvitablesProvider =
    FutureProvider.autoDispose<List<EscuelaInvitable>>(
      (ref) => ref.watch(ligaRepositoryProvider).escuelasInvitables(),
    );

final orgDetalleProvider = FutureProvider.autoDispose
    .family<DetalleEncuentro, String>(
      (ref, encuentroId) =>
          ref.watch(ligaRepositoryProvider).detalleEncuentro(encuentroId),
    );

/// Invalida todo lo que depende del resultado de un encuentro (listas, clasificación, detalle).
void refrescarResultado(WidgetRef ref, EncuentroVista e) {
  ref.invalidate(orgEncuentrosProvider(e.ligaId));
  ref.invalidate(orgClasificacionProvider(e.ligaId));
  ref.invalidate(orgDetalleProvider(e.id));
}

/// Traduce errores del servidor a mensajes en español, sin detalles internos.
String mensajeError(Object e, {String? defecto}) {
  final l = l10nActual;
  final t = e.toString().toLowerCase();
  if (t.contains('escuela_existe') || t.contains('email_existe')) {
    return l.errCuentaExiste;
  }
  if ((t.contains('no se puede regenerar') ||
          t.contains('resultados registrados')) &&
      !t.contains('playoff')) {
    return l.errRegenerar;
  }
  if (t.contains('la liga está cerrada') || t.contains('ya se ha jugado')) {
    return l.errProgramacionCerrada;
  }
  if (t.contains('solo se puede finalizar')) return l.errFinalizarLiga;
  if (t.contains('no puede haber empate')) return l.errEmpateElim;
  if (t.contains('siguiente ronda ya está generada')) {
    return l.errRondaGenerada;
  }
  if (t.contains('pase directo')) return l.errPaseDirecto;
  if (t.contains('fase de grupos no ha terminado'))
    return l.errGruposNoTerminada;
  if (t.contains('primero hay que generar el calendario'))
    return l.errPrimeroCalendario;
  if (t.contains('playoff ya tiene resultados')) return l.errPlayoffResultados;
  if (t.contains('genera el cuadro')) return l.errGeneraCuadro;
  if (t.contains('no es de eliminatoria') ||
      t.contains('no tiene fase de grupos')) {
    return l.errAccionFormato;
  }
  if (t.contains('entre 2 y 8')) return l.errGrupos28;
  if (t.contains('no hay equipos suficientes')) return l.errEquiposPlayoff;
  if (t.contains('usuario no encontrado')) return l.errSinCuenta;
  if (t.contains('correo no válido')) return l.errCorreoValido;
  if (t.contains('ya está invitado como organizador'))
    return l.errYaInvitadaLiga;
  if (t.contains('invitación no encontrada')) return l.errInvNoEncontrada;
  if (t.contains('ya organiza las ligas')) return l.errYaOrgTodas;
  if (t.contains('ya es organizador')) return l.errYaOrgLiga;
  if (t.contains('tiene equipos inscritos') && t.contains('categor')) {
    return l.errCatEquipos;
  }
  if (t.contains('al menos una categoría')) return l.errCatMin;
  if (t.contains('elige una categoría')) return l.errEligeCat;
  if (t.contains('competicion_puntuacion_valida')) {
    return l.errPuntuacion;
  }
  if (t.contains('duplicate key')) return l.errCatDup;
  if (t.contains('solo se puede invitar a escuelas')) return l.errSoloActivas;
  if (t.contains('no admite escuelas de fuera')) return l.errNoExternas;
  if (t.contains('ya participa') || t.contains('está invitada')) {
    return l.errEscuelaYa;
  }
  if (t.contains('ya tiene equipos inscritos')) return l.errEscuelaEquipos;
  if (t.contains('ya no admite invitaciones')) return l.errNoInvitaciones;
  if (t.contains('ya está resuelta')) return l.errSolResuelta;
  if (t.contains('calendario ya está generado')) return l.errCalendarioEquipos;
  if (t.contains('al menos 2 equipos')) return l.errMin2;
  if (t.contains('no admite') || t.contains('ya no admite'))
    return l.errNoCambios;
  if (t.contains('sin permiso') ||
      t.contains('row-level security') ||
      t.contains('42501')) {
    return l.errSinPermiso;
  }
  return defecto ?? l.errOperacion;
}
