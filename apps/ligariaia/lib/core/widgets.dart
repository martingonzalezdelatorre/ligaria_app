import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../data/models.dart';

const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

/// «sáb 3 oct» (sin depender de la inicialización de locales).
String fechaCorta(DateTime? d) => d == null ? 'Sin fecha' : '${_dias[d.weekday - 1]} ${d.day} ${_meses[d.month - 1]}';
String fechaLarga(DateTime d) => '${d.day} ${_meses[d.month - 1]} ${d.year}';

String etiquetaEstadoEncuentro(String estado) => switch (estado) {
      'programado' => 'Programado',
      'en_juego' => 'En juego',
      'finalizado' => 'Finalizado',
      'aplazado' => 'Aplazado',
      'suspendido' => 'Suspendido',
      'no_presentado' => 'Incomparecencia',
      _ => estado,
    };

String etiquetaEstadoLiga(String estado) => switch (estado) {
      'borrador' => 'Borrador',
      'publicada' => 'Abierta a inscripción',
      'en_curso' => 'En curso',
      'finalizada' => 'Finalizada',
      'cancelada' => 'Cancelada',
      _ => estado,
    };

/// Renderiza un AsyncValue con carga, error con reintento y datos.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.builder, this.onRetry});
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
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 8),
              const Text('No se pudieron cargar los datos.', textAlign: TextAlign.center),
              // Solo en modo depuración: causa técnica real (no se muestra en producción).
              if (kDebugMode) SelectableText('$e', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ]),
          ),
        );
        },
        data: builder,
      );
}

/// Clasificación; `destacados` resalta los equipos «míos». Podio con colores en los 3 primeros.
class TablaClasificacion extends StatelessWidget {
  const TablaClasificacion({super.key, required this.filas, this.destacados = const {}});
  final List<FilaClasificacion> filas;
  final Set<String> destacados;

  static const _medallas = [Color(0xFFF2B705), Color(0xFF9AA5B1), Color(0xFFC77B30)];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final cab = tema.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, letterSpacing: .6);
    Widget num(String t) => SizedBox(
        width: 30, child: Text(t, textAlign: TextAlign.center, style: tema.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)));
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            const SizedBox(width: 36),
            Expanded(child: Text('EQUIPO', style: cab)),
            for (final h in ['PJ', 'G', 'E', 'P']) SizedBox(width: 30, child: Text(h, textAlign: TextAlign.center, style: cab)),
            SizedBox(width: 46, child: Text('PTS', textAlign: TextAlign.center, style: cab)),
          ]),
        ),
        const Divider(),
        for (final f in filas)
          Container(
            decoration: BoxDecoration(
              color: destacados.contains(f.equipoId) ? cs.primaryContainer.withValues(alpha: .55) : null,
              border: destacados.contains(f.equipoId) ? Border(left: BorderSide(color: cs.primary, width: 4)) : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              SizedBox(
                width: 36,
                child: f.posicion <= 3
                    ? Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: _medallas[f.posicion - 1]),
                        child: Text('${f.posicion}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      )
                    : Text('${f.posicion}', style: tema.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
              ),
              Expanded(
                child: Row(children: [
                  AvatarEquipo(f.equipo, tam: 32, destacado: destacados.contains(f.equipoId)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.equipo, overflow: TextOverflow.ellipsis, style: tema.textTheme.titleSmall),
                      Text(f.escuela, style: tema.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ]),
              ),
              num('${f.pj}'), num('${f.pg}'), num('${f.pe}'), num('${f.pp}'),
              Container(
                width: 40,
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(10)),
                child: Text('${f.puntos}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
      ]),
    );
  }
}

/// Tarjeta de un encuentro: equipos con avatar, marcador (si es visible) o «vs», fecha y estado.
class TarjetaEncuentro extends StatelessWidget {
  const TarjetaEncuentro({super.key, required this.encuentro, this.destacados = const {}, this.onTap, this.trailing});
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
        child: Column(children: [
          AvatarEquipo(nombre, tam: 44, destacado: mio),
          const SizedBox(height: 6),
          Text(nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.bodyMedium?.copyWith(fontWeight: mio ? FontWeight.w800 : FontWeight.w500)),
        ]),
      );
    }

    return Pulsable(onTap: onTap, child: Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(children: [
            Row(children: [
              Insignia('Jornada ${e.jornada}', color: cs.secondary),
              const SizedBox(width: 8),
              Icon(Icons.calendar_today_outlined, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(child: Text(fechaCorta(e.fecha), style: tema.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant))),
              ?trailing,
            ]),
            const SizedBox(height: 14),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              equipo(e.localId, e.local),
              Container(
                margin: const EdgeInsets.only(top: 6, left: 8, right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: e.tieneMarcador ? cs.primaryContainer : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14)),
                child: Text(e.tieneMarcador ? '${e.partidosLocal} - ${e.partidosVisitante}' : 'VS',
                    style: tema.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800, color: e.tieneMarcador ? cs.onPrimaryContainer : cs.onSurfaceVariant)),
              ),
              equipo(e.visitanteId, e.visitante),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 4, alignment: WrapAlignment.center, children: [
              if (e.incomparecencia != null) Insignia('Incomparecencia', color: cs.error, icono: Icons.block),
              Insignia(etiquetaEstadoEncuentro(e.estado),
                  color: e.confirmado ? cs.primary : cs.onSurfaceVariant,
                  icono: e.confirmado ? Icons.check_circle : Icons.schedule),
            ]),
          ]),
        ),
      ),
    ));
  }
}

