import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';
import 'primeros_pasos.dart';
import '../alumno/alumno_providers.dart';
import '../alumno/liga_tab.dart' show LigaDetalle;

/// Ligas abiertas a inscripción (inscribir uno de mis equipos del mismo deporte) e
/// invitaciones de otras organizaciones pendientes de responder.
class LigasTab extends ConsumerWidget {
  const LigasTab({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(ligasAbiertasProvider);
    // Un fallo al cargar invitaciones no debe ocultar las ligas abiertas.
    final invitaciones = ref
        .watch(misInvitacionesProvider)
        .maybeWhen(
          data: (l) => l.where((i) => i.escuelaId == escuelaId).toList(),
          orElse: () => const <MiInvitacion>[],
        );
    // Tampoco un fallo al cargar mis participaciones o mis equipos debe ocultar las ligas abiertas.
    final participo = ref
        .watch(ligasParticipoProvider(escuelaId))
        .maybeWhen(
          data: (l) => l,
          orElse: () =>
              const <({Liga liga, List<InscripcionVista> inscripciones})>[],
        );
    final equipos = ref
        .watch(equiposEscuelaProvider(escuelaId))
        .maybeWhen(data: (l) => l, orElse: () => const <EquipoLite>[]);
    final inscripciones = ref
        .watch(inscripcionesEscuelaProvider(escuelaId))
        .maybeWhen(data: (l) => l, orElse: () => const <InscripcionVista>[]);

    /// ¿Hay equipos del deporte y todos están ya inscritos en la liga? Entonces no se ofrece «Inscribir».
    bool completa(LigaAbierta l) {
      final delDeporte = equipos.where((e) => e.deporteId == l.deporteId);
      final inscritos = {
        for (final i in inscripciones)
          if (i.ligaId == l.id) i.equipoId,
      };
      return delDeporte.isNotEmpty &&
          delDeporte.every((e) => inscritos.contains(e.id));
    }

    return AsyncView<List<LigaAbierta>>(
      value: datos,
      onRetry: () => ref.invalidate(ligasAbiertasProvider),
      builder: (lista) =>
          lista.isEmpty && invitaciones.isEmpty && participo.isEmpty
          ? EstadoVacio(
              icono: Icons.emoji_events_outlined,
              texto: context.l10n.sinLigasAbiertas,
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(ligasAbiertasProvider);
                ref.invalidate(misInvitacionesProvider);
                ref.invalidate(inscripcionesEscuelaProvider(escuelaId));
                ref.invalidate(ligasParticipoProvider(escuelaId));
              },
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  if (participo.isNotEmpty) ...[
                    _Titulo(context.l10n.ligasParticipo),
                    for (final p in participo)
                      _TarjetaParticipacion(
                        liga: p.liga,
                        inscripciones: p.inscripciones,
                      ),
                  ],
                  if (invitaciones.isNotEmpty) ...[
                    _Titulo(context.l10n.invitacionesN(invitaciones.length)),
                    for (final i in invitaciones)
                      _TarjetaInvitacion(invitacion: i),
                  ],
                  if (lista.isNotEmpty &&
                      (invitaciones.isNotEmpty || participo.isNotEmpty))
                    _Titulo(context.l10n.ligasAbiertas),
                  for (final l in lista)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          l.privada
                              ? Icons.mark_email_read_outlined
                              : Icons.emoji_events_outlined,
                        ),
                        title: Text(l.nombre),
                        subtitle: Text(
                          '${context.l10n.organizaPor(nombreDeporte(l.deporte), l.organizadora)}${l.privada ? ' · ${context.l10n.porInvitacion}' : ''}',
                        ),
                        trailing: completa(l)
                            ? Insignia(
                                key: Key('inscrita-${l.id}'),
                                context.l10n.equiposYaInscritos,
                                icono: Icons.check,
                              )
                            : FilledButton.tonal(
                                key: Key('inscribir-${l.id}'),
                                onPressed: () => _inscribir(context, ref, l),
                                child: Text(context.l10n.inscribir),
                              ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _inscribir(
    BuildContext context,
    WidgetRef ref,
    LigaAbierta liga,
  ) async {
    final repo = ref.read(ligaRepositoryProvider);
    try {
      // Consulta fresca: entre medias pueden haberse inscrito equipos desde otro dispositivo.
      final (equipos, todas) = await (
        ref.read(equiposEscuelaProvider(escuelaId).future),
        repo.inscripcionesEscuela(escuelaId),
      ).wait;
      final inscritos = {
        for (final i in todas)
          if (i.ligaId == liga.id) i.equipoId,
      };
      // Solo equipos del deporte de la liga que aún no estén inscritos en ella.
      final validos = equipos
          .where(
            (e) => e.deporteId == liga.deporteId && !inscritos.contains(e.id),
          )
          .toList();
      if (!context.mounted) return;
      final id = await elegirDeLista<String>(
        context,
        icono: Icons.emoji_events_outlined,
        titulo: context.l10n.inscribirEquipo,
        subtitulo: liga.nombre,
        opciones: [for (final e in validos) (e.id, e.nombre, null)],
        vacio: context.l10n.sinEquiposDeporte(nombreDeporte(liga.deporte)),
      );
      if (id == null) return;
      if (!context.mounted) return;
      final cat = await elegirCategoria(context, repo, liga.id, liga.nombre);
      if (!cat.ok) return;
      final estado = cat.id == null
          ? await repo.inscribirEquipo(liga.id, id)
          : await repo.inscribirEquipo(liga.id, id, categoriaId: cat.id);
      ref.invalidate(inscripcionesOrgProvider(escuelaId));
      ref.invalidate(inscripcionesEscuelaProvider(escuelaId));
      ref.invalidate(ligasParticipoProvider(escuelaId));
      if (context.mounted) {
        avisar(
          context,
          estado == 'pendiente'
              ? context.l10n.solicitudEnviada(liga.organizadora)
              : context.l10n.equipoInscrito(liga.nombre),
        );
      }
    } catch (e) {
      if (context.mounted) avisar(context, mensajeErrorEscuela(e));
    }
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
    child: Text(texto, style: Theme.of(context).textTheme.titleSmall),
  );
}

/// Invitación de otra organización a participar en su liga: aceptar o rechazar.
class _TarjetaInvitacion extends ConsumerWidget {
  const _TarjetaInvitacion({required this.invitacion});
  final MiInvitacion invitacion;

  Future<void> _responder(
    BuildContext context,
    WidgetRef ref,
    bool aceptar,
  ) async {
    try {
      await ref
          .read(ligaRepositoryProvider)
          .responderInvitacion(
            invitacion.ligaId,
            invitacion.escuelaId,
            aceptar: aceptar,
          );
      ref.invalidate(misInvitacionesProvider);
      ref.invalidate(ligasAbiertasProvider);
      if (context.mounted) {
        avisar(
          context,
          aceptar
              ? context.l10n.invitacionAceptada(invitacion.nombre)
              : context.l10n.invitacionRechazada,
        );
      }
    } catch (e) {
      if (context.mounted) avisar(context, mensajeErrorEscuela(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mark_email_unread_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    invitacion.nombre,
                    style: tema.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.teInvita(
                nombreDeporte(invitacion.deporte),
                invitacion.organizadora,
              ),
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  key: Key('aceptar-invitacion-${invitacion.ligaId}'),
                  icon: const Icon(Icons.check),
                  label: Text(context.l10n.aceptar),
                  onPressed: () => _responder(context, ref, true),
                ),
                OutlinedButton.icon(
                  key: Key('rechazar-invitacion-${invitacion.ligaId}'),
                  icon: const Icon(Icons.close),
                  label: Text(context.l10n.rechazar),
                  onPressed: () => _responder(context, ref, false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Liga de otro organizador en la que participa la escuela: sus equipos y el estado de cada inscripción.
class _TarjetaParticipacion extends StatelessWidget {
  const _TarjetaParticipacion({
    required this.liga,
    required this.inscripciones,
  });
  final Liga liga;
  final List<InscripcionVista> inscripciones;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: ListTile(
        key: Key('participo-${liga.id}'),
        leading: const Icon(Icons.emoji_events),
        title: Text(liga.nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${nombreDeporte(liga.deporte)} · ${etiquetaEstadoLiga(liga.estado)}',
            ),
            const SizedBox(height: 4),
            for (final i in inscripciones)
              Text(
                '${i.equipo}${i.categoria == null ? '' : ' (${i.categoria})'}'
                ' · ${etiquetaEstadoInscripcion(i.estado)}',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: i.estado == 'rechazada'
                      ? tema.colorScheme.error
                      : tema.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                LigaParticipoPage(liga: liga, inscripciones: inscripciones),
          ),
        ),
      ),
    );
  }
}

/// Calendario, resultados y clasificación (solo lectura) de una liga en la que participa la escuela.
/// Reutiliza la vista de liga de alumnos y familias, con los equipos de la escuela como «mis equipos».
class LigaParticipoPage extends StatelessWidget {
  const LigaParticipoPage({
    super.key,
    required this.liga,
    required this.inscripciones,
  });
  final Liga liga;
  final List<InscripcionVista> inscripciones;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      misEquiposProvider.overrideWith(
        (ref) async => [
          for (final i in inscripciones)
            MiEquipo(
              equipoId: i.equipoId,
              equipo: i.equipo,
              escuelaId: i.escuelaId,
              escuela: i.categoria ?? liga.nombre,
              rol: etiquetaEstadoInscripcion(i.estado),
              ligaId: liga.id,
              liga: liga.nombre,
            ),
        ],
      ),
    ],
    child: Scaffold(
      appBar: AppBar(title: Text(liga.nombre)),
      body: LigaDetalle(liga: liga),
    ),
  );
}
