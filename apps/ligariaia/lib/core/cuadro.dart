import 'package:flutter/material.dart';
import '../data/models.dart';

/// Alterna entre el cuadro dibujado y la lista de encuentros.
class SelectorVistaCuadro extends StatelessWidget {
  const SelectorVistaCuadro({super.key, required this.cuadro, required this.onCambio, this.etiquetaCuadro = 'Llaves'});
  final bool cuadro;
  final ValueChanged<bool> onCambio;
  final String etiquetaCuadro;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: true, label: Text(etiquetaCuadro), icon: const Icon(Icons.account_tree_outlined, size: 18)),
            const ButtonSegment(value: false, label: Text('Lista'), icon: Icon(Icons.view_list_outlined, size: 18)),
          ],
          selected: {cuadro},
          onSelectionChanged: (s) => onCambio(s.first),
        ),
      );
}

/// Dibuja la eliminatoria de todas las categorías (un cuadro por categoría). Solo se pasan los encuentros
/// de la fase de eliminatoria; `byes` son los pases directos. [onTap] se llama al pulsar un encuentro.
class CuadrosEliminatoria extends StatelessWidget {
  const CuadrosEliminatoria({
    super.key, required this.encuentros, this.byes = const [], this.destacados = const {}, this.onTap,
  });
  final List<EncuentroVista> encuentros;
  final List<Descanso> byes;
  final Set<String> destacados; // ids de mis equipos
  final void Function(EncuentroVista)? onTap;

  @override
  Widget build(BuildContext context) {
    final categorias = <String, List<EncuentroVista>>{};
    for (final e in encuentros.where((e) => e.esEliminatoria)) {
      categorias.putIfAbsent(e.categoria ?? '', () => []).add(e);
    }
    if (categorias.isEmpty) return const SizedBox.shrink();
    final claves = categorias.keys.toList()..sort();
    final tema = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final c in claves) ...[
        if (claves.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(c.isEmpty ? 'General' : c, style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
        CuadroEliminatoria(
          encuentros: categorias[c]!,
          byes: byes.where((b) => (b.categoria ?? '') == c).toList(),
          destacados: destacados,
          onTap: onTap,
        ),
      ],
    ]);
  }
}

/// Cuadro de una eliminatoria: una columna por ronda, con llaves que unen cada pareja de encuentros con el de
/// la ronda siguiente. Las rondas aún sin generar se dibujan como «Por determinar».
class CuadroEliminatoria extends StatelessWidget {
  const CuadroEliminatoria({
    super.key, required this.encuentros, this.byes = const [], this.destacados = const {}, this.onTap,
  });

  /// Encuentros de UNA categoría en fase de eliminatoria.
  final List<EncuentroVista> encuentros;
  final List<Descanso> byes;
  final Set<String> destacados;
  final void Function(EncuentroVista)? onTap;

  static const double anchoCasilla = 184, altoCasilla = 72, hueco = 44, separacion = 14, altoTitulo = 34;

  @override
  Widget build(BuildContext context) {
    // Emparejamientos de la primera ronda (incluye los pases directos) y número de rondas del cuadro.
    final primera = encuentros.where((e) => e.jornada == 1).toList();
    final llaves1 = primera.isEmpty ? null : primera.first.llaves;
    if (llaves1 == null || llaves1 < 1) return const SizedBox.shrink();
    var rondas = 0;
    for (var l = llaves1; l >= 1; l ~/= 2) {
      rondas++;
    }

    EncuentroVista? encuentro(int r, int k) =>
        encuentros.where((e) => e.jornada == r + 1 && e.llave == k + 1).firstOrNull;
    Descanso? bye(int k) => byes.where((b) => b.jornada == 1 && b.llave == k + 1).firstOrNull;

    final paso = altoCasilla + separacion;
    double centro(int r, int k) =>
        r == 0 ? k * paso + altoCasilla / 2 : (centro(r - 1, 2 * k) + centro(r - 1, 2 * k + 1)) / 2;
    final alto = llaves1 * paso;
    final ancho = rondas * anchoCasilla + (rondas - 1) * hueco;
    final tema = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SizedBox(
        width: ancho,
        height: altoTitulo + alto,
        child: Stack(children: [
          // títulos de ronda
          for (var r = 0; r < rondas; r++)
            Positioned(
              left: r * (anchoCasilla + hueco),
              top: 0,
              width: anchoCasilla,
              height: altoTitulo,
              child: Text(nombreRonda(llaves1 >> r, r + 1),
                  style: tema.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: tema.colorScheme.primary)),
            ),
          // llaves (detrás de las casillas)
          Positioned(
            left: 0,
            top: altoTitulo,
            width: ancho,
            height: alto,
            child: CustomPaint(
              painter: _LlavesPainter(
                rondas: rondas, llaves1: llaves1, centro: centro, ancho: anchoCasilla, hueco: hueco,
                color: tema.colorScheme.outline,
              ),
            ),
          ),
          // casillas
          for (var r = 0; r < rondas; r++)
            for (var k = 0; k < (llaves1 >> r); k++)
              Positioned(
                left: r * (anchoCasilla + hueco),
                top: altoTitulo + centro(r, k) - altoCasilla / 2,
                width: anchoCasilla,
                height: altoCasilla,
                child: _Casilla(
                  encuentro: encuentro(r, k),
                  pasoDirecto: r == 0 ? bye(k) : null,
                  destacados: destacados,
                  onTap: onTap,
                ),
              ),
        ]),
      ),
    );
  }
}

class _LlavesPainter extends CustomPainter {
  const _LlavesPainter({
    required this.rondas, required this.llaves1, required this.centro, required this.ancho, required this.hueco,
    required this.color,
  });
  final int rondas, llaves1;
  final double Function(int ronda, int llave) centro;
  final double ancho, hueco;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;
    for (var r = 0; r < rondas - 1; r++) {
      final xSalida = r * (ancho + hueco) + ancho;
      final xMedio = xSalida + hueco / 2;
      final xEntrada = (r + 1) * (ancho + hueco);
      for (var k = 0; k < (llaves1 >> r); k++) {
        final destino = centro(r + 1, k ~/ 2);
        canvas.drawPath(
          Path()
            ..moveTo(xSalida, centro(r, k))
            ..lineTo(xMedio, centro(r, k))
            ..lineTo(xMedio, destino)
            ..lineTo(xEntrada, destino),
          pincel,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_LlavesPainter old) =>
      old.rondas != rondas || old.llaves1 != llaves1 || old.color != color || old.ancho != ancho || old.hueco != hueco;
}

/// Una casilla del cuadro: dos equipos con su marcador, un pase directo o «Por determinar».
class _Casilla extends StatelessWidget {
  const _Casilla({this.encuentro, this.pasoDirecto, required this.destacados, this.onTap});
  final EncuentroVista? encuentro;
  final Descanso? pasoDirecto;
  final Set<String> destacados;
  final void Function(EncuentroVista)? onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final e = encuentro;

    Widget fila(String nombre, {int? puntos, bool gana = false, bool mio = false, bool apagado = false}) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: mio ? cs.primaryContainer.withValues(alpha: .6) : null,
            child: Row(children: [
              Expanded(
                child: Text(nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontWeight: gana || mio ? FontWeight.w800 : FontWeight.w500,
                      color: apagado ? cs.onSurfaceVariant : null,
                    )),
              ),
              if (puntos != null)
                Text('$puntos', style: tema.textTheme.titleSmall?.copyWith(fontWeight: gana ? FontWeight.w900 : FontWeight.w500)),
            ]),
          ),
        );

    Widget contenido;
    if (e != null) {
      final jugado = e.confirmado && e.tieneMarcador;
      final gl = jugado && e.partidosLocal! > e.partidosVisitante!;
      final gv = jugado && e.partidosVisitante! > e.partidosLocal!;
      contenido = Column(children: [
        fila(e.local, puntos: jugado ? e.partidosLocal : null, gana: gl, mio: destacados.contains(e.localId)),
        Divider(height: 1, color: cs.outlineVariant),
        fila(e.visitante, puntos: jugado ? e.partidosVisitante : null, gana: gv, mio: destacados.contains(e.visitanteId)),
      ]);
    } else if (pasoDirecto != null) {
      contenido = Column(children: [
        fila(pasoDirecto!.equipo, mio: destacados.contains(pasoDirecto!.equipoId)),
        Divider(height: 1, color: cs.outlineVariant),
        fila('Pase directo', apagado: true),
      ]);
    } else {
      contenido = Column(children: [
        fila('Por determinar', apagado: true),
        Divider(height: 1, color: cs.outlineVariant),
        fila('Por determinar', apagado: true),
      ]);
    }

    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: e == null ? cs.outlineVariant : cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: e != null && onTap != null ? () => onTap!(e) : null,
        child: contenido,
      ),
    );
  }
}
