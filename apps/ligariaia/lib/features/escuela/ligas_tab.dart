import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';
import 'primeros_pasos.dart';

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
    return AsyncView<List<LigaAbierta>>(
      value: datos,
      onRetry: () => ref.invalidate(ligasAbiertasProvider),
      builder: (lista) => lista.isEmpty && invitaciones.isEmpty
          ? EstadoVacio(
              icono: Icons.emoji_events_outlined,
              texto: context.l10n.sinLigasAbiertas,
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(ligasAbiertasProvider);
                ref.invalidate(misInvitacionesProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  if (invitaciones.isNotEmpty) ...[
                    _Titulo(context.l10n.invitacionesN(invitaciones.length)),
                    for (final i in invitaciones)
                      _TarjetaInvitacion(invitacion: i),
                    if (lista.isNotEmpty) _Titulo(context.l10n.ligasAbiertas),
                  ],
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
                        trailing: FilledButton.tonal(
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
      final equipos = await ref.read(equiposEscuelaProvider(escuelaId).future);
      final validos = equipos
          .where((e) => e.deporteId == liga.deporteId)
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
