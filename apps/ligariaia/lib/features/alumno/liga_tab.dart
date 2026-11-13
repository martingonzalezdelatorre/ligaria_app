import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ilustraciones.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'alumno_providers.dart';

/// Lista desplazable con pull-to-refresh (también cuando está vacía).
class _Refrescable extends StatelessWidget {
  const _Refrescable({required this.onRefresh, required this.children});
  final Future<void> Function() onRefresh;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: children),
      );
}

Widget _vacio(IconData i, String t) => SizedBox(height: 320, child: EstadoVacio(icono: i, texto: t));

/// Pestaña «Liga»: el selector de ligas solo filtra la vista.
class LigaTab extends ConsumerStatefulWidget {
  const LigaTab({super.key});
  @override
  ConsumerState<LigaTab> createState() => _LigaTabState();
}

class _LigaTabState extends ConsumerState<LigaTab> {
  String? _ligaId;

  @override
  Widget build(BuildContext context) {
    final ligas = ref.watch(misLigasProvider);
    return AsyncView<List<Liga>>(
      value: ligas,
      onRetry: () => ref.invalidate(misLigasProvider),
      builder: (lista) {
        if (lista.isEmpty) {
          return const EstadoVacio(icono: Icons.emoji_events_outlined, texto: 'Aún no participas en ninguna liga.');
        }
        final actual = lista.firstWhere((l) => l.id == _ligaId, orElse: () => lista.first);
        return Column(children: [
          if (lista.length > 1)
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  for (final l in lista)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(l.nombre),
                        selected: l.id == actual.id,
                        showCheckmark: false,
                        avatar: Icon(l.deporte == 'Pádel' ? Icons.sports_tennis : Icons.sports_tennis_outlined, size: 18),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: l.id == actual.id ? Theme.of(context).colorScheme.onPrimary : null),
                        onSelected: (_) => setState(() => _ligaId = l.id),
                      ),
                    ),
                ],
              ),
            ),
          Aparece(child: ResumenLiga(key: ValueKey('r${actual.id}'), liga: actual, mostrarNombre: lista.length == 1)),
          Expanded(child: LigaDetalle(key: ValueKey(actual.id), liga: actual)),
        ]);
      },
    );
  }
}

class LigaDetalle extends ConsumerWidget {
  const LigaDetalle({super.key, required this.liga});
  final Liga liga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Column(children: [
        const PestanasPildora(desplazable: true, tabs: [
          Tab(text: 'Mi equipo'),
          Tab(text: 'Calendario'),
          Tab(text: 'Resultados'),
          Tab(text: 'Clasificación'),
        ]),
        Expanded(
          child: TabBarView(children: [
            _MiEquipo(liga: liga),
            _Calendario(liga: liga),
            _Resultados(liga: liga),
            _Clasificacion(liga: liga),
          ]),
        ),
      ]),
    );
  }
}

/// Ids de mis equipos en la liga (para resaltar).
Set<String> _misEquiposIds(WidgetRef ref, Liga liga) =>
    (ref.watch(misEquiposProvider).value ?? const <MiEquipo>[]).where((e) => e.ligaId == liga.id).map((e) => e.equipoId).toSet();

class _MiEquipo extends ConsumerWidget {
  const _MiEquipo({required this.liga});
  final Liga liga;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView<List<MiEquipo>>(
      value: ref.watch(misEquiposProvider),
      onRetry: () => ref.invalidate(misEquiposProvider),
      builder: (todos) {
        final mios = todos.where((e) => e.ligaId == liga.id).toList();
        return _Refrescable(
          onRefresh: () async {
            ref.invalidate(misEquiposProvider);
            await ref.read(misEquiposProvider.future);
          },
          children: [
            if (mios.isEmpty) _vacio(Icons.groups_outlined, 'No tienes equipo en esta liga.'),
            for (final e in mios)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: AvatarEquipo(e.equipo, tam: 46),
                  title: Text(e.equipo, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text('${e.escuela} · ${etiquetaRolEquipo(e.rol)}'),
                ),
              ),
          ],
        );
      },
    );
  }
}

String etiquetaRolEquipo(String rol) => switch (rol) {
      'entrenador' => 'Entrenador',
      'alumno' => 'Jugador',
      'tutor' => 'Familia',
      _ => rol,
    };

class _Calendario extends ConsumerWidget {
  const _Calendario({required this.liga});
  final Liga liga;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mios = _misEquiposIds(ref, liga);
    final descansos = ref.watch(descansosProvider(liga.id)).value ?? const <Descanso>[];
    return AsyncView<List<EncuentroVista>>(
      value: ref.watch(encuentrosProvider(liga.id)),
      onRetry: () => ref.invalidate(encuentrosProvider(liga.id)),
      builder: (encs) {
        final porJornada = <int, List<EncuentroVista>>{};
        for (final e in encs) {
          porJornada.putIfAbsent(e.jornada, () => []).add(e);
        }
        final jornadas = porJornada.keys.toList()..sort();
        return _Refrescable(
          onRefresh: () async {
            ref.invalidate(encuentrosProvider(liga.id));
            ref.invalidate(descansosProvider(liga.id));
            await ref.read(encuentrosProvider(liga.id).future);
          },
          children: [
            if (jornadas.isEmpty) _vacio(Icons.event_outlined, 'El calendario aún no está publicado.'),
            for (final j in jornadas) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Jornada $j', style: Theme.of(context).textTheme.titleSmall),
              ),
              for (final e in porJornada[j]!) TarjetaEncuentro(encuentro: e, destacados: mios),
              for (final d in descansos.where((d) => d.jornada == j))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Text('Descansa: ${d.equipo}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: mios.contains(d.equipoId) ? FontWeight.bold : null)),
                ),
            ],
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _Resultados extends ConsumerWidget {
  const _Resultados({required this.liga});
  final Liga liga;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mios = _misEquiposIds(ref, liga);
    return AsyncView<List<EncuentroVista>>(
      value: ref.watch(encuentrosProvider(liga.id)),
      onRetry: () => ref.invalidate(encuentrosProvider(liga.id)),
      builder: (encs) {
        final jugados = encs.where((e) => e.confirmado && e.tieneMarcador).toList()
          ..sort((a, b) => b.jornada.compareTo(a.jornada));
        return _Refrescable(
          onRefresh: () async {
            ref.invalidate(encuentrosProvider(liga.id));
            await ref.read(encuentrosProvider(liga.id).future);
          },
          children: [
            if (jugados.isEmpty) _vacio(Icons.scoreboard_outlined, 'Todavía no hay resultados confirmados.'),
            for (final e in jugados) TarjetaEncuentro(encuentro: e, destacados: mios),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _Clasificacion extends ConsumerWidget {
  const _Clasificacion({required this.liga});
  final Liga liga;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mios = _misEquiposIds(ref, liga);
    return AsyncView<List<FilaClasificacion>>(
      value: ref.watch(clasificacionProvider(liga.id)),
      onRetry: () => ref.invalidate(clasificacionProvider(liga.id)),
      builder: (filas) => _Refrescable(
        onRefresh: () async {
          ref.invalidate(clasificacionProvider(liga.id));
          await ref.read(clasificacionProvider(liga.id).future);
        },
        children: [
          if (filas.isEmpty)
            _vacio(Icons.leaderboard_outlined, 'La clasificación aparecerá cuando haya equipos inscritos.')
          else
            TablaClasificacion(filas: filas, destacados: mios),
        ],
      ),
    );
  }
}

/// Tarjeta principal de la liga: estado, mi equipo, posición, puntos y próximo partido.
class ResumenLiga extends ConsumerWidget {
  const ResumenLiga({super.key, required this.liga, this.mostrarNombre = true});
  final Liga liga;
  final bool mostrarNombre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mios = _misEquiposIds(ref, liga);
    final miEquipo = (ref.watch(misEquiposProvider).value ?? const <MiEquipo>[]).where((e) => e.ligaId == liga.id).firstOrNull;
    final filas = ref.watch(clasificacionProvider(liga.id)).value ?? const <FilaClasificacion>[];
    final fila = filas.where((f) => mios.contains(f.equipoId)).firstOrNull;
    final encs = ref.watch(encuentrosProvider(liga.id)).value ?? const <EncuentroVista>[];
    final proximo = encs.where((e) => !e.confirmado && (mios.contains(e.localId) || mios.contains(e.visitanteId))).firstOrNull;
    final rival = proximo == null ? null : (mios.contains(proximo.localId) ? proximo.visitante : proximo.local);
    final tema = Theme.of(context);

    Widget dato(String valor, String etiqueta, {IconData? icono}) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: tinta.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(etiqueta, style: tema.textTheme.labelSmall?.copyWith(color: tinta.withValues(alpha: .7), letterSpacing: .4)),
              const SizedBox(height: 2),
              Text(valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.titleLarge?.copyWith(color: tinta, fontWeight: FontWeight.w800)),
            ]),
          ),
        );

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [lima, Color(0xFF5FE08A)]),
        boxShadow: [BoxShadow(color: lima.withValues(alpha: .28), blurRadius: 36)],
      ),
      child: Stack(children: [
        const Positioned.fill(child: CustomPaint(painter: PistaPainter(opacidad: .16, grosor: 1.6))),
        const Positioned(right: 14, top: 10, child: BolaTenis(tam: 42)),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Insignia(etiquetaEstadoLiga(liga.estado), color: tinta, icono: Icons.bolt),
              if (liga.deporte != null) ...[
                const SizedBox(width: 8),
                Text(liga.deporte!, style: tema.textTheme.labelLarge?.copyWith(color: tinta.withValues(alpha: .75))),
              ],
            ]),
            const SizedBox(height: 12),
            if (mostrarNombre)
              Text(liga.nombre,
                  style: tema.textTheme.headlineSmall?.copyWith(color: tinta, fontWeight: FontWeight.w800, height: 1.1)),
            if (miEquipo != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  AvatarEquipo(miEquipo.equipo, tam: 26, destacado: true),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(miEquipo.equipo,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.titleMedium?.copyWith(color: tinta))),
                ]),
              ),
            const SizedBox(height: 14),
            Row(children: [
              dato(fila == null ? '—' : '${fila.posicion}º', 'PUESTO'),
              const SizedBox(width: 8),
              dato(fila == null ? '—' : '${fila.puntos}', 'PUNTOS'),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: tinta, borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('PRÓXIMO PARTIDO', style: tema.textTheme.labelSmall?.copyWith(color: Colors.white70, letterSpacing: .4)),
                    const SizedBox(height: 2),
                    Text(rival == null ? 'Sin fecha' : 'vs $rival',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.titleSmall?.copyWith(color: lima, fontWeight: FontWeight.w800)),
                    if (proximo != null)
                      Text(fechaCorta(proximo.fecha), style: tema.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                  ]),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
