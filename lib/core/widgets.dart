import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';
import 'ilustraciones.dart';
import 'theme.dart';

const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

/// «sáb 3 oct» (sin depender de la inicialización de locales).
String fechaCorta(DateTime? d) => d == null ? 'Sin fecha' : '${_dias[d.weekday - 1]} ${d.day} ${_meses[d.month - 1]}';
String fechaLarga(DateTime d) => '${d.day} ${_meses[d.month - 1]} ${d.year}';

String etiquetaEstadoEncuentro(String estado) => switch (estado) {
      'programado' => 'Programado',
      'propuesto' => 'Pendiente de confirmar',
      'confirmado' => 'Confirmado',
      _ => estado,
    };

String etiquetaEstadoLiga(String estado) => switch (estado) {
      'borrador' => 'Borrador',
      'publicada' => 'Abierta a inscripción',
      'en_curso' => 'En curso',
      'finalizada' => 'Finalizada',
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
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 8),
              const Text('No se pudieron cargar los datos.', textAlign: TextAlign.center),
              if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ]),
          ),
        ),
        data: builder,
      );
}

class EstadoVacio extends StatelessWidget {
  const EstadoVacio({super.key, required this.icono, required this.texto});
  final IconData icono;
  final String texto;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            MedallonVacio(icono: icono),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(texto,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ]),
        ),
      );
}

/// Muestra un error de operación como SnackBar (mensaje genérico, sin detalles internos).
void avisar(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensaje)));
}

/// Avatar con la inicial del equipo (color estable según el nombre).
class AvatarEquipo extends StatelessWidget {
  const AvatarEquipo(this.nombre, {super.key, this.tam = 40, this.destacado = false});
  final String nombre;
  final double tam;
  final bool destacado;

  static const _paleta = [
    Color(0xFF1B8A4B), Color(0xFF2563EB), Color(0xFFDB2777), Color(0xFFEA580C),
    Color(0xFF7C3AED), Color(0xFF0891B2), Color(0xFFCA8A04), Color(0xFFDC2626),
  ];

  @override
  Widget build(BuildContext context) {
    final c = _paleta[nombre.runes.fold<int>(0, (a, r) => a + r) % _paleta.length];
    final inicial = nombre.trim().isEmpty ? '?' : String.fromCharCode(nombre.trim().runes.first).toUpperCase();
    return Container(
      width: tam,
      height: tam,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c, Color.lerp(c, Colors.black, .25)!]),
        border: destacado ? Border.all(color: Marca.de(context).acento, width: 2.5) : null,
      ),
      child: Text(inicial, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: tam * .42)),
    );
  }
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
    final cab = tema.textTheme.labelSmall?.copyWith(color: cs.outline, fontWeight: FontWeight.w700, letterSpacing: .6);
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
                    : Text('${f.posicion}', style: tema.textTheme.titleSmall?.copyWith(color: cs.outline)),
              ),
              Expanded(
                child: Row(children: [
                  AvatarEquipo(f.equipo, tam: 32, destacado: destacados.contains(f.equipoId)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.equipo, overflow: TextOverflow.ellipsis, style: tema.textTheme.titleSmall),
                      Text(f.escuela, style: tema.textTheme.bodySmall?.copyWith(color: cs.outline), overflow: TextOverflow.ellipsis),
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
              Icon(Icons.calendar_today_outlined, size: 14, color: cs.outline),
              const SizedBox(width: 4),
              Expanded(child: Text(fechaCorta(e.fecha), style: tema.textTheme.bodySmall?.copyWith(color: cs.outline))),
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
                        fontWeight: FontWeight.w800, color: e.tieneMarcador ? cs.onPrimaryContainer : cs.outline)),
              ),
              equipo(e.visitanteId, e.visitante),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 4, alignment: WrapAlignment.center, children: [
              if (e.incomparecencia != null) Insignia('Incomparecencia', color: cs.error, icono: Icons.block),
              Insignia(etiquetaEstadoEncuentro(e.estado),
                  color: e.confirmado ? cs.primary : cs.outline,
                  icono: e.confirmado ? Icons.check_circle : Icons.schedule),
            ]),
          ]),
        ),
      ),
    ));
  }
}

/// Centra el contenido con un ancho máximo (pantallas grandes) manteniendo el fondo a sangre.
class ContenidoCentrado extends StatelessWidget {
  const ContenidoCentrado({super.key, required this.child, this.maxAncho = Pantalla.contenidoMax});
  final Widget child;
  final double maxAncho;
  @override
  Widget build(BuildContext context) =>
      Align(alignment: Alignment.topCenter, child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxAncho), child: child));
}

/// Barra de pestañas estilo «píldora», con margen y desplazable si no caben.
class PestanasPildora extends StatelessWidget implements PreferredSizeWidget {
  const PestanasPildora({super.key, required this.tabs, this.desplazable = false});
  final List<Widget> tabs;
  final bool desplazable;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [BoxShadow(color: const Color(0xFF0B3D22).withValues(alpha: .10), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: TabBar(
              isScrollable: desplazable || tabs.length > 2,
              tabAlignment: (desplazable || tabs.length > 2) ? TabAlignment.start : null,
              indicatorPadding: EdgeInsets.zero,
              tabs: tabs,
            ),
          ),
        ),
      );
}

/// Insignia de estado con color semántico.
class Insignia extends StatelessWidget {
  const Insignia(this.texto, {super.key, this.color, this.icono});
  final String texto;
  final Color? color;
  final IconData? icono;
  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: .13), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icono != null) ...[Icon(icono, size: 14, color: c), const SizedBox(width: 4)],
        Text(texto, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
