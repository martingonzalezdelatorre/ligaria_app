import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/idioma.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';
import 'resultado_page.dart';

/// Botones para cerrar la liga (si está en curso) o reabrirla (si está finalizada).
/// Al finalizar, con [alFinalizar] se puede llevar a otra pantalla (p. ej. el resumen).
class AccionesCierreLiga extends ConsumerWidget {
  const AccionesCierreLiga({
    super.key,
    required this.liga,
    required this.escuelaId,
    this.alFinalizar,
  });
  final Liga liga;
  final String? escuelaId;
  final VoidCallback? alFinalizar;

  void _refrescar(WidgetRef ref) {
    ref.invalidate(orgLigasProvider(escuelaId ?? liga.organizationId ?? ''));
    ref.invalidate(orgClasificacionProvider(liga.id));
    ref.invalidate(orgEncuentrosProvider(liga.id));
  }

  Future<void> _finalizar(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(ligaRepositoryProvider);
    final encs = await ref.read(orgEncuentrosProvider(liga.id).future);
    final pendientes = encs.where((e) => !e.confirmado).length;
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.finalizarLiga),
        content: Text(
          '${context.l10n.finalizarLigaPregunta}'
          '${pendientes > 0 ? '\n\n${context.l10n.finalizarPendientes(pendientes)}' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancelar),
          ),
          FilledButton(
            key: const Key('confirmar-finalizar'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.finalizarLiga),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await repo.finalizarLiga(liga.id);
      _refrescar(ref);
      if (!context.mounted) return;
      avisar(context, context.l10n.avisoLigaFinalizada);
      alFinalizar?.call();
    } catch (e) {
      if (context.mounted) {
        avisar(
          context,
          mensajeError(e, defecto: context.l10n.errFinalizarLiga),
        );
      }
    }
  }

  Future<void> _reabrir(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(ligaRepositoryProvider).reabrirLiga(liga.id);
      _refrescar(ref);
      if (context.mounted) avisar(context, context.l10n.ligaReabierta);
    } catch (e) {
      if (context.mounted) {
        avisar(context, mensajeError(e, defecto: context.l10n.errReabrirLiga));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!liga.enCurso && !liga.finalizada) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: liga.enCurso
          ? FilledButton.icon(
              key: const Key('finalizar-liga'),
              icon: const Icon(Icons.flag_outlined),
              label: Text(context.l10n.finalizarLiga),
              onPressed: () => _finalizar(context, ref),
            )
          : OutlinedButton.icon(
              key: const Key('reabrir-liga'),
              icon: const Icon(Icons.lock_open_outlined),
              label: Text(context.l10n.reabrirLiga),
              onPressed: () => _reabrir(context, ref),
            ),
    );
  }
}

/// Pantalla de resumen de una liga: estado y progreso, cifras clave, campeones, clasificación,
/// próximos partidos y últimos resultados.
class ResumenLigaPage extends ConsumerWidget {
  const ResumenLigaPage({
    super.key,
    required this.liga,
    required this.escuelaId,
  });
  final Liga liga;
  final String escuelaId;

  static String _formato(AppL10n l, String f) => switch (f) {
    'ELIMINATORIA' => l.fmtEliminatoria,
    'MIXTO' => l.fmtMixto,
    _ => l.fmtLiga,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final viva =
        ref
            .watch(orgLigasProvider(escuelaId))
            .value
            ?.where((x) => x.id == liga.id)
            .firstOrNull ??
        liga;
    final clas = ref.watch(orgClasificacionProvider(liga.id)).value ?? const [];
    final insc = ref.watch(orgInscripcionesProvider(liga.id)).value;

    void abrir(EncuentroVista e) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultadoPage(escuelaId: escuelaId, encuentro: e),
      ),
    );

    Widget titulo(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
      child: Text(t, style: tema.textTheme.titleMedium),
    );

    Widget kpi(IconData icono, String valor, String etiqueta, {Key? key}) =>
        SizedBox(
          width: 150,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icono, size: 20, color: cs.primary),
                  const SizedBox(height: 8),
                  Text(
                    valor,
                    key: key,
                    style: tema.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    etiqueta,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.resumenLiga)),
      body: ContenidoCentrado(
        maxAncho: 900,
        child: AsyncView<List<EncuentroVista>>(
          value: ref.watch(orgEncuentrosProvider(liga.id)),
          onRetry: () => ref.invalidate(orgEncuentrosProvider(liga.id)),
          builder: (encs) {
            final r = resumenLiga(encs, clas);
            final equipos = insc == null
                ? clas.map((f) => f.equipoId).toSet().length
                : insc.where((i) => i.estado == 'aceptada').length;
            final aplazados = encs
                .where(
                  (e) => e.estado == 'aplazado' || e.estado == 'suspendido',
                )
                .length;
            final incomp = encs.where((e) => e.incomparecencia != null).length;
            final proximos = encs.where((e) => !e.confirmado).toList()
              ..sort((a, b) {
                if (a.fecha == null) return b.fecha == null ? 0 : 1;
                if (b.fecha == null) return -1;
                return a.fecha!.compareTo(b.fecha!);
              });
            final ultimos = encs.where((e) => e.confirmado).toList()
              ..sort((a, b) {
                final c = (b.fecha ?? DateTime(0)).compareTo(
                  a.fecha ?? DateTime(0),
                );
                return c != 0 ? c : b.jornada.compareTo(a.jornada);
              });
            final grupos = <(String, int?), List<FilaClasificacion>>{};
            for (final f in clas) {
              grupos.putIfAbsent((f.categoria ?? '', f.grupo), () => []).add(f);
            }
            final claves = grupos.keys.toList()
              ..sort(
                (a, b) => a.$1 != b.$1
                    ? a.$1.compareTo(b.$1)
                    : (a.$2 ?? 0).compareTo(b.$2 ?? 0),
              );
            final progreso = r.total == 0 ? 0.0 : r.jugados / r.total;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(viva.nombre, style: tema.textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Insignia(
                              etiquetaEstadoLiga(viva.estado),
                              color: viva.finalizada
                                  ? cs.primary
                                  : cs.secondary,
                              icono: viva.finalizada
                                  ? Icons.flag
                                  : Icons.play_circle_outline,
                            ),
                            if (viva.deporte != null)
                              Insignia(viva.deporte!, color: cs.tertiary),
                            Insignia(_formato(l, viva.formato)),
                            if (viva.fechaInicio != null)
                              Insignia(
                                [
                                  fechaLarga(viva.fechaInicio!),
                                  if (viva.fechaFin != null)
                                    fechaLarga(viva.fechaFin!),
                                ].join(' - '),
                                icono: Icons.event_outlined,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progreso,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.partidosJugadosDe(r.jugados, r.total),
                          key: const Key('resumen-progreso'),
                          style: tema.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    kpi(
                      Icons.groups_outlined,
                      '$equipos',
                      l.kpiEquipos,
                      key: const Key('kpi-equipos'),
                    ),
                    kpi(
                      Icons.category_outlined,
                      '${r.categorias.length}',
                      l.kpiCategorias,
                    ),
                    kpi(
                      Icons.pending_actions_outlined,
                      '${r.pendientes}',
                      l.kpiPendientes,
                    ),
                    kpi(
                      Icons.event_busy_outlined,
                      '$aplazados',
                      l.kpiAplazados,
                    ),
                    kpi(Icons.block, '$incomp', l.kpiIncomparecencias),
                  ],
                ),
                titulo(l.resCampeones),
                for (final c in r.categorias)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.emoji_events,
                        color: c.campeon == null
                            ? cs.onSurfaceVariant
                            : cs.primary,
                      ),
                      title: Text(
                        c.campeon == null
                            ? l.sinCampeonAun
                            : '${l.campeonTitulo}: ${c.campeon}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        [
                          if (c.categoria.isNotEmpty) c.categoria,
                          if (c.subcampeon != null)
                            '${l.subcampeonTitulo}: ${c.subcampeon}',
                        ].join(' · '),
                      ),
                    ),
                  ),
                if (clas.isNotEmpty && !viva.esEliminatoria) ...[
                  titulo(l.resClasificacion),
                  for (final k in claves)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (k.$1.isNotEmpty || k.$2 != null)
                              Text(
                                [
                                  if (k.$1.isNotEmpty) k.$1,
                                  if (k.$2 != null) nombreGrupo(k.$2!),
                                ].join(' · '),
                                style: tema.textTheme.labelLarge,
                              ),
                            for (final f
                                in (grupos[k]!..sort(
                                      (a, b) =>
                                          a.posicion.compareTo(b.posicion),
                                    ))
                                    .take(3))
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 14,
                                  child: Text('${f.posicion}'),
                                ),
                                title: Text(f.equipo),
                                subtitle: Text(f.escuela),
                                trailing: Text(
                                  '${f.puntos}',
                                  style: tema.textTheme.titleMedium,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
                titulo(l.resProximos),
                if (proximos.isEmpty)
                  Text(l.resSinProximos)
                else
                  for (final e in proximos.take(5))
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => abrir(e),
                        leading: Icon(
                          e.estado == 'aplazado' || e.estado == 'suspendido'
                              ? Icons.event_busy_outlined
                              : Icons.event_outlined,
                          color:
                              e.estado == 'aplazado' || e.estado == 'suspendido'
                              ? cs.error
                              : cs.primary,
                        ),
                        title: Text('${e.local} - ${e.visitante}'),
                        subtitle: Text(
                          [
                            fechaHoraCorta(e.fecha, conHora: e.conHora),
                            ?e.sede,
                            ?e.pista,
                            if (e.estado != 'programado')
                              etiquetaEstadoEncuentro(e.estado),
                          ].join(' · '),
                        ),
                      ),
                    ),
                titulo(l.resUltimos),
                if (ultimos.isEmpty)
                  Text(l.resSinResultados)
                else
                  for (final e in ultimos.take(5))
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => abrir(e),
                        leading: Icon(Icons.check_circle, color: cs.primary),
                        title: Text(
                          '${e.local} ${e.partidosLocal ?? '-'} - '
                          '${e.partidosVisitante ?? '-'} ${e.visitante}',
                        ),
                        subtitle: Text(e.etiquetaJornada),
                      ),
                    ),
                if (viva.enCurso || viva.finalizada) ...[
                  titulo(l.cierreLigaTitulo),
                  AccionesCierreLiga(liga: viva, escuelaId: escuelaId),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
