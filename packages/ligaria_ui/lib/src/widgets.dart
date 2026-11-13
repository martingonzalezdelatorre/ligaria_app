import 'package:flutter/material.dart';
import 'ilustraciones.dart';
import 'theme.dart';

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
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 16, offset: const Offset(0, 6))],
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
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
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
