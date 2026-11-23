import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../../core/idioma.dart';
import '../grupos/grupos_repositorio.dart';
import 'estadisticas_repositorio.dart';

String _pct(double v) => '${(v * 100).round()}%';

/// Estadísticas del jugador y de los miembros de sus grupos, sobre partidos confirmados.
class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key, this.repo, this.grupos});
  final EstadisticasRepositorio? repo;

  /// Para elegir el grupo en la vista «Del grupo».
  final GruposRepositorio? grupos;

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  late final EstadisticasRepositorio _repo =
      widget.repo ?? EstadisticasRepositorio.instancia;
  bool _verGrupo = false;
  Future<List<Grupo>> _grupos = Future.value(const []);
  Grupo? _grupo;
  late Future<EstadisticasJugador> _mias = _repo.mias();
  Future<List<EstadisticasJugador>> _delGrupo = Future.value(const []);

  @override
  void initState() {
    super.initState();
    if (widget.grupos != null) _grupos = widget.grupos!.misGrupos();
  }

  void _cargar() {
    _mias = _repo.mias();
    _delGrupo = _grupo == null
        ? Future.value(const [])
        : _repo.grupo(_grupo!.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.estadisticas)),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            maxAncho: 640,
            child: FutureBuilder<List<Grupo>>(
              future: _grupos,
              builder: (context, gs) {
                final grupos = gs.data ?? const <Grupo>[];
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(_cargar);
                    await _mias;
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    children: [
                      Text(
                        context.l10n.estSoloConfirmados,
                        style: t.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            avatar: const Icon(Icons.person_outline, size: 18),
                            label: Text(context.l10n.estMias),
                            selected: !_verGrupo,
                            onSelected: (_) =>
                                setState(() => _verGrupo = false),
                          ),
                          if (grupos.isNotEmpty)
                            ChoiceChip(
                              avatar: const Icon(
                                Icons.groups_outlined,
                                size: 18,
                              ),
                              label: Text(context.l10n.estGrupo),
                              selected: _verGrupo,
                              onSelected: (_) => setState(() {
                                _verGrupo = true;
                                _grupo ??= grupos.first;
                                _cargar();
                              }),
                            ),
                        ],
                      ),
                      if (_verGrupo && grupos.length > 1) ...[
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _grupo?.id,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: context.l10n.grupo,
                          ),
                          items: [
                            for (final g in grupos)
                              DropdownMenuItem(
                                value: g.id,
                                child: Text(g.nombre),
                              ),
                          ],
                          onChanged: (id) => setState(() {
                            _grupo = grupos.firstWhere((g) => g.id == id);
                            _cargar();
                          }),
                        ),
                      ],
                      const SizedBox(height: 18),
                      if (_verGrupo) _vistaGrupo() else _vistaMia(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _cargando() => const Padding(
    padding: EdgeInsets.all(32),
    child: Center(child: Cargando()),
  );

  Widget _vistaMia() => FutureBuilder<EstadisticasJugador>(
    future: _mias,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done) return _cargando();
      if (snap.hasError) {
        return EstadoVacio(icono: Icons.error_outline, texto: '${snap.error}');
      }
      final e = snap.data!;
      if (e.partidos == 0) {
        return EstadoVacio(
          icono: Icons.query_stats_rounded,
          texto: context.l10n.estSinPartidos,
        );
      }
      return _Resumen(e: e);
    },
  );

  Widget _vistaGrupo() => FutureBuilder<List<EstadisticasJugador>>(
    future: _delGrupo,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done) return _cargando();
      if (snap.hasError) {
        return EstadoVacio(icono: Icons.error_outline, texto: '${snap.error}');
      }
      final lista = snap.data!;
      return Column(
        children: [
          for (final e in lista)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                shape: const Border(),
                title: Text(
                  e.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${context.l10n.estPartidos}: ${e.partidos} · '
                  '${context.l10n.estVictorias}: ${_pct(e.pctVictorias)}',
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [_Resumen(e: e, compacto: true)],
              ),
            ),
        ],
      );
    },
  );
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.e, this.compacto = false});
  final EstadisticasJugador e;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    Widget fila(String titulo, String valor, [String? detalle]) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: t.titleSmall),
                if (detalle != null)
                  Text(
                    detalle,
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Text(
            valor,
            style: t.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );

    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fila(
          l.estPartidos,
          '${e.partidos}',
          l.estGanadosPerdidos(e.ganados, e.perdidos),
        ),
        fila(l.estVictorias, _pct(e.pctVictorias)),
        const Divider(),
        fila(l.sets, '${e.setsGanados}-${e.setsPerdidos}'),
        fila(l.estJuegos, '${e.juegosGanados}-${e.juegosPerdidos}'),
        const Divider(),
        if (e.tienePuntos) ...[
          fila(
            l.estPctPuntos,
            _pct(e.pctPuntos),
            '${e.puntosGanados}-${e.puntosPerdidos} · '
            '${l.estPuntosDe(e.partidosConPuntos)}',
          ),
          fila(
            l.estMediaPuntos,
            e.mediaPuntosGanados.toStringAsFixed(1),
            l.estMediaDetalle(
              e.mediaPuntosGanados.toStringAsFixed(1),
              e.mediaPuntosPerdidos.toStringAsFixed(1),
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              l.estSinPuntos,
              style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
      ],
    );
    return compacto
        ? contenido
        : Card(
            margin: EdgeInsets.zero,
            child: Padding(padding: const EdgeInsets.all(18), child: contenido),
          );
  }
}
