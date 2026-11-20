import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import '../../core/cuadro.dart';
import 'ajustes_liga.dart';
import 'organizador_providers.dart';
import 'resultado_page.dart';

/// Calendario y clasificación de una liga organizada.
class LigaDetallePage extends ConsumerWidget {
  const LigaDetallePage({super.key, required this.liga, required this.escuelaId, this.coorganizador = false});
  final Liga liga;
  final String escuelaId;
  final bool coorganizador; // gestiona la liga pero no asigna organizadores

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientes = ref.watch(orgInscripcionesProvider(liga.id)).value?.where((i) => i.pendiente).length ?? 0;
    final externas = liga.admiteEscuelasExternas;
    final conClasificacion = !liga.esEliminatoria; // un cuadro de eliminatoria no tiene tabla de puntos
    final pestanas = 3 + (externas ? 1 : 0) + (conClasificacion ? 1 : 0);
    return DefaultTabController(
      length: pestanas,
      child: Scaffold(
        appBar: AppBar(
          title: Text(liga.nombre),
          bottom: TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [
            Tab(text: liga.esEliminatoria ? 'Cuadro' : 'Calendario'),
            if (conClasificacion) const Tab(text: 'Clasificación'),
            Tab(text: pendientes > 0 ? 'Solicitudes ($pendientes)' : 'Solicitudes'),
            if (externas) const Tab(text: 'Escuelas'),
            const Tab(text: 'Ajustes'),
          ]),
        ),
        body: TabBarView(children: [
          _CalendarioTab(liga: liga, escuelaId: escuelaId),
          if (conClasificacion)
            AsyncView<List<FilaClasificacion>>(
              value: ref.watch(orgClasificacionProvider(liga.id)),
              onRetry: () => ref.invalidate(orgClasificacionProvider(liga.id)),
              builder: (filas) => filas.isEmpty
                  ? const EstadoVacio(icono: Icons.leaderboard_outlined, texto: 'Todavía no hay equipos inscritos.')
                  : SingleChildScrollView(child: ClasificacionPorCategoria(filas: filas)),
            ),
          _SolicitudesTab(liga: liga),
          if (externas) _EscuelasTab(liga: liga, escuelaId: escuelaId),
          AjustesLigaTab(liga: liga, coorganizador: coorganizador),
        ]),
      ),
    );
  }
}

/// Calendario (o cuadro) de la liga: una sección por jornada o ronda, separadas por categoría y grupo.
/// En una eliminatoria, bajo la primera ronda se indican los equipos que pasan directamente.
/// Con eliminatoria se puede alternar entre el cuadro dibujado (llaves) y la lista; en una eliminatoria
/// pura el cuadro es la vista inicial y en grupos + playoff lo es la lista.
class _CalendarioTab extends ConsumerStatefulWidget {
  const _CalendarioTab({required this.liga, required this.escuelaId});
  final Liga liga;
  final String escuelaId;

  @override
  ConsumerState<_CalendarioTab> createState() => _CalendarioTabState();
}

class _CalendarioTabState extends ConsumerState<_CalendarioTab> {
  bool? _cuadro; // null = vista inicial según el formato

  Liga get liga => widget.liga;
  String get escuelaId => widget.escuelaId;

  void _abrir(BuildContext context, EncuentroVista e) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => ResultadoPage(escuelaId: escuelaId, encuentro: e)));

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final byes = liga.formato == 'LIGA'
        ? const <Descanso>[]
        : ref.watch(orgByesProvider(liga.id)).maybeWhen(data: (l) => l, orElse: () => const <Descanso>[]);
    return AsyncView<List<EncuentroVista>>(
      value: ref.watch(orgEncuentrosProvider(liga.id)),
      onRetry: () => ref.invalidate(orgEncuentrosProvider(liga.id)),
      builder: (encs) {
        if (encs.isEmpty) {
          return EstadoVacio(
              icono: Icons.event_busy_outlined,
              texto: liga.esEliminatoria
                  ? 'Aún no hay cuadro.\nGénéralo desde la lista de ligas.'
                  : 'Aún no hay calendario.\nGénéralo desde la lista de ligas.');
        }
        final hayCuadro = encs.any((e) => e.esEliminatoria);
        final cuadro = hayCuadro && (_cuadro ?? liga.esEliminatoria);
        final secciones = agruparEncuentros(encs);
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (hayCuadro)
              SelectorVistaCuadro(
                cuadro: cuadro,
                etiquetaCuadro: liga.esMixto ? 'Playoff' : 'Llaves',
                onCambio: (v) => setState(() => _cuadro = v),
              ),
            if (cuadro)
              CuadrosEliminatoria(encuentros: encs, byes: byes, onTap: (e) => _abrir(context, e))
            else
            for (final g in secciones) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('${g.titulo} · ${fechaCorta(g.encuentros.first.fecha)}', style: tema.textTheme.titleSmall),
              ),
              if (g.esEliminatoria && g.jornada == 1)
                for (final b in byes.where((b) => b.jornada == 1 && (b.categoria ?? '') == g.categoria))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: Text('Pasa directo: ${b.equipo}',
                        style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
                  ),
              for (final e in g.encuentros) TarjetaEncuentro(encuentro: e, onTap: () => _abrir(context, e)),
            ],
          ],
        );
      },
    );
  }
}

/// Escuelas invitadas a la liga: invitar, ver su respuesta y retirar invitaciones.
class _EscuelasTab extends ConsumerWidget {
  const _EscuelasTab({required this.liga, required this.escuelaId});
  final Liga liga;
  final String escuelaId; // organización que organiza (no se invita a sí misma)

  Future<void> _invitar(BuildContext context, WidgetRef ref, List<InvitacionLiga> actuales) async {
    try {
      final todas = await ref.read(orgEscuelasInvitablesProvider.future);
      final yaInvitadas = actuales.map((i) => i.escuelaId).toSet();
      final libres = todas.where((e) => e.id != escuelaId && !yaInvitadas.contains(e.id)).toList();
      if (!context.mounted) return;
      final elegida = await elegirDeLista<EscuelaInvitable>(
        context,
        icono: Icons.mark_email_unread_outlined,
        titulo: 'Invitar escuela',
        subtitulo: liga.nombre,
        opciones: [for (final e in libres) (e, e.nombre, e.ciudad)],
        vacio: 'No hay más escuelas a las que invitar.',
      );
      if (elegida == null) return;
      await ref.read(ligaRepositoryProvider).invitarEscuela(liga.id, elegida.id);
      ref.invalidate(orgInvitacionesProvider(liga.id));
      if (context.mounted) avisar(context, 'Invitación enviada a ${elegida.nombre}.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo enviar la invitación.'));
    }
  }

  Future<void> _retirar(BuildContext context, WidgetRef ref, InvitacionLiga i) async {
    try {
      await ref.read(ligaRepositoryProvider).retirarInvitacion(liga.id, i.escuelaId);
      ref.invalidate(orgInvitacionesProvider(liga.id));
      if (context.mounted) avisar(context, 'Invitación a ${i.escuela} retirada.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo retirar la invitación.'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: ref.watch(orgInvitacionesProvider(liga.id)).maybeWhen(
            data: (l) => FloatingActionButton.extended(
              key: const Key('invitar-escuela'),
              onPressed: () => _invitar(context, ref, l),
              icon: const Icon(Icons.mark_email_unread_outlined),
              label: const Text('Invitar escuela'),
            ),
            orElse: () => null,
          ),
      body: AsyncView<List<InvitacionLiga>>(
        value: ref.watch(orgInvitacionesProvider(liga.id)),
        onRetry: () => ref.invalidate(orgInvitacionesProvider(liga.id)),
        builder: (lista) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(orgInvitacionesProvider(liga.id)),
          child: ListView(padding: const EdgeInsets.only(top: 8, bottom: 96), children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                liga.privada
                    ? 'Liga por invitación: solo participan las escuelas que inviten y acepten.'
                    : 'Liga abierta: cualquier escuela puede solicitar inscribir. También puedes invitar escuelas concretas.',
                style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
              ),
            ),
            if (lista.isEmpty)
              const EstadoVacio(icono: Icons.mark_email_unread_outlined, texto: 'Aún no has invitado a ninguna escuela.'),
            for (final i in lista)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: Text(i.escuela),
                  subtitle: Text([if (i.ciudad != null) i.ciudad!, etiquetaEstadoInvitacion(i.estado)].join(' · ')),
                  trailing: i.estado == 'aceptada'
                      ? null
                      : IconButton(
                          key: Key('retirar-${i.escuelaId}'),
                          tooltip: 'Retirar invitación',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => _retirar(context, ref, i),
                        ),
                ),
              ),
          ]),
        ),
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
                    Text(i.categoria == null ? i.escuela : '${i.escuela} · ${i.categoria}',
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
                subtitle: Text(i.categoria == null ? i.escuela : '${i.escuela} · ${i.categoria}'),
                trailing: Text(etiquetaEstadoInscripcion(i.estado)),
              ),
          ]),
        );
      },
    );
  }
}
