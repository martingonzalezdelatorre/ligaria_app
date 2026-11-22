import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../data/models.dart';
import 'idioma.dart';

AppL10n get _l => lookupAppL10n(Locale(codigoIdiomaActual));

/// «sáb 3 oct» (sin depender de la inicialización de locales).
String fechaCorta(DateTime? d) => d == null
    ? _l.sinFecha
    : '${_l.diasCortos.split(',')[d.weekday - 1]} ${d.day} ${_l.mesesCortos.split(',')[d.month - 1]}';
String horaCorta(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// «Sáb 5 dic · 18:30» (la hora solo si el partido la tiene).
String fechaHoraCorta(DateTime? d, {bool conHora = false}) => d == null
    ? fechaCorta(d)
    : '${fechaCorta(d)}${conHora ? ' · ${horaCorta(d)}' : ''}';

String fechaLarga(DateTime d) =>
    '${d.day} ${_l.mesesCortos.split(',')[d.month - 1]} ${d.year}';

String etiquetaEstadoEncuentro(String estado) => switch (estado) {
  'programado' => _l.encProgramado,
  'en_juego' => _l.encEnJuego,
  'finalizado' => _l.encFinalizado,
  'aplazado' => _l.encAplazado,
  'suspendido' => _l.encSuspendido,
  'no_presentado' => _l.incomparecencia,
  _ => estado,
};

String etiquetaEstadoLiga(String estado) => switch (estado) {
  'borrador' => _l.ligaBorrador,
  'publicada' => _l.ligaAbiertaInscr,
  'en_curso' => _l.ligaEnCurso,
  'finalizada' => _l.ligaFinalizada,
  'cancelada' => _l.ligaCancelada,
  _ => estado,
};

/// Renderiza un AsyncValue con carga, error con reintento y datos.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
  });
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => value.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, st) {
      debugPrint('AsyncView error: $e');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 8),
              Text(context.l10n.errCargarDatos, textAlign: TextAlign.center),
              // Solo en modo depuración: causa técnica real (no se muestra en producción).
              if (kDebugMode)
                SelectableText(
                  '$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.reintentar),
                ),
            ],
          ),
        ),
      );
    },
    data: builder,
  );
}

/// Clasificación; `destacados` resalta los equipos «míos». Podio con colores en los 3 primeros.
class TablaClasificacion extends StatelessWidget {
  const TablaClasificacion({
    super.key,
    required this.filas,
    this.destacados = const {},
  });
  final List<FilaClasificacion> filas;
  final Set<String> destacados;

  static const _medallas = [
    Color(0xFFF2B705),
    Color(0xFF9AA5B1),
    Color(0xFFC77B30),
  ];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final cab = tema.textTheme.labelSmall?.copyWith(
      color: cs.onSurfaceVariant,
      fontWeight: FontWeight.w700,
      letterSpacing: .6,
    );
    Widget num(String t) => SizedBox(
      width: 30,
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: tema.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
    );
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const SizedBox(width: 36),
                Expanded(child: Text(context.l10n.colEquipo, style: cab)),
                for (final h in [
                  context.l10n.colPJ,
                  context.l10n.colG,
                  context.l10n.colE,
                  context.l10n.colP,
                ])
                  SizedBox(
                    width: 30,
                    child: Text(h, textAlign: TextAlign.center, style: cab),
                  ),
                SizedBox(
                  width: 46,
                  child: Text(
                    context.l10n.colPts,
                    textAlign: TextAlign.center,
                    style: cab,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          for (final f in filas)
            Container(
              decoration: BoxDecoration(
                color: destacados.contains(f.equipoId)
                    ? cs.primaryContainer.withValues(alpha: .55)
                    : null,
                border: destacados.contains(f.equipoId)
                    ? Border(left: BorderSide(color: cs.primary, width: 4))
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: f.posicion <= 3
                        ? Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _medallas[f.posicion - 1],
                            ),
                            child: Text(
                              '${f.posicion}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : Text(
                            '${f.posicion}',
                            style: tema.textTheme.titleSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        AvatarEquipo(
                          f.equipo,
                          tam: 32,
                          destacado: destacados.contains(f.equipoId),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.equipo,
                                overflow: TextOverflow.ellipsis,
                                style: tema.textTheme.titleSmall,
                              ),
                              Text(
                                f.escuela,
                                style: tema.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  num('${f.pj}'),
                  num('${f.pg}'),
                  num('${f.pe}'),
                  num('${f.pp}'),
                  Container(
                    width: 40,
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${f.puntos}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
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

/// Clasificación agrupada por categoría y, en formato MIXTO, por grupo: con una sola tabla es la tabla
/// sin más; con varias, un título por tabla (la posición se calcula dentro de cada una).
class ClasificacionPorCategoria extends StatelessWidget {
  const ClasificacionPorCategoria({
    super.key,
    required this.filas,
    this.destacados = const {},
  });
  final List<FilaClasificacion> filas;
  final Set<String> destacados;

  @override
  Widget build(BuildContext context) {
    final categorias = filas.map((f) => f.categoria ?? '').toSet();
    final grupos = <(String, int?), List<FilaClasificacion>>{};
    for (final f in filas) {
      grupos.putIfAbsent((f.categoria ?? '', f.grupo), () => []).add(f);
    }
    if (grupos.length <= 1)
      return TablaClasificacion(filas: filas, destacados: destacados);
    final tema = Theme.of(context);
    final claves = grupos.keys.toList()
      ..sort(
        (a, b) => a.$1 != b.$1
            ? a.$1.compareTo(b.$1)
            : (a.$2 ?? 0).compareTo(b.$2 ?? 0),
      );
    String titulo((String, int?) k) => [
      if (categorias.length > 1) k.$1.isEmpty ? context.l10n.general : k.$1,
      if (k.$2 != null) nombreGrupo(k.$2!),
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final k in claves) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              titulo(k),
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TablaClasificacion(filas: grupos[k]!, destacados: destacados),
        ],
      ],
    );
  }
}

/// Tarjeta de un encuentro: equipos con avatar, marcador (si es visible) o «vs», fecha y estado.
class TarjetaEncuentro extends StatelessWidget {
  const TarjetaEncuentro({
    super.key,
    required this.encuentro,
    this.destacados = const {},
    this.onTap,
    this.trailing,
  });
  final EncuentroVista encuentro;
  final Set<String> destacados;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final e = encuentro;
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    Widget equipo(String id, String nombre) {
      final mio = destacados.contains(id);
      return Expanded(
        child: Column(
          children: [
            AvatarEquipo(nombre, tam: 44, destacado: mio),
            const SizedBox(height: 6),
            Text(
              nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.bodyMedium?.copyWith(
                fontWeight: mio ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Pulsable(
      onTap: onTap,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Insignia(e.etiquetaJornada, color: cs.secondary),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        fechaHoraCorta(e.fecha, conHora: e.conHora),
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                if (e.sede != null || e.pista != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [?e.sede, ?e.pista].join(' · '),
                            style: tema.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    equipo(e.localId, e.local),
                    Container(
                      margin: const EdgeInsets.only(top: 6, left: 8, right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: e.tieneMarcador
                            ? cs.primaryContainer
                            : cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        e.tieneMarcador
                            ? '${e.partidosLocal} - ${e.partidosVisitante}'
                            : 'VS',
                        style: tema.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: e.tieneMarcador
                              ? cs.onPrimaryContainer
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    equipo(e.visitanteId, e.visitante),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    if (e.incomparecencia != null)
                      Insignia(
                        context.l10n.incomparecencia,
                        color: cs.error,
                        icono: Icons.block,
                      ),
                    Insignia(
                      etiquetaEstadoEncuentro(e.estado),
                      color: e.confirmado
                          ? cs.primary
                          : (e.estado == 'aplazado' || e.estado == 'suspendido')
                          ? cs.error
                          : cs.onSurfaceVariant,
                      icono: e.confirmado
                          ? Icons.check_circle
                          : (e.estado == 'aplazado' || e.estado == 'suspendido')
                          ? Icons.event_busy_outlined
                          : Icons.schedule,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
