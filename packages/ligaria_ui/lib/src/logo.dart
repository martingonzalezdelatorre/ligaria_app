import 'package:flutter/material.dart';
import 'theme.dart';

/// Logo de marca (icono sobre degradado lima). Cada app pasa su icono.
class LogoLigaria extends StatelessWidget {
  const LogoLigaria({
    super.key,
    this.tam = 48,
    this.icono = Icons.sports_tennis,
  });
  final double tam;
  final IconData icono;
  @override
  Widget build(BuildContext context) {
    final claro = Theme.of(context).brightness == Brightness.light;
    final color = acentoDe(context);
    return Container(
      width: tam,
      height: tam,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tam * .3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, claro ? const Color(0xFF3FAF7E) : const Color(0xFF7BE36B)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: claro ? .35 : .45),
            blurRadius: tam * .6,
          ),
        ],
      ),
      child: Icon(icono, color: tinta, size: tam * .55),
    );
  }
}
