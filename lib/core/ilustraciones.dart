import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

/// Ilustraciones propias dibujadas con código (sin imágenes externas): escalan a móvil, tablet y escritorio.

const verdePista = Color(0xFF2DB36B);
const verdePistaClaro = Color(0xFF5BD18F);
const verdeMenta = Color(0xFFE6F6EC);
const amarilloBola = Color(0xFFDCEB3B);
const arcilla = Color(0xFFF4A261);

/// Pista vista desde arriba (líneas de tenis/pádel) para usar de fondo.
class PistaPainter extends CustomPainter {
  const PistaPainter({this.linea = Colors.white, this.opacidad = .55, this.grosor = 2});
  final Color linea;
  final double opacidad;
  final double grosor;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = linea.withValues(alpha: opacidad)
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height;
    final m = math.min(w, h) * .08;
    final r = Rect.fromLTWH(m, m, w - 2 * m, h - 2 * m);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), p);
    // Pasillos laterales, red central y líneas de saque.
    final pas = r.width * .12;
    canvas.drawLine(Offset(r.left + pas, r.top), Offset(r.left + pas, r.bottom), p);
    canvas.drawLine(Offset(r.right - pas, r.top), Offset(r.right - pas, r.bottom), p);
    canvas.drawLine(Offset(r.left, r.center.dy), Offset(r.right, r.center.dy), p..strokeWidth = grosor * 1.6);
    p.strokeWidth = grosor;
    final saque = r.height * .27;
    canvas.drawLine(Offset(r.left + pas, r.center.dy - saque), Offset(r.right - pas, r.center.dy - saque), p);
    canvas.drawLine(Offset(r.left + pas, r.center.dy + saque), Offset(r.right - pas, r.center.dy + saque), p);
    canvas.drawLine(Offset(r.center.dx, r.center.dy - saque), Offset(r.center.dx, r.center.dy + saque), p);
  }

  @override
  bool shouldRepaint(PistaPainter o) => o.linea != linea || o.opacidad != opacidad || o.grosor != grosor;
}

/// Pelota de tenis con costuras.
class BolaTenis extends StatelessWidget {
  const BolaTenis({super.key, this.tam = 48});
  final double tam;
  @override
  Widget build(BuildContext context) => SizedBox(width: tam, height: tam, child: CustomPaint(painter: _BolaPainter()));
}

class _BolaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: c + Offset(0, r * .12), radius: r * .96)), Colors.black45, 4, true);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = const RadialGradient(center: Alignment(-.4, -.4), colors: [Color(0xFFF1FA6B), amarilloBola, Color(0xFFB7C61C)])
              .createShader(Rect.fromCircle(center: c, radius: r)));
    final costura = Paint()
      ..color = Colors.white.withValues(alpha: .9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .13
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.drawArc(Rect.fromCircle(center: c + Offset(-r * 1.25, 0), radius: r * 1.1), -.9, 1.8, false, costura);
    canvas.drawArc(Rect.fromCircle(center: c + Offset(r * 1.25, 0), radius: r * 1.1), math.pi - .9, 1.8, false, costura);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BolaPainter o) => false;
}

/// Raqueta con cordaje.
class Raqueta extends StatelessWidget {
  const Raqueta({super.key, this.tam = 120, this.color = const Color(0xFF145A37)});
  final double tam;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(width: tam * .5, height: tam, child: CustomPaint(painter: _RaquetaPainter(color)));
}

class _RaquetaPainter extends CustomPainter {
  _RaquetaPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cabeza = Rect.fromLTWH(w * .06, 0, w * .88, h * .62);
    final cuerda = Paint()
      ..color = Colors.white.withValues(alpha: .75)
      ..strokeWidth = 1.2;
    canvas.save();
    canvas.clipPath(Path()..addOval(cabeza.deflate(w * .05)));
    for (var i = 1; i < 8; i++) {
      final x = cabeza.left + cabeza.width * i / 8;
      canvas.drawLine(Offset(x, cabeza.top), Offset(x, cabeza.bottom), cuerda);
      final y = cabeza.top + cabeza.height * i / 9;
      canvas.drawLine(Offset(cabeza.left, y), Offset(cabeza.right, y), cuerda);
    }
    canvas.restore();
    canvas.drawOval(
        cabeza,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * .09);
    // Garganta y mango.
    final garganta = Path()
      ..moveTo(w * .30, h * .58)
      ..lineTo(w * .46, h * .70)
      ..moveTo(w * .70, h * .58)
      ..lineTo(w * .54, h * .70);
    canvas.drawPath(garganta, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = w * .07..strokeCap = StrokeCap.round);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * .43, h * .68, w * .14, h * .32), Radius.circular(w * .07)),
        Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * .43, h * .76, w * .14, h * .06), Radius.circular(2)),
        Paint()..color = color.withValues(alpha: .35));
  }

  @override
  bool shouldRepaint(_RaquetaPainter o) => o.color != color;
}

/// Escena principal: pista, raqueta y pelota. Se adapta al tamaño disponible.
class HeroPista extends StatelessWidget {
  const HeroPista({super.key, this.alto = 220, this.radio = 28});
  final double alto;
  final double radio;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radio),
        child: Container(
          height: alto,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [verdePistaClaro, verdePista]),
          ),
          child: LayoutBuilder(builder: (context, c) {
            final h = c.maxHeight;
            return Stack(children: [
              Positioned.fill(child: CustomPaint(painter: const PistaPainter())),
              // La raqueta entra girando y la pelota cae con rebote (una sola vez).
              Positioned(
                right: c.maxWidth * .12,
                bottom: -h * .08,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.1, end: .45),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutBack,
                  builder: (_, a, child) => Transform.rotate(angle: a, child: child),
                  child: Raqueta(tam: h * .95),
                ),
              ),
              Positioned(
                left: c.maxWidth * .14,
                top: h * .2,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: -h * .9, end: 0),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.bounceOut,
                  builder: (_, dy, child) => Transform.translate(offset: Offset(0, dy), child: child),
                  child: BolaTenis(tam: h * .24),
                ),
              ),
              Positioned(
                left: c.maxWidth * .05,
                bottom: h * .12,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (_, s, child) => Transform.scale(scale: s, child: child),
                  child: Icon(Icons.emoji_events_rounded, size: h * .22, color: Colors.white.withValues(alpha: .95)),
                ),
              ),
            ]);
          }),
        ),
      );
}

/// Medallón ilustrado para estados vacíos: círculo menta con icono y una pelota pequeña.
class MedallonVacio extends StatelessWidget {
  const MedallonVacio({super.key, required this.icono, this.tam = 112});
  final IconData icono;
  final double tam;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: tam,
      height: tam,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: tam,
          height: tam,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: verdeMenta),
          child: ClipOval(child: CustomPaint(painter: const PistaPainter(linea: verdePista, opacidad: .25, grosor: 1.5))),
        ),
        Center(child: Icon(icono, size: tam * .42, color: cs.primary)),
        Positioned(right: -tam * .02, top: tam * .02, child: BolaTenis(tam: tam * .26)),
      ]),
    );
  }
}

/// Entrada suave: aparece con fundido y un pequeño desplazamiento vertical (con retardo opcional).
class Aparece extends StatelessWidget {
  const Aparece({super.key, required this.child, this.retardo = 0, this.desplazamiento = 18});
  final Widget child;
  final int retardo; // ms
  final double desplazamiento;

  @override
  Widget build(BuildContext context) {
    final total = 450 + retardo;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(retardo / total, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) =>
          Opacity(opacity: t, child: Transform.translate(offset: Offset(0, (1 - t) * desplazamiento), child: child)),
      child: child,
    );
  }
}

/// Efecto táctil: la tarjeta se hunde ligeramente al pulsar y se eleva al pasar el ratón.
class Pulsable extends StatefulWidget {
  const Pulsable({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;
  @override
  State<Pulsable> createState() => _PulsableState();
}

class _PulsableState extends State<Pulsable> {
  bool _abajo = false, _sobre = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _sobre = true),
        onExit: (_) => setState(() => _sobre = false),
        child: Listener(
          onPointerDown: (_) => setState(() => _abajo = true),
          onPointerUp: (_) => setState(() => _abajo = false),
          onPointerCancel: (_) => setState(() => _abajo = false),
          child: AnimatedScale(
            scale: _abajo ? .98 : (_sobre && widget.onTap != null ? 1.012 : 1),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: widget.child,
          ),
        ),
      );
}

/// Fondo oscuro con auroras de color en movimiento y rejilla sutil (como Socio+).
class FondoBlobs extends StatefulWidget {
  const FondoBlobs({super.key, required this.child});
  final Widget child;
  @override
  State<FondoBlobs> createState() => _FondoBlobsState();
}

class _FondoBlobsState extends State<FondoBlobs> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: tinta,
        child: Stack(fit: StackFit.expand, children: [
          RepaintBoundary(
            child: AnimatedBuilder(animation: _c, builder: (_, _) => CustomPaint(painter: _AuroraPainter(_c.value))),
          ),
          widget.child,
        ]),
      );
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t);
  final double t;
  @override
  void paint(Canvas canvas, Size s) {
    final a = t * 2 * math.pi;
    final lado = math.max(s.width, s.height);
    void aurora(double fx, double fy, double r, Color c, double fase) {
      final centro = Offset(s.width * fx + math.sin(a + fase) * s.width * .12, s.height * fy + math.cos(a + fase) * s.height * .1);
      final radio = r * lado;
      canvas.drawCircle(centro, radio,
          Paint()..shader = RadialGradient(colors: [c, c.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: centro, radius: radio)));
    }

    aurora(.1, .15, .55, menta.withValues(alpha: .55), 0);
    aurora(.95, .25, .45, const Color(0xFFFF8A3D).withValues(alpha: .4), 2.1);
    aurora(.6, 1.0, .6, lima.withValues(alpha: .28), 4.2);
    aurora(0, .95, .4, verdeMarca.withValues(alpha: .6), 5.5);
    final linea = Paint()
      ..color = Colors.white.withValues(alpha: .035)
      ..strokeWidth = 1;
    for (var x = 0.0; x < s.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.height), linea);
    }
    for (var y = 0.0; y < s.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), linea);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}
