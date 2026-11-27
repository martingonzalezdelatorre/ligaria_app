import '../../core/idioma.dart';
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
import 'resumen_liga_page.dart';

/// Calendario y clasificación de una liga organizada.
class LigaDetallePage extends ConsumerWidget {
  const LigaDetallePage({
    super.key,
    required this.liga,
    required this.escuelaId,
    this.coorganizador = false,
  });
  final Liga liga;
  final String escuelaId;
  final bool coorganizador; // gestiona la liga pero no asigna organizadores

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // La liga viva (el estado o los desempates pueden cambiar mientras se gestiona).
    final liga =
        ref
            .watch(orgLigasProvider(escuelaId))
            .value
            ?.where((l) => l.id == this.liga.id)
            .firstOrNull ??
        this.liga;
    final pendientes =
        ref
            .watch(orgInscripcionesProvider(liga.id))
            .value
            ?.where((i) => i.pendiente)
            .length ??
        0;
    final externas = liga.admiteEscuelasExternas;
    final conClasificacion = !liga
        .esEliminatoria; // un cuadro de eliminatoria no tiene tabla de puntos
    final pestanas = 3 + (externas ? 1 : 0) + (conClasificacion ? 1 : 0);
    return DefaultTabController(
      length: pestanas,
      child: _FondoSuave(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: Text(liga.nombre),
            actions: [
              IconButton(
                key: const Key('abrir-resumen'),
                tooltip: context.l10n.resumenLiga,
                icon: const Icon(Icons.insights_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ResumenLigaPage(liga: liga, escuelaId: escuelaId),
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(
                  text: liga.esEliminatoria
                      ? context.l10n.tabCuadro
                      : context.l10n.tabCalendario,
                ),
                if (conClasificacion) Tab(text: context.l10n.clasificacion),
                Tab(
                  text: pendientes > 0
                      ? context.l10n.tabSolicitudesN(pendientes)
                      : context.l10n.tabSolicitudes,
                ),
                if (externas) Tab(text: context.l10n.tabEscuelas),
                Tab(text: context.l10n.tabAjustes),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _CalendarioTab(liga: liga, escuelaId: escuelaId),
              if (conClasificacion)
                AsyncView<List<FilaClasificacion>>(
                  value: ref.watch(orgClasificacionProvider(liga.id)),
                  onRetry: () =>
                      ref.invalidate(orgClasificacionProvider(liga.id)),
                  builder: (filas) => filas.isEmpty
                      ? EstadoVacio(
                          icono: Icons.leaderboard_outlined,
                          texto: context.l10n.sinEquiposInscritos,
                        )
                      : SingleChildScrollView(
                          child: ClasificacionPorCategoria(filas: filas),
                        ),
                ),
              _SolicitudesTab(liga: liga),
              if (externas) _EscuelasTab(liga: liga, escuelaId: escuelaId),
              AjustesLigaTab(
                liga: liga,
                coorganizador: coorganizador,
                escuelaId: escuelaId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fondo de la pantalla de liga: auroras suaves fijas (en claro, salvia y arena; en oscuro, menta, naranja y lima).
/// Mismo aire que [FondoBlobs] pero sin animación continua (más ligero y sin timers en los tests).
class _FondoSuave extends StatelessWidget {
  const _FondoSuave({required this.child});
  final Widget child;

  static Widget _aurora(Alignment c, double radio, Color color) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: c,
        radius: radio,
        colors: [color, color.withValues(alpha: 0)],
      ),
    ),
    child: const SizedBox.expand(),
  );

  @override
  Widget build(BuildContext context) {
    final claro = Theme.of(context).brightness == Brightness.light;
    return ColoredBox(
      color: claro ? fondoClaro : tinta,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _aurora(
            const Alignment(-1, -.8),
            1.1,
            claro
                ? acentoClaro.withValues(alpha: .30)
                : menta.withValues(alpha: .45),
          ),
          _aurora(
            const Alignment(1, -.5),
            .9,
            (claro ? arenaClaro : const Color(0xFFFF8A3D))
                .withValues(alpha: .28),
          ),
          _aurora(
            const Alignment(.4, 1.1),
            1.2,
            claro
                ? arenaClaroSuave.withValues(alpha: .45)
                : lima.withValues(alpha: .18),
          ),
          child,
        ],
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

  void _abrir(BuildContext context, EncuentroVista e) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultadoPage(escuelaId: escuelaId, encuentro: e),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final byes = liga.formato == 'LIGA'
        ? const <Descanso>[]
        : ref
              .watch(orgByesProvider(liga.id))
              .maybeWhen(data: (l) => l, orElse: () => const <Descanso>[]);
    return AsyncView<List<EncuentroVista>>(
      value: ref.watch(orgEncuentrosProvider(liga.id)),
      onRetry: () => ref.invalidate(orgEncuentrosProvider(liga.id)),
      builder: (encs) {
        if (encs.isEmpty) {
          return EstadoVacio(
            icono: Icons.event_busy_outlined,
            texto: liga.esEliminatoria
                ? context.l10n.sinCuadro
                : context.l10n.sinCalendario,
          );
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
                etiquetaCuadro: liga.esMixto
                    ? context.l10n.playoff
                    : context.l10n.llaves,
                onCambio: (v) => setState(() => _cuadro = v),
              ),
            if (cuadro)
              CuadrosEliminatoria(
                encuentros: encs,
                byes: byes,
                onTap: (e) => _abrir(context, e),
              )
            else
              for (final g in secciones) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    '${g.titulo} · ${fechaCorta(g.encuentros.first.fecha)}',
                    style: tema.textTheme.titleSmall,
                  ),
                ),
                if (g.esEliminatoria && g.jornada == 1)
                  for (final b in byes.where(
                    (b) => b.jornada == 1 && (b.categoria ?? '') == g.categoria,
                  ))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      child: Text(
                        context.l10n.pasaDirecto(b.equipo),
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                for (final e in g.encuentros)
                  TarjetaEncuentro(
                    encuentro: e,
                    onTap: () => _abrir(context, e),
                  ),
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

  Future<void> _invitar(
    BuildContext context,
    WidgetRef ref,
    List<InvitacionLiga> actuales,
  ) async {
    try {
      final todas = await ref.read(orgEscuelasInvitablesProvider.future);
      final yaInvitadas = actuales.map((i) => i.escuelaId).toSet();
      final libres = todas
          .where((e) => e.id != escuelaId && !yaInvitadas.contains(e.id))
          .toList();
      if (!context.mounted) return;
      final elegida = await elegirDeLista<EscuelaInvitable>(
        context,
        icono: Icons.mark_email_unread_outlined,
        titulo: context.l10n.invitarEscuela,
        subtitulo: liga.nombre,
        opciones: [for (final e in libres) (e, e.nombre, e.ciudad)],
        vacio: context.l10n.sinMasEscuelas,
      );
      if (elegida == null) return;
      await ref
          .read(ligaRepositoryProvider)
          .invitarEscuela(liga.id, elegida.id);
      ref.invalidate(orgInvitacionesProvider(liga.id));
      if (context.mounted) {
        avisar(context, context.l10n.invitacionEnviadaA(elegida.nombre));
      }
    } catch (e) {
      if (context.mounted) {
        avisar(
          context,
          mensajeError(e, defecto: context.l10n.errEnviarInvitacion),
        );
      }
    }
  }

  Future<void> _retirar(
    BuildContext context,
    WidgetRef ref,
    InvitacionLiga i,
  ) async {
    try {
      await ref
          .read(ligaRepositoryProvider)
          .retirarInvitacion(liga.id, i.escuelaId);
      ref.invalidate(orgInvitacionesProvider(liga.id));
      if (context.mounted) {
        avisar(context, context.l10n.invitacionRetiradaDe(i.escuela));
      }
    } catch (e) {
      if (context.mounted) {
        avisar(
          context,
          mensajeError(e, defecto: context.l10n.errRetirarInvitacion),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: ref
          .watch(orgInvitacionesProvider(liga.id))
          .maybeWhen(
            data: (l) => FloatingActionButton.extended(
              key: const Key('invitar-escuela'),
              onPressed: () => _invitar(context, ref, l),
              icon: const Icon(Icons.mark_email_unread_outlined),
              label: Text(context.l10n.invitarEscuela),
            ),
            orElse: () => null,
          ),
      body: AsyncView<List<InvitacionLiga>>(
        value: ref.watch(orgInvitacionesProvider(liga.id)),
        onRetry: () => ref.invalidate(orgInvitacionesProvider(liga.id)),
        builder: (lista) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(orgInvitacionesProvider(liga.id)),
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 96),
            children: [
              _TarjetaInfoEscuelas(privada: liga.privada),
              if (lista.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: EstadoVacio(
                    icono: Icons.mark_email_unread_outlined,
                    texto: context.l10n.sinEscuelasInvitadas,
                  ),
                ),
              for (final i in lista)
                _TarjetaInvitacion(
                  i: i,
                  onRetirar: () => _retirar(context, ref, i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabecera de la pestaña Escuelas: explica cómo participan las escuelas en la liga.
class _TarjetaInfoEscuelas extends StatelessWidget {
  const _TarjetaInfoEscuelas({required this.privada});
  final bool privada;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final marca = Marca.de(context);
    final cs = t.colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: marca.borde),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              privada ? Icons.lock_outline_rounded : Icons.public_rounded,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  privada
                      ? context.l10n.ligaPorInvitacion
                      : context.l10n.ligaAbierta,
                  style: t.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  privada
                      ? context.l10n.visPrivadaDesc
                      : context.l10n.ligaAbiertaAyuda,
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Una escuela invitada: avatar, ciudad, estado de su respuesta y botón para retirar la invitación.
class _TarjetaInvitacion extends StatelessWidget {
  const _TarjetaInvitacion({required this.i, required this.onRetirar});
  final InvitacionLiga i;
  final VoidCallback onRetirar;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final marca = Marca.de(context);
    final (color, icono) = switch (i.estado) {
      'aceptada' => (
        const Color(0xFF3DDC84),
        Icons.check_circle_outline_rounded,
      ),
      'rechazada' => (const Color(0xFFFF8A80), Icons.cancel_outlined),
      _ => (const Color(0xFFFFC857), Icons.schedule_rounded),
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: marca.borde),
      ),
      child: Row(
        children: [
          AvatarEquipo(i.escuela, tam: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i.escuela,
                  style: t.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (i.ciudad != null)
                  Text(
                    i.ciudad!,
                    style: t.textTheme.bodySmall?.copyWith(
                      color: t.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 6),
                Insignia(
                  etiquetaEstadoInvitacion(i.estado),
                  color: color,
                  icono: icono,
                ),
              ],
            ),
          ),
          if (i.estado != 'aceptada')
            IconButton(
              key: Key('retirar-${i.escuelaId}'),
              tooltip: context.l10n.retirarInvitacion,
              icon: const Icon(Icons.close_rounded),
              onPressed: onRetirar,
            ),
        ],
      ),
    );
  }
}

/// Solicitudes de inscripción: el organizador acepta o rechaza los equipos de otras escuelas.
class _SolicitudesTab extends ConsumerWidget {
  const _SolicitudesTab({required this.liga});
  final Liga liga;

  Future<void> _resolver(
    BuildContext context,
    WidgetRef ref,
    InscripcionVista i,
    bool aceptar,
  ) async {
    try {
      await ref
          .read(ligaRepositoryProvider)
          .resolverInscripcion(i.id, aceptar: aceptar);
      ref.invalidate(orgInscripcionesProvider(liga.id));
      ref.invalidate(orgClasificacionProvider(liga.id));
      if (context.mounted) {
        avisar(
          context,
          aceptar
              ? context.l10n.equipoAceptado(i.equipo)
              : context.l10n.solicitudRechazada(i.equipo),
        );
      }
    } catch (e) {
      if (context.mounted) {
        avisar(
          context,
          mensajeError(e, defecto: context.l10n.errResolverSolicitud),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView<List<InscripcionVista>>(
      value: ref.watch(orgInscripcionesProvider(liga.id)),
      onRetry: () => ref.invalidate(orgInscripcionesProvider(liga.id)),
      builder: (lista) {
        if (lista.isEmpty) {
          return EstadoVacio(
            icono: Icons.how_to_reg_outlined,
            texto: context.l10n.sinSolicitudes,
          );
        }
        final pendientes = lista.where((i) => i.pendiente).toList();
        final resueltas = lista.where((i) => !i.pendiente).toList();
        final tema = Theme.of(context);
        Widget titulo(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(t, style: tema.textTheme.titleSmall),
        );
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(orgInscripcionesProvider(liga.id)),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              titulo(context.l10n.pendientesN(pendientes.length)),
              if (pendientes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    context.l10n.sinPendientes,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              for (final i in pendientes)
                Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.equipo, style: tema.textTheme.titleMedium),
                        Text(
                          i.categoria == null
                              ? i.escuela
                              : '${i.escuela} · ${i.categoria}',
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilledButton.icon(
                              key: Key('aceptar-${i.id}'),
                              icon: const Icon(Icons.check),
                              label: Text(context.l10n.aceptar),
                              onPressed: () => _resolver(context, ref, i, true),
                            ),
                            OutlinedButton.icon(
                              key: Key('rechazar-${i.id}'),
                              icon: const Icon(Icons.close),
                              label: Text(context.l10n.rechazar),
                              onPressed: () =>
                                  _resolver(context, ref, i, false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (resueltas.isNotEmpty) titulo(context.l10n.resueltas),
              for (final i in resueltas)
                ListTile(
                  title: Text(i.equipo),
                  subtitle: Text(
                    i.categoria == null
                        ? i.escuela
                        : '${i.escuela} · ${i.categoria}',
                  ),
                  trailing: Text(etiquetaEstadoInscripcion(i.estado)),
                ),
            ],
          ),
        );
      },
    );
  }
}
