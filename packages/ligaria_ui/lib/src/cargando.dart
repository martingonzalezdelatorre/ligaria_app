import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ilustraciones.dart';
import 'theme.dart';

/// Indicador de carga de marca: un aro con degradado lima → menta que gira alrededor de una
/// pelota de tenis que rebota. Sustituye a `CircularProgressIndicator` en cargas de contenido.
///
/// Respeta «reducir movimiento» del sistema: en ese caso se muestra quieto.
class Cargando extends StatefulWidget {
  const Cargando({super.key, this.tam = 64, this.etiqueta = 'Cargando'});

  /// Lado del indicador (el aro ocupa todo el cuadrado).
  final double tam;

  /// Texto para lectores de pantalla.
  final String etiqueta;

  @override
  State<Cargando> createState() => _CargandoState();
}

class _CargandoState extends State<Cargando>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tam = widget.tam;
    final radioBola = tam * .19;
    return Semantics(
      label: widget.etiqueta,
      liveRegion: true,
      child: RepaintBoundary(
        child: SizedBox(
          width: tam,
          height: tam,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              // Dos rebotes por vuelta del aro: h va de 0 (en el suelo) a 1 (arriba del todo).
              final u = (t * 2) % 1;
              final h = 4 * u * (1 - u);
              final suelo = tam * .68;
              final alto = tam * .13;
              // Aplastamiento al tocar el suelo.
              final aplasta = math.pow(1 - h, 6).toDouble() * .16;
              final cy = suelo - radioBola - h * alto;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(size: Size.square(tam), painter: _AroPainter(t)),
                  CustomPaint(
                    size: Size.square(tam),
                    painter: _SombraPainter(
                      centro: Offset(tam / 2, suelo + tam * .01),
                      ancho: radioBola * (1.7 - .5 * h),
                      alfa: .42 - .22 * h,
                    ),
                  ),
                  Positioned(
                    left: tam / 2 - radioBola,
                    top: cy - radioBola,
                    width: radioBola * 2,
                    height: radioBola * 2,
                    child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.diagonal3Values(
                        1 + aplasta,
                        1 - aplasta,
                        1,
                      ),
                      child: BolaTenis(tam: radioBola * 2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AroPainter extends CustomPainter {
  _AroPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size s) {
    final grosor = s.width * .075;
    final rect = (Offset.zero & s).deflate(grosor);
    final giro = t * 2 * math.pi;
    const arco = 2 * math.pi * .72;

    // Pista tenue.
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor
        ..color = Colors.white.withValues(alpha: .07),
    );

    final degradado = SweepGradient(
      endAngle: arco,
      colors: [lima.withValues(alpha: 0), menta, lima],
      stops: const [0, .6, 1],
      transform: GradientRotation(giro),
    ).createShader(rect);

    // Resplandor.
    canvas.drawArc(
      rect,
      giro,
      arco,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor * 1.7
        ..shader = degradado
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, grosor * .9)
        ..color = lima.withValues(alpha: .6),
    );
    // Trazo nítido.
    canvas.drawArc(
      rect,
      giro,
      arco,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = grosor
        ..shader = degradado,
    );
  }

  @override
  bool shouldRepaint(_AroPainter old) => old.t != t;
}

class _SombraPainter extends CustomPainter {
  _SombraPainter({
    required this.centro,
    required this.ancho,
    required this.alfa,
  });
  final Offset centro;
  final double ancho;
  final double alfa;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawOval(
      Rect.fromCenter(center: centro, width: ancho * 2, height: ancho * .55),
      Paint()
        ..color = Colors.black.withValues(alpha: alfa)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, ancho * .25),
    );
  }

  @override
  bool shouldRepaint(_SombraPainter o) =>
      o.centro != centro || o.ancho != ancho || o.alfa != alfa;
}

/// Verdes del fondo de la pantalla de carga: verde de marca → verde profundo, de la paleta de la app.
const verdeCargaClaro = Color(0xFF0E7C66);
const verdeCargaOscuro = Color(0xFF07503F);

/// Pantalla completa de carga con el verde de la app: degradado verde con destellos lima y menta en
/// movimiento, el indicador [Cargando] y el mensaje «Cargando [nombre]» con tres puntos animados.
///
/// Necesita un `Theme` y `Directionality` por encima (cualquier `MaterialApp`); para usarla antes de
/// que exista la app, véase [AppCargaInicial].
class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key, this.nombre = 'Ligaria', this.mensaje});

  /// Nombre de la app (p. ej. «Ligaria Friends»); el mensaje por defecto es «Cargando [nombre]».
  final String nombre;

  /// Sustituye al mensaje por defecto.
  final String? mensaje;

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final texto = widget.mensaje ?? 'Cargando ${widget.nombre}';
    return Scaffold(
      backgroundColor: verdeCargaOscuro,
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) =>
                  CustomPaint(painter: _FondoVerdePainter(_c.value)),
            ),
          ),
          SafeArea(
            child: Center(
              child: Aparece(
                desplazamiento: 10,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Cargando(tam: 140),
                      const SizedBox(height: 32),
                      Text(
                        texto,
                        textAlign: TextAlign.center,
                        style: tema.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.2,
                          shadows: const [
                            Shadow(color: Color(0x66000000), blurRadius: 12),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _Puntos(animation: _c),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tres puntos lima que se encienden en onda bajo el mensaje.
class _Puntos extends StatelessWidget {
  const _Puntos({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (_, _) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lima.withValues(
                alpha:
                    .3 +
                    .7 *
                        (math.sin(
                              ((animation.value * 4) - i * .18) * 2 * math.pi,
                            ) +
                            1) /
                        2,
              ),
            ),
          ),
      ],
    ),
  );
}

class _FondoVerdePainter extends CustomPainter {
  _FondoVerdePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Offset.zero & s;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [verdeCargaClaro, verdeCargaOscuro],
        ).createShader(rect),
    );
    final a = t * 2 * math.pi;
    final lado = math.max(s.width, s.height);
    void destello(double fx, double fy, double r, Color c, double fase) {
      final centro = Offset(
        s.width * fx + math.sin(a + fase) * s.width * .1,
        s.height * fy + math.cos(a + fase) * s.height * .08,
      );
      final radio = r * lado;
      canvas.drawCircle(
        centro,
        radio,
        Paint()
          ..shader = RadialGradient(
            colors: [c, c.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: centro, radius: radio)),
      );
    }

    destello(.15, .12, .55, menta.withValues(alpha: .5), 0);
    destello(.9, .85, .6, lima.withValues(alpha: .22), 2.4);
    destello(.5, .5, .35, Colors.white.withValues(alpha: .08), 4.4);
    final linea = Paint()
      ..color = Colors.white.withValues(alpha: .04)
      ..strokeWidth = 1;
    for (var x = 0.0; x < s.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.height), linea);
    }
    for (var y = 0.0; y < s.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), linea);
    }
  }

  @override
  bool shouldRepaint(_FondoVerdePainter old) => old.t != t;
}

/// App mínima con la [PantallaCarga], para mostrarla con `runApp` mientras `main()` inicializa
/// servicios (Supabase, preferencias…) y antes de que exista la app real.
class AppCargaInicial extends StatelessWidget {
  const AppCargaInicial({
    super.key,
    this.nombre = 'Ligaria',
    this.acento = acentoNaranja,
  });
  final String nombre;
  final Color acento;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: temaOscuro(acento: acento),
    darkTheme: temaOscuro(acento: acento),
    themeMode: ThemeMode.dark,
    home: PantallaCarga(nombre: nombre),
  );
}
