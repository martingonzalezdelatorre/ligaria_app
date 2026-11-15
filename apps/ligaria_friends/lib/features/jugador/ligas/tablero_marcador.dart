import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'tanteo.dart';

/// Tablero del marcador (sets cerrados, juegos y punto actual). Se adapta al ancho:
/// compacto en móvil y más grande en pantallas anchas. Lo usan el tanteador y la vista en directo.
class TableroMarcador extends StatelessWidget {
  const TableroMarcador({
    super.key,
    required this.tanteo,
    required this.local,
    required this.visitante,
    this.enDirecto = false,
  });
  final Tanteo tanteo;
  final String local, visitante;
  final bool enDirecto;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    final t = tanteo;
    final (pl, pv) = t.textoPuntos;
    return LayoutBuilder(
      builder: (context, c) {
        final k = c.maxWidth >= 520 ? 1.3 : 1.0;
        return Container(
          padding: EdgeInsets.all(18 * k),
          decoration: BoxDecoration(
            color: marca.superficie,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: marca.borde),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (enDirecto && !t.terminado) const _EnDirecto(),
                  const Spacer(),
                  if (t.desempate && !t.terminado)
                    Insignia('Desempate', color: cs.primary),
                ],
              ),
              if (enDirecto || t.desempate) SizedBox(height: 10 * k),
              _Fila(
                nombre: local,
                sets: [for (final s in t.sets) s[0]],
                juegos: t.juegosL,
                puntos: pl,
                terminado: t.terminado,
                ganador: t.terminado && t.ganaLocal,
                k: k,
              ),
              Divider(color: marca.borde, height: 24 * k),
              _Fila(
                nombre: visitante,
                sets: [for (final s in t.sets) s[1]],
                juegos: t.juegosV,
                puntos: pv,
                terminado: t.terminado,
                ganador: t.terminado && !t.ganaLocal,
                k: k,
              ),
              SizedBox(height: 10 * k),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    t.terminado ? 'Sets' : 'Sets · Juegos · Punto',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({
    required this.nombre,
    required this.sets,
    required this.juegos,
    required this.puntos,
    required this.terminado,
    required this.ganador,
    required this.k,
  });
  final String nombre, puntos;
  final List<int> sets;
  final int juegos;
  final bool terminado, ganador;
  final double k;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    Widget celda(String s, {bool fuerte = false}) => SizedBox(
      width: 34 * k,
      child: Text(
        s,
        textAlign: TextAlign.center,
        style: t.titleLarge?.copyWith(
          fontSize: (t.titleLarge?.fontSize ?? 22) * k,
          fontWeight: fuerte ? FontWeight.w900 : FontWeight.w600,
          color: fuerte ? cs.onSurface : cs.onSurfaceVariant,
        ),
      ),
    );
    return Row(
      children: [
        AvatarEquipo(nombre, tam: 38 * k),
        SizedBox(width: 10 * k),
        Expanded(
          child: Text(
            nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.titleMedium?.copyWith(
              fontSize: (t.titleMedium?.fontSize ?? 16) * k,
              fontWeight: ganador ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        for (final x in sets) celda('$x', fuerte: ganador),
        if (!terminado) ...[
          celda('$juegos', fuerte: true),
          Container(
            width: 62 * k,
            margin: EdgeInsets.only(left: 8 * k),
            padding: EdgeInsets.symmetric(vertical: 8 * k),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              puntos,
              textAlign: TextAlign.center,
              style: t.headlineSmall?.copyWith(
                fontSize: (t.headlineSmall?.fontSize ?? 24) * k,
                fontWeight: FontWeight.w900,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EnDirecto extends StatefulWidget {
  const _EnDirecto();
  @override
  State<_EnDirecto> createState() => _EnDirectoState();
}

class _EnDirectoState extends State<_EnDirecto>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      FadeTransition(
        opacity: Tween(begin: .35, end: 1.0).animate(_c),
        child: const Icon(Icons.circle, size: 10, color: Color(0xFFEF4444)),
      ),
      const SizedBox(width: 6),
      Text(
        'EN DIRECTO',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          color: const Color(0xFFEF4444),
        ),
      ),
    ],
  );
}
