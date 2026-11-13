import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';

class _SetCtl {
  _SetCtl([String l = '', String v = ''])
      : local = TextEditingController(text: l),
        visitante = TextEditingController(text: v);
  final TextEditingController local, visitante;
  void dispose() {
    local.dispose();
    visitante.dispose();
  }
}

/// Formulario de corrección: sets por partido, incomparecencia y motivo obligatorio.
class CorreccionPage extends ConsumerStatefulWidget {
  const CorreccionPage({super.key, required this.escuelaId, required this.encuentro, required this.detalle});
  final String escuelaId;
  final EncuentroVista encuentro;
  final DetalleEncuentro detalle;
  @override
  ConsumerState<CorreccionPage> createState() => _CorreccionPageState();
}

class _CorreccionPageState extends ConsumerState<CorreccionPage> {
  final _motivo = TextEditingController();
  late final List<List<_SetCtl>> _sets = [
    for (final p in widget.detalle.partidos)
      p.sets.isEmpty ? [_SetCtl()] : [for (final s in p.sets) _SetCtl('${s[0]}', '${s[1]}')],
  ];
  late String? _inc = widget.detalle.incomparecencia;
  String? _errorMotivo, _errorSets;
  bool _enviando = false;

  @override
  void dispose() {
    _motivo.dispose();
    for (final l in _sets) {
      for (final c in l) {
        c.dispose();
      }
    }
    super.dispose();
  }

  /// Construye el JSON de resultado o devuelve null (marcando el error) si no es válido.
  Map<String, dynamic>? _construir() {
    if (_inc != null) return {'incomparecencia': _inc, 'partidos': <Map<String, dynamic>>[]};
    final partidos = <Map<String, dynamic>>[];
    var total = 0;
    for (var i = 0; i < widget.detalle.partidos.length; i++) {
      final p = widget.detalle.partidos[i];
      final sets = <List<int>>[];
      for (final c in _sets[i]) {
        final lt = c.local.text.trim(), vt = c.visitante.text.trim();
        if (lt.isEmpty && vt.isEmpty) continue;
        final l = int.tryParse(lt), v = int.tryParse(vt);
        if (l == null || v == null || l < 0 || v < 0 || l == v) {
          setState(() => _errorSets = 'Revisa los marcadores del partido ${p.orden}: números válidos y sin empates en un set.');
          return null;
        }
        sets.add([l, v]);
      }
      total += sets.length;
      partidos.add({'orden': p.orden, 'local': p.localIds, 'visitante': p.visitanteIds, 'sets': sets});
    }
    if (total == 0) {
      setState(() => _errorSets = 'Introduce al menos un set.');
      return null;
    }
    return {'incomparecencia': null, 'partidos': partidos};
  }

  Future<void> _enviar() async {
    final motivo = _motivo.text.trim();
    setState(() {
      _errorMotivo = motivo.isEmpty ? 'Indica el motivo de la corrección' : null;
      _errorSets = null;
    });
    if (motivo.isEmpty) return;
    final json = _construir();
    if (json == null) return;
    setState(() => _enviando = true);
    try {
      await ref.read(ligaRepositoryProvider).corregirResultado(widget.encuentro.id, json, motivo);
      refrescarResultado(ref, widget.escuelaId, widget.encuentro);
      if (!mounted) return;
      avisar(context, 'Resultado corregido. La clasificación se ha actualizado.');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeError(e, defecto: 'No se pudo guardar la corrección.'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.encuentro;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Corregir resultado')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('${e.local} vs ${e.visitante}', style: tema.textTheme.titleMedium),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Incomparecencia'),
          subtitle: const Text('Derrota administrativa del equipo que no se presenta'),
          value: _inc != null,
          onChanged: (v) => setState(() => _inc = v ? 'visitante' : null),
        ),
        if (_inc != null)
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'local', label: Text('No se presenta ${e.local}', overflow: TextOverflow.ellipsis)),
              ButtonSegment(value: 'visitante', label: Text('No se presenta ${e.visitante}', overflow: TextOverflow.ellipsis)),
            ],
            selected: {_inc!},
            onSelectionChanged: (s) => setState(() => _inc = s.first),
          )
        else
          for (var i = 0; i < widget.detalle.partidos.length; i++) _bloquePartido(i),
        if (_errorSets != null)
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(_errorSets!, style: TextStyle(color: tema.colorScheme.error))),
        const SizedBox(height: 16),
        TextField(
          controller: _motivo,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: 'Motivo de la corrección', errorText: _errorMotivo, border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _enviando ? null : _enviar,
          child: _enviando
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar corrección'),
        ),
      ]),
    );
  }

  Widget _bloquePartido(int i) {
    final p = widget.detalle.partidos[i];
    String quien(List<String> n) => n.isEmpty ? '—' : n.join(' / ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Partido ${p.orden} · ${p.tipo == 'dobles' ? 'Dobles' : 'Individual'}', style: Theme.of(context).textTheme.labelLarge),
          Text('${quien(p.local)}  vs  ${quien(p.visitante)}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          for (var s = 0; s < _sets[i].length; s++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Text('Set ${s + 1}'),
                const SizedBox(width: 12),
                Expanded(child: _campo(_sets[i][s].local, 'Local P${p.orden} S${s + 1}')),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('-')),
                Expanded(child: _campo(_sets[i][s].visitante, 'Visitante P${p.orden} S${s + 1}')),
                IconButton(
                  tooltip: 'Quitar set',
                  icon: const Icon(Icons.close),
                  onPressed: _sets[i].length <= 1
                      ? null
                      : () => setState(() {
                            _sets[i].removeAt(s).dispose();
                          }),
                ),
              ]),
            ),
          if (_sets[i].length < 5)
            TextButton.icon(
              onPressed: () => setState(() => _sets[i].add(_SetCtl())),
              icon: const Icon(Icons.add),
              label: const Text('Añadir set'),
            ),
        ]),
      ),
    );
  }

  Widget _campo(TextEditingController c, String etiqueta) => Semantics(
        label: etiqueta,
        child: TextField(
          key: ValueKey(etiqueta),
          controller: c,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
        ),
      );
}
