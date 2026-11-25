import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/idioma.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../entrenador/entrenador_providers.dart';

/// Detalle de un partido: arriba, los dos equipos con los nombres de sus jugadores; debajo, la fecha y
/// la hora, el lugar y, si ya se ha jugado, el resultado de cada partido.
class DetallePartidoPage extends ConsumerWidget {
  const DetallePartidoPage({
    super.key,
    required this.encuentro,
    this.destacados = const {},
  });
  final EncuentroVista encuentro;

  /// Ids de mis equipos, para resaltarlos.
  final Set<String> destacados;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final e = encuentro;
    final datos = ref.watch(
      datosFormularioProvider((e.id, e.localId, e.visitanteId)),
    );
    final detalle = datos.value?.detalle;
    // Con el partido ya alineado se ven los jugadores que jugaron; si no, la plantilla (la del rival
    // solo se conoce si es de la misma escuela).
    List<String> nombres(bool local) {
      final enPartidos = <String>{
        for (final p in detalle?.partidos ?? const <PartidoDetalle>[])
          ...(local ? p.local : p.visitante),
      };
      if (enPartidos.isNotEmpty) return enPartidos.toList();
      final plantilla = local ? datos.value?.local : datos.value?.visitante;
      return [for (final j in plantilla ?? const <Jugador>[]) j.nombreCompleto];
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.detallePartido)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Cabecera(
            encuentro: e,
            destacados: destacados,
            jugadoresLocal: nombres(true),
            jugadoresVisitante: nombres(false),
            cargando: datos.isLoading,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              Insignia(
                e.etiquetaJornada,
                color: Theme.of(context).colorScheme.secondary,
              ),
              if (e.categoria != null && e.categoria!.isNotEmpty)
                Insignia(e.categoria!),
              Insignia(
                etiquetaEstadoEncuentro(e.estado),
                color: e.confirmado
                    ? Theme.of(context).colorScheme.primary
                    : (e.estado == 'aplazado' || e.estado == 'suspendido')
                    ? Theme.of(context).colorScheme.error
                    : null,
                icono: e.confirmado ? Icons.check_circle : Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FechaHora(encuentro: e),
          const SizedBox(height: 8),
          _Lugar(encuentro: e),
          if (detalle != null && detalle.partidos.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              l.resultados,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final p in detalle.partidos) _TarjetaPartido(partido: p),
          ] else if (datos.hasValue && !e.confirmado) ...[
            const SizedBox(height: 16),
            Text(
              l.alineacionPendiente,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Los dos bandos enfrentados, con el nombre del equipo grande y los jugadores debajo.
class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.encuentro,
    required this.destacados,
    required this.jugadoresLocal,
    required this.jugadoresVisitante,
    required this.cargando,
  });
  final EncuentroVista encuentro;
  final Set<String> destacados;
  final List<String> jugadoresLocal, jugadoresVisitante;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final e = encuentro;
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    Widget lado(String id, String nombre, List<String> jugadores) {
      final mio = destacados.contains(id);
      return Expanded(
        child: Column(
          children: [
            AvatarEquipo(nombre, tam: 64, destacado: mio),
            const SizedBox(height: 10),
            Text(
              nombre,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (cargando && jugadores.isEmpty)
              const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (jugadores.isEmpty)
              Text(
                '—',
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            else
              for (final j in jugadores)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    j,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lado(e.localId, e.local, jugadoresLocal),
            Container(
              margin: const EdgeInsets.only(top: 18, left: 4, right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            lado(e.visitanteId, e.visitante, jugadoresVisitante),
          ],
        ),
      ),
    );
  }
}

class _FechaHora extends StatelessWidget {
  const _FechaHora({required this.encuentro});
  final EncuentroVista encuentro;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final e = encuentro;
    final f = e.fecha;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(l.fechaYHoraTitulo),
        subtitle: Text(
          f == null
              ? l.sinFecha
              : e.conHora
              ? '${etiquetaDia(f)} · ${horaCorta(f)}'
              : '${etiquetaDia(f)} · ${l.horaPorConfirmar}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _Lugar extends StatelessWidget {
  const _Lugar({required this.encuentro});
  final EncuentroVista encuentro;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lugar = [
      if (encuentro.sede != null && encuentro.sede!.isNotEmpty) encuentro.sede!,
      if (encuentro.pista != null && encuentro.pista!.isNotEmpty)
        encuentro.pista!,
    ].join(' · ');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.place_outlined),
        title: Text(l.lugarTitulo),
        subtitle: Text(
          lugar.isEmpty ? l.lugarPorConfirmar : lugar,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Un partido del encuentro (individual o dobles) con sus jugadores y los juegos de cada set.
class _TarjetaPartido extends StatelessWidget {
  const _TarjetaPartido({required this.partido});
  final PartidoDetalle partido;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tema = Theme.of(context);
    final p = partido;
    String quienes(List<String> n) => n.isEmpty ? '—' : n.join(' / ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.partidoTipo(
                p.orden,
                p.tipo == 'dobles' ? l.dobles : l.individual,
              ),
              style: tema.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    quienes(p.local),
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  p.sets.map((s) => '${s[0]}-${s[1]}').join('   '),
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(
                  child: Text(
                    quienes(p.visitante),
                    textAlign: TextAlign.end,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
