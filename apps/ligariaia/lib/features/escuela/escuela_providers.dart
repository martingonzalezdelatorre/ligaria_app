import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';

/// Pide la categoría cuando la liga tiene varias. `ok == false` si se cancela;
/// `id == null` si no hace falta elegir (la liga tiene una sola categoría).
Future<({bool ok, String? id})> elegirCategoria(
  BuildContext context,
  LigaRepository repo,
  String ligaId,
  String ligaNombre,
) async {
  final cats = await repo.categorias(ligaId);
  if (cats.length <= 1) return (ok: true, id: null);
  if (!context.mounted) return (ok: false, id: null);
  final id = await elegirDeLista<String>(
    context,
    icono: Icons.category_outlined,
    titulo: context.l10n.eligeCategoria,
    subtitulo: ligaNombre,
    opciones: [for (final c in cats) (c.id, c.nombre, c.detalle)],
    vacio: context.l10n.ligaSinCategorias,
  );
  return (ok: id != null, id: id);
}

final usuariosEscuelaProvider =
    FutureProvider.family<List<UsuarioEscuela>, String>(
      (ref, escuelaId) => ref.watch(ligaRepositoryProvider).usuarios(escuelaId),
    );
final jugadoresOrgProvider = FutureProvider.family<List<JugadorLite>, String>(
  (ref, escuelaId) => ref.watch(ligaRepositoryProvider).jugadoresOrg(escuelaId),
);
final equiposEscuelaProvider = FutureProvider.family<List<EquipoLite>, String>(
  (ref, escuelaId) => ref.watch(ligaRepositoryProvider).equipos(escuelaId),
);
final jugadoresEquipoEscuelaProvider =
    FutureProvider.family<List<Jugador>, String>(
      (ref, equipoId) => ref.watch(ligaRepositoryProvider).jugadores(equipoId),
    );
final ligasAbiertasProvider = FutureProvider<List<LigaAbierta>>(
  (ref) => ref.watch(ligaRepositoryProvider).ligasAbiertas(),
);
/// Inscripciones de los equipos de la escuela en cualquier liga (pendientes, aceptadas y rechazadas).
final inscripcionesEscuelaProvider =
    FutureProvider.family<List<InscripcionVista>, String>(
      (ref, escuelaId) =>
          ref.watch(ligaRepositoryProvider).inscripcionesEscuela(escuelaId),
    );

/// Ligas de otros organizadores en las que la escuela tiene algún equipo inscrito, con sus inscripciones.
final ligasParticipoProvider =
    FutureProvider.family<
      List<({Liga liga, List<InscripcionVista> inscripciones})>,
      String
    >((ref, escuelaId) async {
      final repo = ref.watch(ligaRepositoryProvider);
      final (ligas, inscripciones) = await (
        repo.misLigas(),
        ref.watch(inscripcionesEscuelaProvider(escuelaId).future),
      ).wait;
      return [
        for (final l in ligas)
          if (l.organizationId != escuelaId &&
              inscripciones.any((i) => i.ligaId == l.id))
            (
              liga: l,
              inscripciones: inscripciones
                  .where((i) => i.ligaId == l.id)
                  .toList(),
            ),
      ];
    });
final misInvitacionesProvider =FutureProvider.autoDispose<List<MiInvitacion>>(
  (ref) => ref.watch(ligaRepositoryProvider).misInvitaciones(),
);
final deportesProvider = FutureProvider<List<Deporte>>(
  (ref) => ref.watch(ligaRepositoryProvider).deportes(),
);

int edadDe(DateTime nac, [DateTime? hoy]) {
  final h = hoy ?? DateTime.now();
  var e = h.year - nac.year;
  if (h.month < nac.month || (h.month == nac.month && h.day < nac.day)) e--;
  return e;
}

/// Traduce errores del servidor a mensajes comprensibles (sin detalles técnicos).
String mensajeErrorEscuela(Object e) {
  final l = l10nActual;
  final t = e.toString().toLowerCase();
  if (t.contains('escuela_existe') || t.contains('email_existe')) {
    return l.errCuentaExiste;
  }
  if (t.contains('deporte del equipo no coincide')) {
    return l.errDeporteNoCoincide;
  }
  if (t.contains('no está abierta') ||
      t.contains('ya no admite inscripciones')) {
    return l.errLigaCerrada;
  }
  if (t.contains('calendario ya está generado')) return l.errCalendarioInscr;
  if (t.contains('privada de su organización')) return l.errPrivadaOrg;
  if (t.contains('elige una categoría')) return l.errEligeCat;
  if (t.contains('categoría no pertenece')) return l.errCatNoPertenece;
  if (t.contains('es privada')) return l.errPrivadaInv;
  if (t.contains('invitación ya está resuelta')) return l.errInvRespondida;
  if (t.contains('no pertenece a la organización')) return l.errJugadorOrg;
  if (t.contains('duplicate key') || t.contains('23505')) {
    return l.errRegistroDup;
  }
  if (t.contains('sin permiso') ||
      t.contains('42501') ||
      t.contains('row-level security')) {
    return l.errSinPermiso;
  }
  return l.errAccion;
}

/// Fecha dd/mm/aaaa → DateTime (null si no es válida).
DateTime? parseFecha(String t) {
  final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), mes = int.parse(m[2]!), a = int.parse(m[3]!);
  final f = DateTime(a, mes, d);
  return (f.day == d && f.month == mes && f.year == a) ? f : null;
}
