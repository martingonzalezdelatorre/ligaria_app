import 'package:flutter/material.dart';
import 'theme.dart';

/// Logo de marca (icono sobre degradado lima). Cada app pasa su icono.
class LogoLigaria extends StatelessWidget {
  const LogoLigaria({super.key, this.tam = 48, this.icono = Icons.sports_tennis});
  final double tam;
  final IconData icono;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: tam,
      height: tam,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tam * .3),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [lima, Color(0xFF7BE36B)]),
        boxShadow: [BoxShadow(color: lima.withValues(alpha: .45), blurRadius: tam * .6)],
      ),
      child: Icon(icono, color: tinta, size: tam * .55),
    );
  }
}
