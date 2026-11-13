import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'entrenador_providers.dart';

/// Formulario rápido de resultado: una sola pantalla con scroll y un botón fijo para enviar.
/// Hace `pop(true)` al enviar con éxito.
class ResultadoFormPage extends ConsumerWidget {
  const ResultadoFormPage({super.key, required this.encuentro});
  final EncuentroVista encuentro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clave = (encuentro.id, encuentro.localId, encuentro.visitanteId);
    final datos = ref.watch(datosFormularioProvider(clave));
    return Scaffold(
      appBar: AppBar(title: Text('Jornada ${encuentro.jornada}')),
      body: AsyncView<DatosFormulario>(
        value: datos,
        onRetry: () => ref.invalidate(datosFormularioProvider(clave)),
        builder: (d) => _Cuerpo(encuentro: encuentro, datos: d),
      ),
    );
  }
}

class _SetCtl {
  _SetCtl([int? l, int? v])
      : local = TextEditingController(text: l?.toString() ?? ''),
        visitante = TextEditingController(text: v?.toString() ?? '');
  final TextEditingController local, visitante;
  int? get l => int.tryParse(local.text.trim());
  int? get v => int.tryParse(visitante.text.trim());
  bool get vacio => local.text.trim().isEmpty && visitante.text.trim().isEmpty;
  void dispose() {
    local.dispose();
    visitante.dispose();
  }
}

class _PartidoEstado {
  _PartidoEstado(this.orden, this.tipo, this.localSel, this.visSel, this.sets);
  final int orden;
  final String tipo;
  final List<String?> localSel, visSel;
  final List<_SetCtl> sets;
}

class _Cuerpo extends ConsumerStatefulWidget {
  const _Cuerpo({required this.encuentro, required this.datos});
  final EncuentroVista encuentro;
  final DatosFormulario datos;
  @override
  ConsumerState<_Cuerpo> createState() => _CuerpoState();
}

class _CuerpoState extends ConsumerState<_Cuerpo> {
  late final List<_PartidoEstado> _partidos;
  final Map<String, String> _nombres = {};
  bool _incomparecencia = false;
  String? _ausente; // 'local' | 'visitante'
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final d = widget.datos;
    for (final j in [...d.local, ...d.visitante]) {
      _nombres[j.jugadorId] = j.nombreCompleto;
    }
    _incomparecencia = d.detalle.incomparecencia != null;
    _ausente = d.detalle.incomparecencia;
    _partidos = [
      for (var i = 0; i < d.detalle.partidos.length; i++) _construir(i, d.detalle.partidos[i]),
    ];
  }

  /// Jugadores preseleccionados por orden de plantilla: 1 por lado en individuales, 2 en dobles.
  List<String?> _preseleccion(List<Jugador> plantilla, int indice, int n, List<String> previos, List<String> nombresPrevios) {
    if (previos.isNotEmpty) {
      for (var k = 0; k < previos.length; k++) {
        _nombres.putIfAbsent(previos[k], () => k < nombresPrevios.length ? nombresPrevios[k] : 'Jugador');
      }
      return [for (var k = 0; k < n; k++) k < previos.length ? previos[k] : null];
    }
    if (plantilla.isEmpty) return List<String?>.filled(n, null);
    return [
      for (var k = 0; k < n; k++)
        (plantilla.length > k || n == 1) ? plantilla[(indice + k) % plantilla.length].jugadorId : null,
    ];
  }

  _PartidoEstado _construir(int i, PartidoDetalle p) {
    final n = p.tipo == 'dobles' ? 2 : 1;
    final d = widget.datos;
    final loc = _preseleccion(d.local, i, n, p.localIds, p.local);
    final vis = _preseleccion(d.visitante, i, n, p.visitanteIds, p.visitante);
    final sets = p.sets.isEmpty ? [_SetCtl()] : [for (final s in p.sets) _SetCtl(s[0], s[1])];
    return _PartidoEstado(p.orden, p.tipo, loc, vis, sets);
  }

  @override
  void dispose() {
    for (final p in _partidos) {
      for (final s in p.sets) {
        s.dispose();
      }
    }
    super.dispose();
  }

  /// Marcador en sets del partido, calculado en vivo con los sets válidos.
  (int, int) _marcador(_PartidoEstado p) {
    var a = 0, b = 0;
    for (final s in p.sets) {
      final l = s.l, v = s.v;
      if (l == null || v == null || l == v) continue;
      l > v ? a++ : b++;
    }
    return (a, b);
  }

  Future<void> _enviar() async {
    final e = widget.encuentro;
    Map<String, dynamic> json;
    if (_incomparecencia) {
      if (_ausente == null) return avisar(context, 'Indica qué equipo no se presentó.');
      json = {'incomparecencia': _ausente, 'partidos': <Map<String, dynamic>>[]};
    } else {
      final partidos = <Map<String, dynamic>>[];
      for (final p in _partidos) {
        final sets = <List<int>>[];
        for (final s in p.sets) {
          if (s.vacio) continue;
          final l = s.l, v = s.v;
          if (l == null || v == null || l < 0 || v < 0) {
            return avisar(context, 'Completa los dos marcadores de cada set (partido ${p.orden}).');
          }
          if (l == v) return avisar(context, 'Marcador de set no válido: no puede haber empate (partido ${p.orden}).');
          sets.add([l, v]);
        }
        if (sets.isEmpty) continue;
        partidos.add({
          'orden': p.orden,
          'local': p.localSel.whereType<String>().toSet().toList(),
          'visitante': p.visSel.whereType<String>().toSet().toList(),
          'sets': sets,
        });
      }
      if (partidos.isEmpty) return avisar(context, 'Añade al menos un set para guardar el resultado.');
      json = {'incomparecencia': null, 'partidos': partidos};
    }
    setState(() => _enviando = true);
    try {
      await ref.read(ligaRepositoryProvider).registrarResultado(e.id, json);
      if (mounted) Navigator.of(context).pop(true);
    } catch (err) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeErrorEntrenador(err));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.encuentro;
    final tema = Theme.of(context);
    return Column(children: [
      Expanded(
        child: ListView(padding: const EdgeInsets.all(12), children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Text('${e.local}  vs  ${e.visitante}', style: tema.textTheme.titleMedium, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(fechaCorta(e.fecha), style: tema.textTheme.bodySmall),
                if (e.confirmado)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Este encuentro ya tiene resultado; al guardar se corregirá.', textAlign: TextAlign.center),
                  ),
              ]),
            ),
          ),
          SwitchListTile(
            title: const Text('Incomparecencia'),
            subtitle: const Text('Un equipo no se presentó (derrota administrativa)'),
            value: _incomparecencia,
            onChanged: (v) => setState(() => _incomparecencia = v),
          ),
          if (_incomparecencia)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SegmentedButton<String>(
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: 'local', label: Text('No se presenta ${e.local}', overflow: TextOverflow.ellipsis)),
                  ButtonSegment(value: 'visitante', label: Text('No se presenta ${e.visitante}', overflow: TextOverflow.ellipsis)),
                ],
                selected: {?_ausente},
                onSelectionChanged: (s) => setState(() => _ausente = s.isEmpty ? null : s.first),
              ),
            )
          else
            for (var i = 0; i < _partidos.length; i++) _tarjetaPartido(i, _partidos[i]),
        ]),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: _enviando
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar resultado'),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _tarjetaPartido(int i, _PartidoEstado p) {
    final e = widget.encuentro;
    final tema = Theme.of(context);
    final (a, b) = _marcador(p);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(p.tipo == 'dobles' ? 'Dobles' : 'Individual ${p.orden}', style: tema.textTheme.titleSmall),
            const Spacer(),
            Text('Sets $a - $b', style: tema.textTheme.titleSmall?.copyWith(color: tema.colorScheme.primary)),
          ]),
          const SizedBox(height: 8),
          _jugadores(i, 'local', e.local, p.localSel, widget.datos.local),
          _jugadores(i, 'visitante', e.visitante, p.visSel, widget.datos.visitante),
          const SizedBox(height: 8),
          for (var s = 0; s < p.sets.length; s++) _filaSet(i, s, p.sets[s]),
          if (p.sets.length < 3)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: Key('mas-set-$i'),
                onPressed: () => setState(() => p.sets.add(_SetCtl())),
                icon: const Icon(Icons.add),
                label: const Text('set'),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _jugadores(int i, String lado, String equipo, List<String?> sel, List<Jugador> plantilla) {
    // Si no se puede leer la plantilla (rival) no hay desplegable: el lado queda vacío.
    if (plantilla.isEmpty && sel.every((s) => s == null)) return const SizedBox.shrink();
    final ids = {...plantilla.map((j) => j.jugadorId), ...sel.whereType<String>()};
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        for (var k = 0; k < sel.length; k++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: k < sel.length - 1 ? 8 : 0),
              child: DropdownButtonFormField<String>(
                key: Key('jug-$i-$lado-$k'),
                initialValue: sel[k],
                isExpanded: true,
                decoration: InputDecoration(
                    labelText: sel.length == 1 ? equipo : '$equipo · J${k + 1}',
                    border: const OutlineInputBorder(), isDense: true),
                items: [for (final id in ids) DropdownMenuItem(value: id, child: Text(_nombres[id] ?? 'Jugador', overflow: TextOverflow.ellipsis))],
                onChanged: (v) => setState(() => sel[k] = v),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _filaSet(int i, int s, _SetCtl c) {
    Widget campo(String clave, TextEditingController ctl) => SizedBox(
          width: 72,
          child: TextField(
            key: Key('set-$i-$s-$clave'),
            controller: ctl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            onChanged: (_) => setState(() {}),
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 56, child: Text('Set ${s + 1}')),
        campo('l', c.local),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('-')),
        campo('v', c.visitante),
      ]),
    );
  }
}
