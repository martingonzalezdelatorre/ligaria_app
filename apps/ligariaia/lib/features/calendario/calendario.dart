import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/idioma.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import '../alumno/alumno_providers.dart';
import '../partido/detalle_partido_page.dart';

/// Entrenos de mis equipos (los que asigna el entrenador), por fecha.
final misEntrenosProvider = FutureProvider<List<Entreno>>(
  (ref) => ref.watch(ligaRepositoryProvider).misEntrenos(),
);

/// Un elemento del calendario: un entreno o un partido de uno de mis equipos.
class ItemAgenda {
  ItemAgenda.entreno(Entreno e)
    : entreno = e,
      encuentro = null,
      fecha = e.fecha;
  ItemAgenda.partido(EncuentroVista e)
    : entreno = null,
      encuentro = e,
      fecha = e.fecha;
  final Entreno? entreno;
  final EncuentroVista? encuentro;

  /// Cuándo es (un partido sin fecha asignada queda en null).
  final DateTime? fecha;
  bool get esEntreno => entreno != null;
}

/// Entrenos y partidos de mis equipos, ordenados por fecha (los partidos sin fecha, al final).
final agendaProvider = FutureProvider<List<ItemAgenda>>((ref) async {
  final equipos = await ref.watch(misEquiposProvider.future);
  final mios = {for (final e in equipos) e.equipoId};
  final ligaIds = {
    for (final e in equipos)
      if (e.ligaId != null) e.ligaId!,
  };

  final items = <ItemAgenda>[];
  for (final id in ligaIds) {
    final encs = await ref.watch(encuentrosProvider(id).future);
    items.addAll(
      encs
          .where(
            (e) => mios.contains(e.localId) || mios.contains(e.visitanteId),
          )
          .map(ItemAgenda.partido),
    );
  }
  try {
    items.addAll(
      (await ref.watch(misEntrenosProvider.future)).map(ItemAgenda.entreno),
    );
  } catch (e) {
    // los partidos se muestran aunque no se puedan leer los entrenos
    debugPrint('Calendario: no se pudieron cargar los entrenos: $e');
  }
  items.sort((a, b) {
    if (a.fecha == null || b.fecha == null) {
      return a.fecha == null ? (b.fecha == null ? 0 : 1) : -1;
    }
    return a.fecha!.compareTo(b.fecha!);
  });
  return items;
});

final _misEquiposIdsProvider = Provider<Set<String>>(
  (ref) => {
    for (final e in ref.watch(misEquiposProvider).value ?? const <MiEquipo>[])
      e.equipoId,
  },
);

/// Pestaña «Calendario»: próximos entrenos y partidos agrupados por día, y los anteriores al final.
class CalendarioTab extends ConsumerWidget {
  const CalendarioTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final mios = ref.watch(_misEquiposIdsProvider);
    return AsyncView<List<ItemAgenda>>(
      value: ref.watch(agendaProvider),
      onRetry: () => ref.invalidate(agendaProvider),
      builder: (items) {
        final ahora = DateTime.now();
        final hoy = DateTime(ahora.year, ahora.month, ahora.day);
        final proximos = items
            .where((i) => i.fecha != null && !i.fecha!.isBefore(hoy))
            .toList();
        final sinFecha = items.where((i) => i.fecha == null).toList();
        final pasados = items
            .where((i) => i.fecha != null && i.fecha!.isBefore(hoy))
            .toList()
            .reversed
            .toList();

        Widget titulo(String t, {double arriba = 16}) => Padding(
          padding: EdgeInsets.fromLTRB(16, arriba, 16, 6),
          child: Text(
            t,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        );
        Widget tarjeta(ItemAgenda i) => TarjetaAgenda(item: i, mios: mios);

        final children = <Widget>[];
        DateTime? dia;
        if (proximos.isNotEmpty) children.add(titulo(l.agendaProximos));
        for (final i in proximos) {
          if (dia == null || !mismoDia(dia, i.fecha!)) {
            dia = i.fecha;
            children.add(_CabeceraDia(fecha: i.fecha!));
          }
          children.add(tarjeta(i));
        }
        if (sinFecha.isNotEmpty) {
          children.add(titulo(l.sinFecha));
          children.addAll(sinFecha.map(tarjeta));
        }
        if (pasados.isNotEmpty) {
          children.add(titulo(l.agendaAnteriores, arriba: 24));
          children.addAll(pasados.take(20).map(tarjeta));
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(misEntrenosProvider);
            ref.invalidate(misEquiposProvider);
            ref.invalidate(agendaProvider);
            await ref.read(agendaProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: items.isEmpty
                ? [
                    SizedBox(
                      height: 360,
                      child: EstadoVacio(
                        icono: Icons.calendar_month_outlined,
                        texto: l.agendaVacia,
                      ),
                    ),
                  ]
                : children,
          ),
        );
      },
    );
  }
}

class _CabeceraDia extends StatelessWidget {
  const _CabeceraDia({required this.fecha});
  final DateTime fecha;
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Text(
        etiquetaDia(fecha).toUpperCase(),
        style: tema.textTheme.labelMedium?.copyWith(
          color: tema.colorScheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
        ),
      ),
    );
  }
}

/// Tarjeta del calendario: hora a la izquierda y, a la derecha, qué es, dónde y contra quién.
/// Un partido abre su detalle; un entreno ya muestra todo en la tarjeta.
class TarjetaAgenda extends StatelessWidget {
  const TarjetaAgenda({super.key, required this.item, this.mios = const {}});
  final ItemAgenda item;
  final Set<String> mios;

  @override
  Widget build(BuildContext context) {
    final e = item.encuentro;
    if (e == null) return TarjetaEntreno(entreno: item.entreno!);
    final l = context.l10n;
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final lugar = [?e.sede, ?e.pista].join(' · ');
    Widget equipo(String id, String nombre) => Text(
      nombre,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: tema.textTheme.titleSmall?.copyWith(
        fontWeight: mios.contains(id) ? FontWeight.w800 : FontWeight.w500,
      ),
    );
    return _BaseTarjeta(
      color: cs.primary,
      hora: e.conHora && e.fecha != null ? horaCorta(e.fecha!) : null,
      fecha: e.fecha,
      trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetallePartidoPage(encuentro: e, destacados: mios),
        ),
      ),
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            Insignia(
              l.partidoEtiqueta,
              color: cs.primary,
              icono: Icons.sports_tennis,
            ),
            Insignia(e.etiquetaJornada, color: cs.secondary),
            if (e.estado == 'aplazado' || e.estado == 'suspendido')
              Insignia(
                etiquetaEstadoEncuentro(e.estado),
                color: cs.error,
                icono: Icons.event_busy_outlined,
              ),
          ],
        ),
        const SizedBox(height: 8),
        equipo(e.localId, e.local),
        Text(
          'vs',
          style: tema.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        equipo(e.visitanteId, e.visitante),
        const SizedBox(height: 6),
        _Dato(
          Icons.place_outlined,
          lugar.isEmpty ? l.lugarPorConfirmar : lugar,
          apagado: lugar.isEmpty,
        ),
        if (!e.conHora)
          _Dato(Icons.schedule, l.horaPorConfirmar, apagado: true),
      ],
    );
  }
}

/// Entreno que asigna el entrenador: equipo, hora, duración, lugar y notas.
class TarjetaEntreno extends StatelessWidget {
  const TarjetaEntreno({super.key, required this.entreno, this.trailing});
  final Entreno entreno;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final en = entreno;
    return _BaseTarjeta(
      color: cs.tertiary,
      hora: horaCorta(en.fecha),
      fecha: en.fecha,
      duracion: en.duracionMin,
      trailing: trailing,
      children: [
        Insignia(
          l.entrenoEtiqueta,
          color: cs.tertiary,
          icono: Icons.fitness_center,
        ),
        const SizedBox(height: 8),
        Text(
          en.equipo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: tema.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        _Dato(
          Icons.place_outlined,
          (en.lugar == null || en.lugar!.isEmpty)
              ? l.lugarPorConfirmar
              : en.lugar!,
          apagado: en.lugar == null || en.lugar!.isEmpty,
        ),
        if (en.notas != null && en.notas!.isNotEmpty)
          _Dato(Icons.notes_outlined, en.notas!),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.icono, this.texto, {this.apagado = false});
  final IconData icono;
  final String texto;
  final bool apagado;
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = tema.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icono, size: 14, color: c),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              texto,
              style: tema.textTheme.bodySmall?.copyWith(
                color: apagado ? c.withValues(alpha: .7) : c,
                fontStyle: apagado ? FontStyle.italic : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estructura común: columna de hora con barra de color y el contenido a la derecha.
class _BaseTarjeta extends StatelessWidget {
  const _BaseTarjeta({
    required this.color,
    required this.hora,
    required this.fecha,
    required this.children,
    this.duracion,
    this.trailing,
    this.onTap,
  });
  final Color color;
  final String? hora;
  final DateTime? fecha;
  final int? duracion;
  final List<Widget> children;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: color),
              SizedBox(
                width: 74,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hora ?? '—',
                        style: tema.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (fecha != null)
                        Text(
                          fechaCorta(fecha),
                          textAlign: TextAlign.center,
                          style: tema.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      if (duracion != null)
                        Text(
                          context.l10n.duracionMin(duracion!),
                          style: tema.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(child: trailing),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
