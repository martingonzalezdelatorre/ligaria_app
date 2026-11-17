import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';
import 'resultado_page.dart';

/// Calendario y clasificación de una liga organizada.
class LigaDetallePage extends ConsumerWidget {
  const LigaDetallePage({super.key, required this.liga, required this.escuelaId});
  final Liga liga;
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientes = ref.watch(orgInscripcionesProvider(liga.id)).value?.where((i) => i.pendiente).length ?? 0;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(liga.nombre),
          bottom: TabBar(tabs: [
            const Tab(text: 'Calendario'),
            const Tab(text: 'Clasificación'),
            Tab(text: pendientes > 0 ? 'Solicitudes ($pendientes)' : 'Solicitudes'),
          ]),
        ),
        body: TabBarView(children: [
          AsyncView<List<EncuentroVista>>(
            value: ref.watch(orgEncuentrosProvider(liga.id)),
            onRetry: () => ref.invalidate(orgEncuentrosProvider(liga.id)),
            builder: (encs) {
              if (encs.isEmpty) {
                return const EstadoVacio(icono: Icons.event_busy_outlined, texto: 'Aún no hay calendario.\nGénéralo desde la lista de ligas.');
              }
              final porJornada = <int, List<EncuentroVista>>{};
              for (final e in encs) {
                porJornada.putIfAbsent(e.jornada, () => []).add(e);
              }
              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  for (final j in porJornada.keys.toList()..sort()) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text('Jornada $j · ${fechaCorta(porJornada[j]!.first.fecha)}',
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    for (final e in porJornada[j]!)
                      TarjetaEncuentro(
                        encuentro: e,
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => ResultadoPage(escuelaId: escuelaId, encuentro: e))),
                      ),
                  ],
                ],
              );
            },
          ),
          AsyncView<List<FilaClasificacion>>(
            value: ref.watch(orgClasificacionProvider(liga.id)),
            onRetry: () => ref.invalidate(orgClasificacionProvider(liga.id)),
            builder: (filas) => filas.isEmpty
                ? const EstadoVacio(icono: Icons.leaderboard_outlined, texto: 'Todavía no hay equipos inscritos.')
                : SingleChildScrollView(child: TablaClasificacion(filas: filas)),
          ),
          _SolicitudesTab(liga: liga),
        ]),
      ),
    );
  }
}

/// Solicitudes de inscripción: el organizador acepta o rechaza los equipos de otras escuelas.
class _SolicitudesTab extends ConsumerWidget {
  const _SolicitudesTab({required this.liga});
  final Liga liga;

  Future<void> _resolver(BuildContext context, WidgetRef ref, InscripcionVista i, bool aceptar) async {
    try {
      await ref.read(ligaRepositoryProvider).resolverInscripcion(i.id, aceptar: aceptar);
      ref.invalidate(orgInscripcionesProvider(liga.id));
      ref.invalidate(orgClasificacionProvider(liga.id));
      if (context.mounted) {
        avisar(context, aceptar ? '${i.equipo} aceptado en la liga.' : 'Solicitud de ${i.equipo} rechazada.');
      }
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo resolver la solicitud.'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView<List<InscripcionVista>>(
      value: ref.watch(orgInscripcionesProvider(liga.id)),
      onRetry: () => ref.invalidate(orgInscripcionesProvider(liga.id)),
      builder: (lista) {
        if (lista.isEmpty) {
          return const EstadoVacio(icono: Icons.how_to_reg_outlined, texto: 'Todavía no hay solicitudes de inscripción.');
        }
        final pendientes = lista.where((i) => i.pendiente).toList();
        final resueltas = lista.where((i) => !i.pendiente).toList();
        final tema = Theme.of(context);
        Widget titulo(String t) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(t, style: tema.textTheme.titleSmall),
            );
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(orgInscripcionesProvider(liga.id)),
          child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
            titulo('Pendientes (${pendientes.length})'),
            if (pendientes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('No hay solicitudes pendientes.',
                    style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
              ),
            for (final i in pendientes)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(i.equipo, style: tema.textTheme.titleMedium),
                    Text(i.escuela,
                        style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: [
                      FilledButton.icon(
                        key: Key('aceptar-${i.id}'),
                        icon: const Icon(Icons.check),
                        label: const Text('Aceptar'),
                        onPressed: () => _resolver(context, ref, i, true),
                      ),
                      OutlinedButton.icon(
                        key: Key('rechazar-${i.id}'),
                        icon: const Icon(Icons.close),
                        label: const Text('Rechazar'),
                        onPressed: () => _resolver(context, ref, i, false),
                      ),
                    ]),
                  ]),
                ),
              ),
            if (resueltas.isNotEmpty) titulo('Resueltas'),
            for (final i in resueltas)
              ListTile(
                title: Text(i.equipo),
                subtitle: Text(i.escuela),
                trailing: Text(etiquetaEstadoInscripcion(i.estado)),
              ),
          ]),
        );
      },
    );
  }
}
