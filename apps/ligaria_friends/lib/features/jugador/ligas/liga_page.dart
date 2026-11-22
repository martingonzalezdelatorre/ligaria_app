import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../grupos/grupos_repositorio.dart';
import 'confirmacion_repositorio.dart';
import 'dialogo_resultado.dart';
import 'marcador_page.dart';
import 'marcador_repositorio.dart';
import 'tanteador_page.dart';
import 'tanteo.dart';
import 'formato.dart';
import 'ligas_repositorio.dart';
import '../../../core/idioma.dart';

/// Una liga: participantes (mientras se prepara), y después clasificación y partidos con resultados.
class LigaPage extends StatefulWidget {
  const LigaPage({
    super.key,
    required this.liga,
    required this.esAdmin,
    required this.ligas,
    required this.grupos,
  });
  final Liga liga;
  final bool esAdmin;
  final LigasRepositorio ligas;
  final GruposRepositorio grupos;
  @override
  State<LigaPage> createState() => _LigaPageState();
}

class _LigaPageState extends State<LigaPage> {
  late Liga _liga = widget.liga;
  Set<String> _vivos = {};
  StreamSubscription<Set<String>>? _subVivos;

  @override
  void initState() {
    super.initState();
    _subVivos = MarcadorRepositorio.instancia
        .enDirecto(widget.liga.grupoId)
        .listen((v) {
          if (mounted) setState(() => _vivos = v);
        }, onError: (_) {});
  }

  @override
  void dispose() {
    _subVivos?.cancel();
    super.dispose();
  }

  late Future<_Datos> _datos = _cargar();

  Future<_Datos> _cargar() async {
    final r = widget.ligas;
    final id = _liga.id;
    final ps = await r.participantes(id);
    if (_liga.enBorrador) return _Datos(participantes: ps);
    Map<String, Confirmacion> conf = {};
    try {
      conf = await ConfirmacionRepositorio.instancia.delGrupo(_liga.grupoId);
    } catch (_) {}
    return _Datos(
      participantes: ps,
      partidos: await r.partidos(id),
      tabla: await r.clasificacion(id),
      confirmaciones: conf,
    );
  }

  Future<void> _confirmar(PartidoLiga p) async {
    try {
      await ConfirmacionRepositorio.instancia.confirmar(partidoId: p.id);
      if (!mounted) return;
      avisar(context, context.l10n.resultadoConfirmado);
      _recargar();
    } catch (e) {
      if (mounted) avisar(context, context.l10n.errConfirmar);
    }
  }

  void _recargar() {
    final nuevos = _cargar();
    setState(() {
      _datos = nuevos;
    });
  }

  Future<void> _ejecutar(Future<void> Function() accion) async {
    try {
      await accion();
      if (mounted) _recargar();
    } on LigasException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
  }

  Future<void> _agregar() async {
    final miembros = await widget.grupos.miembros(_liga.grupoId);
    final usados = await widget.ligas.jugadoresInscritos(_liga.id);
    if (!mounted) return;
    final n = _liga.modalidad == Modalidad.individual ? 1 : 2;
    final elegidos = await showDialog<List<Miembro>>(
      context: context,
      builder: (_) => _ElegirJugadores(
        miembros: miembros.where((m) => !usados.contains(m.id)).toList(),
        cuantos: n,
      ),
    );
    if (elegidos == null) return;
    await _ejecutar(
      () => widget.ligas.agregarParticipante(
        ligaId: _liga.id,
        nombre: elegidos.map((m) => m.nombre).join(' / '),
        usuarios: [for (final m in elegidos) m.id],
      ),
    );
  }

  Future<void> _generar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.l10n.generarCalendario),
        content: Text(c.l10n.generarCalendarioTxt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(c.l10n.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(c.l10n.generar),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final n = await widget.ligas.generarCalendario(_liga.id);
      if (!mounted) return;
      final nuevas = await widget.ligas.ligas(_liga.grupoId);
      setState(
        () => _liga = nuevas.firstWhere(
          (l) => l.id == _liga.id,
          orElse: () => _liga,
        ),
      );
      if (!mounted) return;
      _recargar();
      avisar(
        context,
        n == 1
            ? context.l10n.calendarioGenerado1
            : context.l10n.calendarioGeneradoN(n),
      );
    } on LigasException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
  }

  Future<void> _tanteador(PartidoLiga p) async {
    final res = await Navigator.of(context).push<ResultadoTanteador>(
      MaterialPageRoute(
        builder: (_) => TanteadorPage(
          local: p.localNombre,
          visitante: p.visitanteNombre,
          deporte: _liga.deporte,
          setsParaGanar: _liga.setsParaGanar,
          partidoId: p.id,
        ),
      ),
    );
    if (res == null) return;
    await _ejecutar(
      () => widget.ligas.registrarResultado(p.id, res.sets, puntos: res.puntos),
    );
  }

  void _ver(PartidoLiga p) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MarcadorPage(
        local: p.localNombre,
        visitante: p.visitanteNombre,
        deporte: _liga.deporte,
        partidoId: p.id,
      ),
    ),
  );

  Future<void> _resultado(PartidoLiga p) async {
    final sets = await showDialog<List<List<int>>>(
      context: context,
      builder: (_) => DialogoResultado(
        localNombre: p.localNombre,
        visitanteNombre: p.visitanteNombre,
        setsParaGanar: _liga.setsParaGanar,
      ),
    );
    if (sets == null) return;
    await _ejecutar(() => widget.ligas.registrarResultado(p.id, sets));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_liga.nombre, overflow: TextOverflow.ellipsis),
      ),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            maxAncho: 800,
            child: FutureBuilder<_Datos>(
              future: _datos,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return EstadoVacio(
                    icono: Icons.error_outline,
                    texto: '${snap.error}',
                  );
                }
                final d = snap.data!;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  children: [
                    Aparece(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Insignia(
                            _liga.deporte.etiqueta,
                            icono: Icons.sports_tennis,
                          ),
                          Insignia(
                            _liga.modalidad.etiqueta,
                            icono: Icons.people_alt_outlined,
                          ),
                          Insignia(
                            _liga.estadoEtiqueta,
                            color: cs.primary,
                            icono: Icons.flag_outlined,
                          ),
                          Insignia(
                            context.l10n.alMejorDeSets(
                              _liga.setsParaGanar * 2 - 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_liga.enBorrador)
                      ..._borrador(d, t, cs)
                    else ...[
                      Text(context.l10n.clasificacion, style: t.titleLarge),
                      const SizedBox(height: 12),
                      _Tabla(filas: d.tabla),
                      const SizedBox(height: 28),
                      Text(context.l10n.partidos, style: t.titleLarge),
                      const SizedBox(height: 12),
                      ..._rondas(d.partidos, d.confirmaciones, t, cs),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _borrador(_Datos d, TextTheme t, ColorScheme cs) {
    final falta = d.participantes.length < 2;
    return [
      Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.participantesN(d.participantes.length),
              style: t.titleLarge,
            ),
          ),
          if (widget.esAdmin)
            FilledButton.icon(
              onPressed: _agregar,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.anadir),
            ),
        ],
      ),
      const SizedBox(height: 12),
      if (d.participantes.isEmpty)
        Text(
          widget.esAdmin
              ? context.l10n.sinParticipantesAdmin
              : context.l10n.sinParticipantesMiembro,
          style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
      for (final p in d.participantes)
        _Fila(
          izquierda: AvatarEquipo(p.nombre, tam: 36),
          derecha: widget.esAdmin
              ? IconButton(
                  tooltip: context.l10n.quitar,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () =>
                      _ejecutar(() => widget.ligas.quitarParticipante(p.id)),
                )
              : null,
          child: Text(p.nombre, style: t.titleSmall),
        ),
      if (widget.esAdmin) ...[
        const SizedBox(height: 20),
        Text(
          falta ? context.l10n.necesitas2 : context.l10n.cuandoEstenTodos,
          style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: falta ? null : _generar,
            icon: const Icon(Icons.event_available_outlined),
            label: Text(context.l10n.generarCalendario),
          ),
        ),
      ],
    ];
  }

  List<Widget> _rondas(
    List<PartidoLiga> partidos,
    Map<String, Confirmacion> confirmaciones,
    TextTheme t,
    ColorScheme cs,
  ) {
    final porRonda = <int, List<PartidoLiga>>{};
    for (final p in partidos) {
      porRonda.putIfAbsent(p.ronda, () => []).add(p);
    }
    return [
      for (final e in porRonda.entries) ...[
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            context.l10n.rondaN(e.key),
            style: t.titleSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        for (final p in e.value)
          _Fila(
            derecha: p.jugado
                ? Icon(Icons.check_circle_rounded, color: cs.primary)
                : Column(
                    children: [
                      if (_vivos.contains(p.id))
                        FilledButton.tonalIcon(
                          onPressed: () => _ver(p),
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: Text(context.l10n.verMarcador),
                        ),
                      FilledButton.icon(
                        onPressed: () => _tanteador(p),
                        icon: const Icon(Icons.scoreboard_outlined, size: 18),
                        label: Text(context.l10n.tanteador),
                      ),
                      TextButton(
                        onPressed: () => _resultado(p),
                        child: Text(context.l10n.introducirResultado),
                      ),
                    ],
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: p.localNombre,
                        style: TextStyle(
                          fontWeight: p.ganador == 'LOCAL'
                              ? FontWeight.w900
                              : null,
                        ),
                      ),
                      const TextSpan(text: '  vs  '),
                      TextSpan(
                        text: p.visitanteNombre,
                        style: TextStyle(
                          fontWeight: p.ganador == 'VISITANTE'
                              ? FontWeight.w900
                              : null,
                        ),
                      ),
                    ],
                  ),
                  style: t.titleSmall,
                ),
                if (p.fechaHora != null || p.lugar != null)
                  Text(
                    [
                      if (p.fechaHora != null) fechaHora(p.fechaHora!),
                      if (p.lugar != null) p.lugar!,
                    ].join(' · '),
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                if (!p.jugado && _vivos.contains(p.id))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Insignia(
                      context.l10n.enDirecto,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                if (p.jugado && confirmacionDe(confirmaciones, p.id) != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: EstadoConfirmacion(
                      c: confirmacionDe(confirmaciones, p.id)!,
                      onConfirmar: () => _confirmar(p),
                    ),
                  ),
                if (p.resultado != null)
                  Text(
                    p.resultado!,
                    style: t.bodyMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
      ],
    ];
  }
}

class _Datos {
  const _Datos({
    required this.participantes,
    this.partidos = const [],
    this.tabla = const [],
    this.confirmaciones = const {},
  });
  final List<Participante> participantes;
  final List<PartidoLiga> partidos;
  final List<FilaClasificacion> tabla;
  final Map<String, Confirmacion> confirmaciones;
}

class _Fila extends StatelessWidget {
  const _Fila({required this.child, this.izquierda, this.derecha});
  final Widget child;
  final Widget? izquierda, derecha;

  @override
  Widget build(BuildContext context) {
    final marca = Marca.de(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: marca.borde),
      ),
      child: Row(
        children: [
          if (izquierda != null) ...[izquierda!, const SizedBox(width: 12)],
          Expanded(child: child),
          ?derecha,
        ],
      ),
    );
  }
}

class _Tabla extends StatelessWidget {
  const _Tabla({required this.filas});
  final List<FilaClasificacion> filas;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    final cab = t.labelMedium?.copyWith(
      color: cs.onSurfaceVariant,
      fontWeight: FontWeight.w800,
    );
    Widget num(String s, {TextStyle? estilo}) => SizedBox(
      width: 34,
      child: Text(
        s,
        textAlign: TextAlign.center,
        style: estilo ?? t.bodyMedium,
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: marca.borde),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 28),
              Expanded(child: Text(context.l10n.jugador, style: cab)),
              num(context.l10n.tablaPJ, estilo: cab),
              num(context.l10n.tablaG, estilo: cab),
              num(context.l10n.tablaP, estilo: cab),
              num(context.l10n.tablaPts, estilo: cab),
            ],
          ),
          const Divider(height: 16),
          for (var i = 0; i < filas.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${i + 1}',
                      style: t.titleSmall?.copyWith(
                        color: i == 0 ? cs.primary : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      filas[i].nombre,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleSmall,
                    ),
                  ),
                  num('${filas[i].pj}'),
                  num('${filas[i].pg}'),
                  num('${filas[i].pp}'),
                  num(
                    '${filas[i].puntos}',
                    estilo: t.titleSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Elige 1 jugador (individual) o 2 (parejas) entre los miembros libres.
class _ElegirJugadores extends StatefulWidget {
  const _ElegirJugadores({required this.miembros, required this.cuantos});
  final List<Miembro> miembros;
  final int cuantos;
  @override
  State<_ElegirJugadores> createState() => _ElegirJugadoresState();
}

class _ElegirJugadoresState extends State<_ElegirJugadores> {
  final _sel = <Miembro>[];

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.cuantos == 1
          ? context.l10n.anadirJugador
          : context.l10n.anadirPareja,
    ),
    content: SizedBox(
      width: 380,
      child: widget.miembros.isEmpty
          ? Text(context.l10n.todosInscritos)
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.cuantos == 1
                        ? context.l10n.eligeQuienInscribir
                        : context.l10n.eligeLos2Pareja,
                  ),
                  for (final m in widget.miembros)
                    CheckboxListTile(
                      dense: true,
                      title: Text(
                        m.esYo ? '${m.nombre} ${context.l10n.tu}' : m.nombre,
                      ),
                      value: _sel.contains(m),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          if (_sel.length < widget.cuantos) _sel.add(m);
                        } else {
                          _sel.remove(m);
                        }
                      }),
                    ),
                ],
              ),
            ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancelar),
      ),
      FilledButton(
        onPressed: _sel.length == widget.cuantos
            ? () => Navigator.pop(context, _sel)
            : null,
        child: Text(context.l10n.anadir),
      ),
    ],
  );
}
