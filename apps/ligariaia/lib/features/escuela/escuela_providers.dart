import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';

/// Pide la categoría cuando la liga tiene varias. `ok == false` si se cancela;
/// `id == null` si no hace falta elegir (la liga tiene una sola categoría).
Future<({bool ok, String? id})> elegirCategoria(
    BuildContext context, LigaRepository repo, String ligaId, String ligaNombre) async {
  final cats = await repo.categorias(ligaId);
  if (cats.length <= 1) return (ok: true, id: null);
  if (!context.mounted) return (ok: false, id: null);
  final id = await elegirDeLista<String>(
    context,
    icono: Icons.category_outlined,
    titulo: 'Elige la categoría',
    subtitulo: ligaNombre,
    opciones: [for (final c in cats) (c.id, c.nombre, c.detalle)],
    vacio: 'La liga no tiene categorías.',
  );
  return (ok: id != null, id: id);
}

final usuariosEscuelaProvider = FutureProvider.family<List<UsuarioEscuela>, String>(
    (ref, escuelaId) => ref.watch(ligaRepositoryProvider).usuarios(escuelaId));
final jugadoresOrgProvider = FutureProvider.family<List<JugadorLite>, String>(
    (ref, escuelaId) => ref.watch(ligaRepositoryProvider).jugadoresOrg(escuelaId));
final equiposEscuelaProvider = FutureProvider.family<List<EquipoLite>, String>(
    (ref, escuelaId) => ref.watch(ligaRepositoryProvider).equipos(escuelaId));
final jugadoresEquipoEscuelaProvider = FutureProvider.family<List<Jugador>, String>(
    (ref, equipoId) => ref.watch(ligaRepositoryProvider).jugadores(equipoId));
final ligasAbiertasProvider =
    FutureProvider<List<LigaAbierta>>((ref) => ref.watch(ligaRepositoryProvider).ligasAbiertas());
final misInvitacionesProvider = FutureProvider.autoDispose<List<MiInvitacion>>(
    (ref) => ref.watch(ligaRepositoryProvider).misInvitaciones());
final deportesProvider = FutureProvider<List<Deporte>>((ref) => ref.watch(ligaRepositoryProvider).deportes());

int edadDe(DateTime nac, [DateTime? hoy]) {
  final h = hoy ?? DateTime.now();
  var e = h.year - nac.year;
  if (h.month < nac.month || (h.month == nac.month && h.day < nac.day)) e--;
  return e;
}

/// Traduce errores del servidor a mensajes comprensibles (sin detalles técnicos).
String mensajeErrorEscuela(Object e) {
  final t = e.toString().toLowerCase();
  if (t.contains('escuela_existe') || t.contains('email_existe')) {
    return 'No se puede crear la cuenta, contacte con el departamento técnico en tecnico@ligaria.es';
  }
  if (t.contains('deporte del equipo no coincide')) return 'El deporte del equipo no coincide con el de la liga.';
  if (t.contains('no está abierta') || t.contains('ya no admite inscripciones')) {
    return 'La liga no está abierta a inscripción.';
  }
  if (t.contains('calendario ya está generado')) return 'La liga ya tiene calendario; no admite más inscripciones.';
  if (t.contains('privada de su organización')) return 'Esta liga es privada de su organización.';
  if (t.contains('elige una categoría')) return 'Elige una categoría.';
  if (t.contains('categoría no pertenece')) return 'La categoría no pertenece a esa liga.';
  if (t.contains('es privada'))return 'Esta liga es privada: solo participan las escuelas invitadas.';
  if (t.contains('invitación ya está resuelta')) return 'Esta invitación ya estaba respondida.';
  if (t.contains('no pertenece a la organización')) return 'El jugador no pertenece a la organización del equipo.';
  if (t.contains('duplicate key') || t.contains('23505')) return 'Ya existe un registro igual.';
  if (t.contains('sin permiso') || t.contains('42501') || t.contains('row-level security')) {
    return 'No tienes permiso para hacer esto.';
  }
  return 'No se pudo completar la acción. Inténtalo de nuevo.';
}

/// Fecha dd/mm/aaaa → DateTime (null si no es válida).
DateTime? parseFecha(String t) {
  final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), mes = int.parse(m[2]!), a = int.parse(m[3]!);
  final f = DateTime(a, mes, d);
  return (f.day == d && f.month == mes && f.year == a) ? f : null;
}
